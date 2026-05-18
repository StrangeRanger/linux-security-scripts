#!/bin/bash
#
# This script automates the installation and configuration of ModSecurity as a Web
# Application Firewall (WAF) for Nginx on Linux systems. It clones the ModSecurity and
# ModSecurity-nginx repositories, builds and installs the ModSecurity module, configures
# Nginx to load the module, and sets up the OWASP Core Rule Set for basic protection against
# common web vulnerabilities.
#
# Version: v1.0.0-beta
# License: MIT License
#          Copyright (c) 2026 Hunter T. (StrangeRanger)
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
    libgd-dev
    libgeoip-dev
    liblmdb-dev
    libpcre2-dev
    libperl-dev
    libssl-dev
    libtool
    libxml2-dev
    libxslt1-dev
    libyajl-dev
    pkgconf
    wget
    zlib1g-dev
)

C_NGINX_VERSION=""
C_NGINX_CONFIG_ARGS=""
C_MODULES_PATH=""

modsecurity_clone_exists=false
coreruleset_clone_exists=false
missing_pkgs=()


####[Functions]#############################################################################


error_exit() {
    local message="${1:-An unknown error occurred}"
    local exit_code="${2:-1}"

    echo "${C_ERROR}${message}" >&2
    exit "$exit_code"
}

on_err() {
    local exit_code=$?
    error_exit "Command failed at line ${BASH_LINENO[0]}: ${BASH_COMMAND}" "$exit_code"
}

require_non_empty() {
    local var_name="$1"
    local var_value="${2:-}"

    [[ -n "$var_value" ]] || error_exit "Required value '${var_name}' is empty"
}


####[ Trapping & Initial Checks ]###########################################################


trap on_err ERR


####[ Initial Checks ]######################################################################


if (( EUID != 0 )); then
    error_exit "This script must be run with root privileges"
fi

if command -v nginx &>/dev/null; then
    C_NGINX_VERSION="$(nginx -V 2>&1 | sed -n 's/^nginx version: nginx\/\([0-9.]\+\).*/\1/p')"
    C_NGINX_CONFIG_ARGS="$(nginx -V 2>&1 | awk -F': ' '/configure arguments/ {print $2}')"
    C_MODULES_PATH="$(sed -n 's/.*--modules-path=\([^ ]*\).*/\1/p' <<<"$C_NGINX_CONFIG_ARGS" | head -n 1)"
    require_non_empty "C_NGINX_VERSION" "$C_NGINX_VERSION"
    require_non_empty "C_NGINX_CONFIG_ARGS" "$C_NGINX_CONFIG_ARGS"
    require_non_empty "C_MODULES_PATH" "$C_MODULES_PATH"
else
    error_exit "Nginx is not installed or not in PATH"
fi

for pkg in "${C_REQUIRED_PKGS[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
        missing_pkgs+=("$pkg")
    fi
done

if (( ${#missing_pkgs[@]} > 0 )); then
    echo "${C_INFO}Installing missing packages: ${missing_pkgs[*]}"
    apt-get update
    apt-get install -y "${missing_pkgs[@]}"
fi


####[ Main ]################################################################################


echo "${C_INFO}Starting ModSecurity installation and configuration process..."

###
### [ Clone and build ModSecurity ]
###

if [[ ! -d "ModSecurity/.git" ]]; then
    echo "${C_INFO}Cloning ModSecurity repository..."
    git clone --depth 1 -b v3/master --single-branch https://github.com/owasp-modsecurity/ModSecurity
else
    echo "${C_NOTE}ModSecurity repository already exists"
    modsecurity_clone_exists=true
fi

pushd ModSecurity >/dev/null
if [[ $modsecurity_clone_exists == true ]]; then
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
make install
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
mkdir -p "$C_MODULES_PATH"
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

echo "${C_SUCC}DONE"
