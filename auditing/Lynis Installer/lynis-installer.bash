#!/bin/bash
#
# This script downloads a security auditing tool called Lynis. It is designed to scan a
# system, identify security issues, and provide recommendations on how to better secure
# it. Unless an error is encountered, Lynis will always be downloaded to the current
# user's root directory (`/home/USERNAME/`).
#
# Version: v1.0.8
# License: MIT License
#          Copyright (c) 2020-2024 Hunter T. (StrangeRanger)
#
########################################################################################

C_YELLOW="$(printf '\033[1;33m')"
C_GREEN="$(printf '\033[0;32m')"
C_BLUE="$(printf '\033[0;34m')"
C_CYAN="$(printf '\033[0;36m')"
C_RED="$(printf '\033[1;31m')"
C_NC="$(printf '\033[0m')"

C_SUCCESS="${C_GREEN}==>${C_NC} "
C_ERROR="${C_RED}ERROR:${C_NC} "
C_WARNING="${C_YELLOW}==>${C_NC} "
C_INFO="${C_BLUE}==>${C_NC} "
C_NOTE="${C_CYAN}==>${C_NC} "


read -rp "${C_NOTE}We will now download lynis. Press [Enter] to continue."

if [[ -d "$HOME/lynis" ]]; then
    echo "${C_WARNING}Lynis is already downloaded to your system" >&2
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

echo -e "\n${C_SUCCESS}Lynis has been downloaded to your system"
echo -e "${C_NOTE}To perform a system scan with lynis, execute the following command" \
    "in the lynis root directory: sudo ./lynis audit system"
