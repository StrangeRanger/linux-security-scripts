#!/bin/bash
#
# Set up UFW to only allow HTTP and HTTPS traffic from Cloudflare's IP ranges.
#
# Version: v1.0.3
# License: MIT License
#          Copyright (c) 2024-2026 Hunter T. (StrangeRanger)
#
############################################################################################
set -euo pipefail
####[ Global Variables ]####################################################################


C_TMP_DIR=$(mktemp -d)
C_UFW_BACKUP_ARCHIVE="$C_TMP_DIR/ufw-backup-$(date +%F).tar.gz"
readonly C_TMP_DIR C_UFW_BACKUP_ARCHIVE
readonly C_CLOUDFLARE_UFW_COMMENT="Cloudflare IP"
readonly C_SLEEP_TIME=1

readonly C_CLOUDFLARE_IPV4_RANGES_URL="https://www.cloudflare.com/ips-v4/"
readonly C_CLOUDFLARE_IPV6_RANGES_URL="https://www.cloudflare.com/ips-v6/"

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

current_cloudflare_rule_numbers=()
current_cloudflare_ip_ranges=()
new_cloudflare_ip_ranges=()
modifications_in_progress=false


####[ Function ]############################################################################


####
# Remove temporary files, restore backups if needed, and display a message based on the exit
# code.
clean_exit() {
    local exit_code="$1"

    case "$exit_code" in
        0|1) echo "" ;;
        129) echo -e "\n\n${C_WARN}Hangup signal detected (SIGHUP)" ;;
        130) echo -e "\n\n${C_WARN}User interrupt detected (SIGINT)" ;;
        143) echo -e "\n\n${C_WARN}Termination signal detected (SIGTERM)" ;;
        *)   echo -e "\n\n${C_WARN}Exiting with code: $exit_code" ;;
    esac

    # Check if we need to restore the original configurations.
    if [[ $modifications_in_progress == true ]]; then
        echo "${C_INFO}Temporarily disabling UFW..."
        ufw disable

        echo "${C_INFO}Restoring previous UFW rules..."
        tar -C /etc -xzf "$C_UFW_BACKUP_ARCHIVE"

        echo "${C_INFO}Re-enabling UFW..."
        ufw enable

        echo "${C_INFO}Displaying current UFW status..."
        echo "---"
        ufw status verbose
        echo "---"
    fi

    if [[ -d "$C_TMP_DIR" ]]; then
        echo "${C_INFO}Cleaning up..."
        rm -rf "$C_TMP_DIR"
    fi

    echo "${C_INFO}Exiting..."
    exit "$exit_code"
}

# shellcheck disable=SC2329
on_err() {
    local exit_code=$?

    echo "${C_ERROR}Command failed at line ${BASH_LINENO[0]}: ${BASH_COMMAND}" >&2
    clean_exit "$exit_code"
}


####[ Trapping Logic ]######################################################################


trap 'clean_exit 129' SIGHUP
trap 'clean_exit 130' SIGINT
trap 'clean_exit 143' SIGTERM
trap 'on_err' ERR


####[ Prepping ]############################################################################


if (( EUID != 0 )); then
    echo "${C_ERROR}This script requires root privilege" >&2
    exit 1
fi


####[ Main ]################################################################################


read -rp "${C_NOTE}We will now configure Cloudflare UFW rules. Press [Enter] to continue."

echo "${C_INFO}Checking UFW status..."
if ! ufw status | grep -q '^Status: active$'; then
    echo "${C_ERROR}UFW is not active"
    clean_exit 1
fi

###
### [ Initial Setup ]
###

echo "${C_INFO}Retrieving current Cloudflare IP rules from UFW..."
while IFS= read -r line; do
    read -ra fields <<< "$line"
    current_cloudflare_ip_ranges+=("${fields[2]}")
done < <(ufw status | grep "$C_CLOUDFLARE_UFW_COMMENT")
unset fields

echo "${C_INFO}Retrieving new Cloudflare IP ranges..."
mapfile -t new_cloudflare_ip_ranges < <(
    curl -s "$C_CLOUDFLARE_IPV4_RANGES_URL"
    echo ""  # Will prevent the last IPv4 and first IPv6 address from being merged.
    curl -s "$C_CLOUDFLARE_IPV6_RANGES_URL"
)

echo "${C_INFO}Creating UFW backup archive at: $C_UFW_BACKUP_ARCHIVE"
tar -C /etc -czf "$C_UFW_BACKUP_ARCHIVE" ufw

###
### Add temporary rule to prevent traffic disruption.
###

modifications_in_progress=true

echo "${C_INFO}Temporarily opening ports 80 and 443 from any IP address..."
if ! ufw allow from any to any port 80,443 proto tcp comment "Temporary rule"; then
    echo "${C_ERROR}Failed to add temporary rule" >&2
    clean_exit 1
fi

echo "${C_NOTE}Waiting '$C_SLEEP_TIME' second for changes to take effect..."
sleep "$C_SLEEP_TIME"

###
### Remove the existing Cloudflare IP ranges to allow new ones.
###

if (( ${#current_cloudflare_ip_ranges[@]} != 0 )); then
    echo "${C_INFO}Removing the existing Cloudflare IP ranges..."

    mapfile -t current_cloudflare_rule_numbers < <(
        ufw status numbered \
            | grep -E "^\[ *[0-9]+\].*$C_CLOUDFLARE_UFW_COMMENT" \
            | while IFS= read -r line; do
                ## Extract the number between brackets (handles both [1] and [ 1] formats).
                temp="${line#*[}"
                temp="${temp%%]*}"
                ## Remove any leading/trailing whitespace.
                temp="${temp#"${temp%%[![:space:]]*}"}"
                temp="${temp%"${temp##*[![:space:]]}"}"
                echo "$temp"
              done \
            | sort -rn
    )

    for rule_num in "${current_cloudflare_rule_numbers[@]}"; do
        echo "y" | ufw delete "$rule_num"
    done

    echo "${C_NOTE}Waiting '$C_SLEEP_TIME' second for changes to take effect..."
    sleep "$C_SLEEP_TIME"
fi

unset current_cloudflare_rule_numbers

###
### Add the new Cloudflare IP ranges.
###

echo "${C_INFO}Adding the new Cloudflare IPv4 and IPv6 ranges..."
for ip in "${new_cloudflare_ip_ranges[@]}"; do
    echo "${C_INFO}  Adding rule for '$ip'..."
    if ! ufw allow from "$ip" to any port 80,443 proto tcp comment \
        "$C_CLOUDFLARE_UFW_COMMENT" >/dev/null
    then
        echo "${C_ERROR}Failed to add rule for '$ip'" >&2
    fi
done

echo "${C_NOTE}Waiting '$C_SLEEP_TIME' second for changes to take effect..."
sleep "$C_SLEEP_TIME"

###
### Perform the last modifications to UFW.
###

echo "${C_INFO}Removing temporary rules..."
if ! ufw delete allow from any to any port 80,443 proto tcp comment "Temporary rule"; then
    echo "${C_ERROR}Failed to remove temporary rule" >&2
    echo "${C_NOTE}Please check your UFW configuration and remove it manually"
fi

modifications_in_progress=false

echo "${C_NOTE}Waiting '$C_SLEEP_TIME' second for changes to take effect..."
sleep "$C_SLEEP_TIME"
echo "${C_SUCC}Finished setting up UFW with Cloudflare IP ranges"
clean_exit 0
