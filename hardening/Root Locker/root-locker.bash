#!/bin/bash
#
# This script locks the root account, preventing users from directly logging in as root.
#
# NOTE:
#   Locking the root account doesn't prevent users from using something like `sudo su`
#   to gain root access.
#
# Version: v1.0.10
# License: MIT License
#          Copyright (c) 2020-2025 Hunter T. (StrangeRanger)
#
########################################################################################


readonly C_GREEN=$'\033[0;32m'
readonly C_BLUE=$'\033[0;34m'
readonly C_CYAN=$'\033[0;36m'
readonly C_RED=$'\033[1;31m'
readonly C_NC=$'\033[0m'

readonly C_ERROR="${C_RED}ERROR:${C_NC} "
readonly C_SUCC="${C_GREEN}==>${C_NC} "
readonly C_INFO="${C_BLUE}==>${C_NC} "
readonly C_NOTE="${C_CYAN}==>${C_NC} "


if (( EUID != 0 )); then
    echo "${C_ERROR}Please run this script as or with root privilege" >&2
    exit 1
fi


read -rp "${C_NOTE}We will now disable the root account. Press [Enter] to continue."

echo "${C_INFO}Disabling root account..."
usermod -L root || {
    echo -e "${C_ERROR}Failed to lock the root account" >&2
    exit 1
}

echo -e "\n${C_SUCC}The root account has been locked"
