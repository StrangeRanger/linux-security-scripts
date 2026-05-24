#!/bin/bash
#
# This script automates the installation and configuration of ModSecurity as a Web
# Application Firewall (WAF) for Nginx on Linux systems. It clones the ModSecurity and
# ModSecurity-nginx repositories, builds and installs the ModSecurity module, configures
# Nginx to load the module, and sets up the OWASP Core Rule Set for basic protection against
# common web vulnerabilities.
#
# Version: v1.0.0-beta.3
# License: MIT License
#          Copyright (c) 2026 Hunter T. (StrangeRanger)
#
# TODO: Delete existing nginx source directory if it exists? Maybe a cleanup?
# TODO: Go through and verify 'sudo' is only used where necessary.
# TODO: Go through and ensure proper ownership and permissions of create, copied, and
#   modified files.
#
############################################################################################
set -Eeuo pipefail
####[ Global Variables ]####################################################################


readonly C_GREEN=$'\033[0;32m'
readonly C_BLUE=$'\033[0;34m'
readonly C_CYAN=$'\033[0;36m'
readonly C_RED=$'\033[1;31m'
readonly C_NC=$'\033[0m'

readonly C_ERROR="${C_RED}ERROR:${C_NC} "
readonly C_SUCC="${C_GREEN}==>${C_NC} "
readonly C_INFO="${C_BLUE}==>${C_NC} "
readonly C_NOTE="${C_CYAN}==>${C_NC} "

readonly C_SO_FILE="ngx_http_modsecurity_module.so"
readonly C_MODULES_AVAILABLE="/etc/nginx/modules-available"
readonly C_MODULES_ENABLED="/etc/nginx/modules-enabled"
readonly C_MODSEC_PATH="/etc/nginx/modsec"
readonly C_MODSEC_CONF_PATH="$C_MODSEC_PATH/modsecurity.conf"
readonly C_MAIN_CONF_PATH="$C_MODSEC_PATH/main.conf"
readonly C_REQUIRED_PKGS=(
    git
    autoconf
    automake
    build-essential
    libcurl4-openssl-dev
    libgeoip-dev
    libpcre2-dev
    libtool
    libxml2-dev
    libyajl-dev
    pkgconf
    wget
    zlib1g-dev
)

C_NGINX_VERSION=""
C_NGINX_CONFIG_ARGS=""
C_MODULES_PATH=""

coreruleset_clone_exists=false
required_pkgs=("${C_REQUIRED_PKGS[@]}")
missing_pkgs=()


####[Functions]#############################################################################


####
# Print an error message and exit with the provided exit code.
#
# NOTE: This function is intended to be used in the 'on_error' trap handler.
on_error() {
    local exit_code=$?

    echo "${C_ERROR}Command failed at line ${BASH_LINENO[0]}: ${BASH_COMMAND}" >&2
    exit "$exit_code"
}

####
# Check if a variable is empty. If it is empty, print an error message and exit with
# code 1.
is_not_empty() {
    local var_name="$1"
    local -n var_ref="$1"

    if [[ -z "$var_ref" ]]; then
        echo "${C_ERROR}Required value '${var_name}' is empty" >&2
        return 1
    fi
}

####
# Add additional packages to the list of required packages if certain Nginx modules are
# enabled.
require_pkg() {
    local required_pkg="$1"

    for pkg in "${required_pkgs[@]}"; do
        [[ $pkg == "$required_pkg" ]] && return
    done

    required_pkgs+=("$required_pkg")
}


####[ Trapping & Initial Checks ]###########################################################


trap on_error ERR


####[ Initial Checks ]######################################################################


if command -v nginx &>/dev/null; then
    C_NGINX_VERSION="$(nginx -V 2>&1 | sed -n 's/^nginx version: nginx\/\([0-9.]\+\).*/\1/p')"
    C_NGINX_CONFIG_ARGS="$(nginx -V 2>&1 | awk -F': ' '/configure arguments/ {print $2}')"
    C_MODULES_PATH="$(sed -n 's/.*--modules-path=\([^ ]*\).*/\1/p' <<< "$C_NGINX_CONFIG_ARGS" | head -n 1)"
    is_not_empty C_NGINX_VERSION || exit 1
    is_not_empty C_NGINX_CONFIG_ARGS || exit 1
    is_not_empty C_MODULES_PATH || exit 1
    readonly C_NGINX_VERSION C_NGINX_CONFIG_ARGS C_MODULES_PATH
else
    echo "${C_ERROR}Nginx is not installed or not in PATH" >&2
    exit 1
fi

[[ $C_NGINX_CONFIG_ARGS == *--with-http_image_filter_module* ]] && require_pkg "libgd-dev"
[[ $C_NGINX_CONFIG_ARGS == *--with-http_perl_module* ]] && require_pkg "libperl-dev"
[[ $C_NGINX_CONFIG_ARGS == *--with-http_xslt_module* ]] && require_pkg "libxslt1-dev"
[[ $C_NGINX_CONFIG_ARGS == *ssl* ]] && require_pkg "libssl-dev"


####[ Main ]################################################################################


read -rp "${C_NOTE}We will now install and configure ModSecurity. Press [Enter] to continue."

###
### [ Install Required Packages ]
###

for pkg in "${required_pkgs[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
        missing_pkgs+=("$pkg")
    fi
done

if (( ${#missing_pkgs[@]} > 0 )); then
    echo "${C_INFO}Installing missing packages: ${missing_pkgs[*]}"
    sudo apt-get update
    sudo apt-get install -y "${missing_pkgs[@]}"
fi

###
### [ Clone and build ModSecurity ]
###

if [[ ! -d "ModSecurity/.git" ]]; then
    echo "${C_INFO}Cloning ModSecurity repository..."
    git clone --depth 1 -b v3/master --single-branch https://github.com/owasp-modsecurity/ModSecurity
    pushd ModSecurity >/dev/null
else
    echo "${C_NOTE}ModSecurity repository already exists"
    pushd ModSecurity >/dev/null
    echo "${C_INFO}Updating existing ModSecurity repository..."
    # TODO: Consider adding a check to ensure the local repository is on the correct branch
    # and there are no local changes before pulling.
    git pull
fi

echo "${C_INFO}Initializing and updating git submodules..."
git submodule update --init --recursive

echo "${C_INFO}Building ModSecurity..."
./build.sh

echo "${C_INFO}Configuring ModSecurity..."
./configure --with-pcre2

echo "${C_INFO}Compiling ModSecurity..."
# Runs the build in parallel using all available CPU cores except one.
make -j"$(nproc --ignore=1)"

echo "${C_INFO}Installing ModSecurity..."
sudo make install
popd >/dev/null

###
### [ Clone, build, and install ModSecurity Nginx module ]
###

if [[ ! -d "ModSecurity-nginx/.git" ]]; then
    echo "${C_INFO}Cloning ModSecurity-nginx repository..."
    git clone --depth 1 https://github.com/owasp-modsecurity/ModSecurity-nginx
else
    echo "${C_NOTE}ModSecurity-nginx repository already exists"
    echo "${C_INFO}Updating existing ModSecurity-nginx repository..."
    pushd ModSecurity-nginx >/dev/null
    git pull
    popd >/dev/null
fi

echo "${C_INFO}Downloading Nginx source code for version '${C_NGINX_VERSION}'..."
[[ -f "nginx-${C_NGINX_VERSION}.tar.gz" ]] && rm -f "nginx-${C_NGINX_VERSION}.tar.gz"
wget "https://nginx.org/download/nginx-${C_NGINX_VERSION}.tar.gz"

echo "${C_INFO}Extracting Nginx source code..."
tar -xzf "nginx-${C_NGINX_VERSION}.tar.gz"

pushd "nginx-${C_NGINX_VERSION}" >/dev/null
echo "${C_INFO}Configuring Nginx with ModSecurity module..."
# Split the Nginx configure arguments into an array to handle cases where there are multiple
# arguments with spaces.
mapfile -t nginx_cfg_argv < <(xargs -n1 <<<"$C_NGINX_CONFIG_ARGS")
./configure "${nginx_cfg_argv[@]}" --with-compat --add-dynamic-module=../ModSecurity-nginx

echo "${C_INFO}Compiling ModSecurity Nginx module..."
make modules

echo "${C_INFO}Installing ModSecurity Nginx module..."
sudo mkdir -p "$C_MODULES_PATH"
sudo cp objs/"$C_SO_FILE" "$C_MODULES_PATH"
sudo chmod 0644 "$C_MODULES_PATH/$C_SO_FILE"
popd >/dev/null

echo "${C_INFO}Setting up Nginx configuration for ModSecurity module..."
sudo mkdir -p "$C_MODULES_AVAILABLE" "$C_MODULES_ENABLED"
echo "load_module $C_MODULES_PATH/$C_SO_FILE;" \
    | sudo tee "$C_MODULES_AVAILABLE/50-modsecurity.conf" >/dev/null

if [[ -e $C_MODULES_ENABLED/50-modsecurity.conf ]]; then
    echo "${C_NOTE}ModSecurity module is already enabled"
else
    echo "${C_INFO}Enabling ModSecurity module in Nginx..."
    sudo ln -s "$C_MODULES_AVAILABLE/50-modsecurity.conf" "$C_MODULES_ENABLED/50-modsecurity.conf"
fi

###
### [ Configure ModSecurity and OWASP Core Rule Set ]
###

echo "${C_INFO}Configuring ModSecurity rules..."
pushd ModSecurity >/dev/null
sudo mkdir -p "$C_MODSEC_PATH"
sudo cp unicode.mapping "$C_MODSEC_PATH/"
sudo cp modsecurity.conf-recommended "$C_MODSEC_CONF_PATH"

echo "${C_INFO}Enabling ModSecurity in On mode..."
sudo sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' "$C_MODSEC_CONF_PATH"
popd >/dev/null

pushd "$C_MODSEC_PATH" >/dev/null
if [[ ! -d coreruleset/.git ]]; then
    echo "${C_INFO}Cloning OWASP Core Rule Set repository..."
    sudo git clone https://github.com/coreruleset/coreruleset.git
else
    echo "${C_NOTE}OWASP Core Rule Set repository already exists"
    coreruleset_clone_exists=true
fi

# Use cd intentionally; keep dir stack unchanged so popd jumps to original pushd location.
cd coreruleset

if [[ $coreruleset_clone_exists == true ]]; then
    echo "${C_INFO}Updating existing OWASP Core Rule Set repository..."
    # TODO: Consider adding a check to ensure the local repository is on the correct branch
    # and there are no local changes before pulling.
    sudo git pull
fi

echo "${C_INFO}Configuring OWASP Core Rule Set..."
sudo cp crs-setup.conf.example crs-setup.conf
popd >/dev/null

echo "${C_INFO}Writing ModSecurity main configuration..."
sudo tee "$C_MAIN_CONF_PATH" >/dev/null <<EOF
Include $C_MODSEC_CONF_PATH
Include $C_MODSEC_PATH/coreruleset/crs-setup.conf
Include $C_MODSEC_PATH/coreruleset/rules/*.conf
EOF

###
### [ Finalize and restart Nginx ]
###

echo "${C_INFO}Testing Nginx configuration..."
sudo nginx -t
echo "${C_INFO}Restarting Nginx to apply changes..."
sudo systemctl restart nginx

echo "${C_SUCC}Finished installing and configuring ModSecurity WAF for Nginx"
cat <<EOF
${C_NOTE}To enable ModSecurity WAF for a site, add these lines to its Nginx server block, for example in '/etc/nginx/sites-enabled/':
${C_CYAN}
    ## Modsecurity settings
    modsecurity on;
    modsecurity_rules_file /etc/nginx/modsec/main.conf;
${C_NC}
EOF
