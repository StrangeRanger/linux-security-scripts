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


C_TMP_DIR=$(mktemp -d)
C_UFW_BACKUP_ARCHIVE="$C_TMP_DIR/ufw-backup-$(date +%F).tar.gz"
readonly C_TMP_DIR C_UFW_BACKUP_ARCHIVE
readonly C_CLOUDFLARE_UFW_COMMENT="Cloudflare IP"

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
# Cleanly exit the script by removing temporary files, restoring backups if needed, and
# displaying a message based on the exit code.
#
# PARAMETERS:
#   - $1: exit_code (Required)
clean_exit() {
    local exit_code="$1"

    case "$exit_code" in
        0|1) echo "" ;;
        129) echo -e "\n\nHangup signal detected (SIGHUP)" ;;
        130) echo -e "\n\nUser interrupt detected (SIGINT)" ;;
        143) echo -e "\n\nTermination signal detected (SIGTERM)" ;;
        *)   echo -e "\n\nExiting with code: $exit_code" ;;
    esac

    case $stage in
        2|3|4)
            echo "Interrupt occurred during stage '$stage', resulting in incomplete changes"
            echo "Temporarily disabling UFW..."
            ufw disable
            echo "Restoring previous UFW rules..."
            sudo tar -C /etc -xf "$C_UFW_BACKUP_ARCHIVE"
            echo "Re-enabling UFW..."
            ufw enable
            echo "Displaying current UFW status..."
            echo "---"
            ufw status verbose
            echo "---"
            ;;
    esac
}


####[ Trapping Logic ]######################################################################


trap 'clean_exit 129' SIGHUP
trap 'clean_exit 130' SIGINT
trap 'clean_exit 143' SIGTERM


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

echo "Creating UFW backup archive at: $C_UFW_BACKUP_ARCHIVE"
tar -C /etc -cf "$C_UFW_BACKUP_ARCHIVE" ufw

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

    mapfile -t current_cloudflare_rule_numbers < <(
        ufw status numbered \
            | grep -E "^\[ *[0-9]+\].*$C_CLOUDFLARE_UFW_COMMENT" \
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
fi

unset current_cloudflare_rule_numbers
sleep 1  # Wait for the changes to take effect.

###
### Add the new Cloudflare IP ranges.
###

stage=4

echo "Adding the new Cloudflare IPv4 and IPv6 ranges..."
for ip in "${new_cloudflare_ip_ranges[@]}"; do
    ufw_rule_exists "$ip" "80,443" \
        || ufw allow from "$ip" to any port 80,443 proto tcp comment "Cloudflare IP"
done

sleep 1  # Wait for the changes to take effect.

###
### [ Finalizing ]
###

stage=5

echo "Removing temporary rules..."
ufw delete allow from any to any port 80,443 proto tcp
sleep 1  # Wait for the changes to take effect.

echo "Done."
clean_exit 0
