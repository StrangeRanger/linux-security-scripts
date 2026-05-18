#!/bin/bash
#
# This script downloads a security auditing tool called Lynis. It is designed to scan a
# system, identify security issues, and provide recommendations on how to better secure
# it. Unless an error is encountered, Lynis will always be downloaded to the current
# user's root directory (`/home/USERNAME/`).
#
# Version: v1.0.9
# License: MIT License
#          Copyright (c) 2020-2025 Hunter T. (StrangeRanger)
#
########################################################################################


readonly C_YELLOW=$'\033[1;33m'
readonly C_GREEN=$'\033[0;32m'
readonly C_BLUE=$'\033[0;34m'
readonly C_CYAN=$'\033[0;36m'
readonly C_RED=$'\033[1;31m'
readonly C_NC=$'\033[0m'

readonly C_ERROR="${C_RED}ERROR:${C_NC} "
readonly C_SUCC="${C_GREEN}==>${C_NC} "
readonly C_WARN="${C_YELLOW}==>${C_NC} "
readonly C_INFO="${C_BLUE}==>${C_NC} "
readonly C_NOTE="${C_CYAN}==>${C_NC} "


read -rp "${C_NOTE}We will now download lynis. Press [Enter] to continue."

if [[ -d "$HOME/lynis" ]]; then
    echo "${C_WARN}Lynis is already downloaded to your system" >&2
    echo "${C_NOTE}  Current location: '$HOME/lynis'"
    echo -e "\n${C_INFO}Exiting..."
    exit 0
fi

echo "${C_INFO}Changing working directory to '$HOME'..."
cd "$HOME" || {
    echo "${C_ERROR}Failed to change working directory to '$HOME'" >&2
    echo "${C_CYAN}Lynis will download to '$PWD'${C_NC}"
}

echo "${C_INFO}Downloading lynis..."
git clone https://github.com/CISOfy/lynis || {
    echo "${C_ERROR}Failed to download lynis" >&2
    echo -e "\n${C_INFO}Exiting..."
    exit 1
}

echo -e "\n${C_SUCC}Lynis has been downloaded to your system"
echo "${C_NOTE}To perform a system scan with lynis, execute the following command" \
    "in the lynis root directory: sudo ./lynis audit system"
