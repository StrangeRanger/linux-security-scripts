#!/bin/bash
#
# Sets up UFW to only allow HTTP and HTTPS traffic from Cloudflare's IP ranges.
#
# Version: v1.0.0-beta.2
# License: MIT License
#          Copyright (c) 2024 Hunter T. (StrangeRanger)
#
########################################################################################
####[ Global Variables ]################################################################


## URL for retrieving the current Cloudflare IP ranges.
readonly C_CLOUDFLARE_IPV4_RANGES_URL="https://www.cloudflare.com/ips-v4/"
readonly C_CLOUDFLARE_IPV6_RANGES_URL="https://www.cloudflare.com/ips-v6/"

current_cloudflare_rule_numbers=()
current_cloudflare_ip_ranges=()
new_cloudflare_ip_ranges=()
stage=0


####[ Function ]########################################################################


####
# Check if a UFW rule exists for a specific IP address and port.
#
# PARAMETERS:
#   - $1: ip (Required)
#       - The IP address to check.
#   - $2: port (Required)
#       - The port to check.
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
# Retrieves the rule number of all Cloudflare IP rules currently set in UFW, then
# stores them in an array.
#
# PARAMETERS:
#   - $1: string_to_grep (Required)
#       - The string to grep for in the UFW status output.
#       - Acceptable values:
#           - 0: "Cloudflare IP"
#           - 1: "Temporary rule"
get_set_cloudflare_rule_numbers() {
    if (( $1 == 0 )); then
        local string_to_grep="Cloudflare IP"
    elif (( $1 == 1 )); then
        local string_to_grep="Temporary rule"
    else
        echo "Invalid argument: $1"
        exit 1
    fi

    mapfile -t current_cloudflare_rule_numbers < <(
        ufw status numbered \
            | grep "$string_to_grep" \
            | awk -F'[][]' '{print $2}' \
            | sort -rn
    )
}

####
# Retrieves the IP addresses of all Cloudflare IP rules currently set in UFW, then
# stores them in an array.
get_set_cloudflare_ip_ranges() {
    while IFS= read -r line; do
        ip=$(echo "$line" | awk '{print $3}')  # Extract the IP address.
        current_cloudflare_ip_ranges+=("$ip")
    done < <(sudo ufw status | grep "Cloudflare IP")
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
delete_set_cloudflare_rules() {
    get_set_cloudflare_rule_numbers "0"

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


####[ Trapping Logic ]##################################################################


trap 'clean_exit 130' SIGINT
trap 'clean_exit 143' SIGTERM
trap 'clean_exit 129' SIGHUP
trap 'clean_exit 131' SIGQUIT
trap 'clean_exit $?'  EXIT


####[ Main ]############################################################################


###
### [ Initial Setup ]
###

stage=1

get_set_cloudflare_ip_ranges
mapfile -t new_cloudflare_ip_ranges < <(curl -s "$C_CLOUDFLARE_IPV4_RANGES_URL")
mapfile -t new_cloudflare_ipv6_ranges < <(curl -s "$C_CLOUDFLARE_IPV6_RANGES_URL")

new_cloudflare_ip_ranges+=("${new_cloudflare_ipv6_ranges[@]}")
unset new_cloudflare_ipv6_ranges

###
### [ Opening ports 80 and 443 from any IP address ]
###

stage=2

echo "Temporarily opening ports 80 and 443 from any IP address..."
ufw allow from any to any port 80,443 proto tcp comment "Temporary rule"
sleep 1  # Wait for the rule to take effect.

###
### [ Removing the existing Cloudflare IP ranges ]
###

stage=3

if (( ${#current_cloudflare_ip_ranges[@]} != 0 )); then
    echo "Removing the existing Cloudflare IP ranges..."
    delete_set_cloudflare_rules
fi

sleep 1  # Wait for the rule to take effect.

###
### [ Adding the new Cloudflare IP ranges ]
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

