#!/bin/bash
#
# This script locks the root account, preventing users from directly logging in as root.
#
# Note:
#   Locking the root account doesn't prevent users from using something like `sudo su`
#   to gain root access.
#
# Version: v1.0.7
# License: MIT License
#          Copyright (c) 2020-2024 Hunter T. (StrangeRanger)
#
########################################################################################

C_GREEN="$(printf '\033[0;32m')"
C_RED="$(printf '\033[1;31m')"
C_NC="$(printf '\033[0m')"


## Check if this script was executed with root privilege.
if [[ $EUID != 0 ]]; then
    echo "${C_RED}Please run this script as or with root privilege${C_NC}" >&2
    echo -e "\nExiting..."
    exit 1
fi


read -rp "We will now disable the root account. Press [Enter] to continue."

echo "Disabling root account..."
usermod -L root || {
    echo -e "${C_RED}ERROR:${C_NC} Failed to lock the root account" >&2
    echo -e "\nExiting..."
    exit 1
}

echo -e "\n${C_GREEN}The root account has been locked${C_NC}"
