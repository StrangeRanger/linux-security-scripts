#!/bin/bash
#
# Set up UFW to only allow HTTP and HTTPS traffic from Cloudflare's IP ranges.
#
# Version: v1.0.0-alpha.2
# License: MIT License
#          Copyright (c) 2024-2025 Hunter T. (StrangeRanger)
#
############################################################################################
####[ Global Variables ]####################################################################


## URL for retrieving the current Cloudflare IP ranges.
readonly C_CLOUDFLARE_IPV4_RANGES_URL="https://www.cloudflare.com/ips-v4/"
readonly C_CLOUDFLARE_IPV6_RANGES_URL="https://www.cloudflare.com/ips-v6/"

current_cloudflare_rule_numbers=()
current_cloudflare_ip_ranges=()
new_cloudflare_ip_ranges=()
stage=0


####[ Function ]############################################################################


####
# Check if a UFW rule exists for a specific IP address and port.
#
# PARAMETERS:
#   - $1: ip (Required)
#   - $2: port (Required)
#
# RETURN:
#   - 0: The rule exists.
#   - ?: The rule does not exist.
ufw_rule_exists() {
    local ip="$1"
    local port="$2"

    ufw status | grep -qE "^${port}.*ALLOW.*${ip}.*$"
}

####
# Set the new Cloudflare IP ranges in UFW, retrieved from the Cloudflare website.
set_new_cloudflare_ip_ranges() {
    for ip in "${new_cloudflare_ip_ranges[@]}"; do
        ufw_rule_exists "$ip" "80,443" \
            || ufw allow from "$ip" to any port 80,443 proto tcp comment "Cloudflare IP"
    done
}

####
# Restores the previous (non-new) Cloudflare IP ranges in UFW.
restore_current_cloudflare_ip_ranges() {
    for ip in "${current_cloudflare_ip_ranges[@]}"; do
        ufw_rule_exists "$ip" "80,443" \
            || ufw allow from "$ip" to any port 80,443 proto tcp comment "Cloudflare IP"
    done
}

####
# Deletes all Cloudflare IP rules currently set in UFW.
#
# PARAMETERS:
#   - $1: grep_string (Optional, Default: 0)
#       - The string to look for in the UFW status output. Using an integer for the value
#         helps eliminate accidental misspellings when passing arguments.
#       - Acceptable values:
#           - 0: "Cloudflare IP"
#           - 1: "Temporary rule"
delete_set_cloudflare_rules() {
    local grep_string="${1:-0}"
    local current_cloudflare_rule_numbers

    if (( $1 == 0 )); then
        grep_string="Cloudflare IP"
    elif (( $1 == 1 )); then
        grep_string="Temporary rule"
    else
        echo "INTERNAL ERROR: Invalid argument: $1"
        exit 2
    fi

    mapfile -t current_cloudflare_rule_numbers < <(
        ufw status numbered \
            | grep -E "^\[ *[0-9]+\].*$grep_string" \
            | while IFS= read -r line; do
                ## Extract number between brackets (handles both [1] and [ 1] formats).
                temp="${line#*[}"
                temp="${temp%%]*}"
                ## Remove any leading/trailing whitespace.
                temp="${temp#"${temp%%[![:space:]]*}"}"
                temp="${temp%"${temp##*[![:space:]]}"}"
                echo "$temp"
              done
    )

    for rule_num in "${current_cloudflare_rule_numbers[@]}"; do
        # TODO: Add configuration option to confirm deletion.
        yes | ufw delete "$rule_num"
    done
}

####
# Cleanup function to close ports 80 and 443 from any IP address.
cleanup() {
    case $stage in
        2)
            delete_set_cloudflare_rules "1"
            ;;
        3)
            echo "Potential error or interruption detected."
            echo "Restoring the previous Cloudflare IP ranges..."
            restore_current_cloudflare_ip_ranges
            delete_set_cloudflare_rules "1"
            ;;
        4)
            echo "Potential error or interruption detected."
            echo "Restoring the previous Cloudflare IP ranges..."
            delete_new_cloudflare_ip_ranges
            restore_current_cloudflare_ip_ranges
            delete_set_cloudflare_rules "1"
            ;;
        5)
            # Continue, as we are too far along to realistically undo anything
            ;;
        *)
            echo "Invalid stage: $stage"
            ;;
    esac
}


####[ Trapping Logic ]######################################################################


trap 'clean_exit 130' SIGINT
trap 'clean_exit 143' SIGTERM
trap 'clean_exit 129' SIGHUP
trap 'clean_exit 131' SIGQUIT
trap 'clean_exit $?'  EXIT


####[ Prepping ]############################################################################


## Check if the script was executed with root privilege.
if (( EUID != 0 )); then
    echo "${C_ERROR}This script requires root privilege" >&2
    exit 1
fi


####[ Main ]################################################################################


###
### [ Initial Setup ]
###

stage=1

echo "Retrieving current Cloudflare IP rules from UFW..."
while IFS= read -r line; do
    read -ra fields <<< "$line"
    current_cloudflare_ip_ranges+=("${fields[2]}")
done < <(sudo ufw status | grep "Cloudflare IP")
unset fields

echo "Retrieving new Cloudflare IP ranges..."
mapfile -t new_cloudflare_ip_ranges < <(
    curl -s "$C_CLOUDFLARE_IPV4_RANGES_URL"
    curl -s "$C_CLOUDFLARE_IPV6_RANGES_URL"
)

###
### Temporary rule to prevent traffic disruption.
###

stage=2

echo "Temporarily opening ports 80 and 443 from any IP address..."
ufw allow from any to any port 80,443 proto tcp comment "Temporary rule"
sleep 1  # Wait for the rule to take effect.

###
### Remove the existing Cloudflare IP ranges to allow new ones.
###

stage=3

if (( ${#current_cloudflare_ip_ranges[@]} != 0 )); then
    echo "Removing the existing Cloudflare IP ranges..."
    delete_set_cloudflare_rules
fi

sleep 1  # Wait for the rule to take effect.

###
### Add the new Cloudflare IP ranges.
###

stage=4

echo "Adding the new Cloudflare IPv4 and IPv6 ranges..."
set_new_cloudflare_ip_ranges
sleep 1  # Wait for the rule to take effect.

###
### [ Finalizing ]
###

stage=5

echo "Removing temporary rules..."
ufw delete allow from any to any port 80,443 proto tcp
sleep 1  # Wait for the rule to take effect.

echo "Done."
