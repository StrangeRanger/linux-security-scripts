#!/bin/bash

################################################################################
#
# Lynis Installer
# ---------------
# A script for installing and running lynis with recommended options
#
# Version: v1.0.0
# License: MIT License
#   Copyright (c) 2020 Hunter T.
#
################################################################################
#
    cyan=$'\033[0;36m'
    red=$'\033[1;31m'
    nc=$'\033[0m'

    # Checks to see if this script was executed with root privilege
    if ((EUID == 0)); then 
        echo "${red}Do not run this script as root or with root privilege${nc}" >&2
        echo -e "\nExiting..."
        exit 1
    fi

    echo "Changing working directory to ~/${USER_SUDO}..."
    cd /home/"$SUDO_USER" || {
        echo "${red}Failed to change working directory to ~/${SUDO_USER}"
        echo "${cyan}Lynis will download to ${PWD}${nc}"
    }

    echo "Downloading lynis..."
    git clone https://github.com/CISOfy/lynis
    echo "Changing ownership of lynis to root:root..."
    chown -R root:root lynis
    echo -e "${cyan}To peform a system scan with lynis, execute the following" \
        "command in the lynis root directory: sudo ./lynis audit system"
