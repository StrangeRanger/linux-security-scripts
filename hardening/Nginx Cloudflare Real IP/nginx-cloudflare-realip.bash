#!/bin/bash
#
# Configure Nginx to trust Cloudflare's IP ranges and use the CF-Connecting-IP header for
# the true client IP.
#
# Version: v1.0.0
# License: MIT License
#          Copyright (c) 2026 Hunter T. (StrangeRanger)
#
############################################################################################
set -euo pipefail
####[ Global Variables ]####################################################################


readonly C_CLOUDFLARE_IPV4_RANGES_URL="https://www.cloudflare.com/ips-v4/"
readonly C_CLOUDFLARE_IPV6_RANGES_URL="https://www.cloudflare.com/ips-v6/"
readonly C_REAL_IP_CONFIG_FILE="/etc/nginx/conf.d/cloudflare-realip.conf"

readonly C_YELLOW=$'\033[1;33m'
readonly C_GREEN=$'\033[0;32m'
readonly C_BLUE=$'\033[0;34m'
readonly C_CYAN=$'\033[0;36m'
readonly C_RED=$'\033[1;31m'
readonly C_NC=$'\033[0m'

readonly C_ERROR="${C_RED}ERROR:${C_NC} "
readonly C_WARN="${C_YELLOW}==>${C_NC} "
readonly C_SUCC="${C_GREEN}==>${C_NC} "
readonly C_INFO="${C_BLUE}==>${C_NC} "
readonly C_NOTE="${C_CYAN}==>${C_NC} "

ipv4_response=""
ipv6_response=""


####[ Initial Checks ]######################################################################


## User confirmation to overwrite existing configuration file if it exists.
if [[ -f "$C_REAL_IP_CONFIG_FILE" ]]; then
    echo "${C_WARN}Cloudflare real IP configuration file already exists" >&2
    read -rp "${C_NOTE}Do you want to overwrite it? [y/N]: " choice

    choice="${choice,,}"
    if [[ ! "$choice" =~ ^y(es)?$ ]]; then
        echo "${C_WARN}Aborting configuration. No changes were made." >&2
        exit 0
    fi
fi


####[ Main ]################################################################################


printf "%sWe will now configure Nginx to trust Cloudflare's IP ranges. " "$C_NOTE"
read -rp "Press [Enter] to continue."

###
### Retrieve Cloudflare IP ranges.
###

echo "${C_INFO}Retrieving Cloudflare IPv4 range..."
ipv4_response=$(curl -fsSL "$C_CLOUDFLARE_IPV4_RANGES_URL") || exit 1
echo "${C_INFO}Retrieving Cloudflare IPv6 range..."
ipv6_response=$(curl -fsSL "$C_CLOUDFLARE_IPV6_RANGES_URL") || exit 1

# Ensure neither response is empty.
if [[ -z ${ipv4_response[0]} || -z ${ipv6_response[0]} ]]; then
    echo "${C_ERROR}Cloudflare returned an empty IP range list" >&2
    exit 1
fi

###
### Configure Cloudflare real IP configuration file for Nginx.
###

echo "${C_INFO}Configuring Cloudflare real IP configuration file for Nginx..."
sudo tee "$C_REAL_IP_CONFIG_FILE" > /dev/null <<EOF
###
### [ Real IP module configurations ]
###
### Trust Cloudflare's IP ranges as legitimate proxies, and specify the header
### Cloudflare uses to carry the true client IP. ONLY ADD TRUSTED PROXIES.
### For a list of all/updated IP Ranges, visit: https://www.cloudflare.com/ips/
### More info about this module: https://nginx.org/en/docs/http/ngx_http_realip_module.html
###

## All of Cloudflare's IPv4 addresses.
$(while IFS= read -r ip; do
    printf "set_real_ip_from %s;\n" "$ip"
done <<< "$ipv4_response")

## All of Cloudflare's IPv6 addresses.
$(while IFS= read -r ip; do
    printf "set_real_ip_from %s;\n" "$ip"
done <<< "$ipv6_response")

# The header containing the true client IP.
real_ip_header CF-Connecting-IP;

# CF-Connecting-IP normally contains a single client address, so recursive
# processing has no practical effect with the current real_ip_header.
real_ip_recursive off;
EOF

echo "${C_SUCC}Finished configuring Cloudflare real IP configuration file for Nginx"

###
### Post configuration checks and restart Nginx.
###

echo "${C_INFO}Checking Nginx configuration..."

if ! nginx_config=$(sudo nginx -T); then
    echo "${C_ERROR}Failed to retrieve Nginx configuration" >&2
    exit 1
fi

if ! grep -Fxq "# configuration file ${C_REAL_IP_CONFIG_FILE}:" <<< "$nginx_config"; then
    echo "${C_ERROR}Nginx does not include '${C_REAL_IP_CONFIG_FILE}'" >&2
    echo "${C_NOTE}Add 'include /etc/nginx/conf.d/*.conf;' inside the http block of your" \
        "active Nginx configuration, or include the file directly" >&2
    echo "${C_NOTE}Then rerun these checks before restarting Nginx" >&2
    exit 1
fi
unset nginx_config

echo "${C_INFO}Applying changes..."
if ! sudo systemctl restart nginx; then
    echo "${C_ERROR}Failed to restart Nginx" >&2
    exit 1
fi

echo "${C_SUCC}Done"
