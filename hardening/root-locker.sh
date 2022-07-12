#!/bin/bash
#
# Locks the root account and erases it's current password.
#
# Version: v1.0.5
# License: MIT License
#          Copyright (c) 2020-2022 Hunter T. (StrangeRanger)
#
########################################################################################
#### [ Variables ]


green="$(printf '\033[0;32m')"
red="$(printf '\033[1;31m')"
nc="$(printf '\033[0m')"


##### End of [ Variables ]
########################################################################################
#### [ Prepping ]


## Check if this script was executed with root privilege.
if [[ $EUID != 0 ]]; then
    echo "${red}Please run this script as or with root privilege${nc}" >&2
    echo -e "\nExiting..."
    exit 2
fi


#### End of [ Prepping ]
########################################################################################
#### [ Main ]


read -rp "We will now disable the root account. Press [Enter] to continue."

echo "Disabling root account..."
passwd -dl root || {
    echo -e "\n${red}Failed to lock the root account${nc}"
    exit 1
}

echo -e "\n${green}The root account has been locked${nc}"


#### End of [ Main ]
########################################################################################
