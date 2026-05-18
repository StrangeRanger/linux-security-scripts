#!/bin/bash
#
# ....
#
# Version: v0.0.1
# License: MIT License
#          Copyright (c) 2025 Hunter T. (StrangeRanger)
#
############################################################################################
####[ Global Variables ]####################################################################


readonly C_GREEN=$'\033[0;32m'
readonly C_BLUE=$'\033[0;34m'
readonly C_CYAN=$'\033[0;36m'
readonly C_RED=$'\033[1;31m'
readonly C_NC=$'\033[0m'

readonly C_ERROR="${C_RED}ERROR:${C_NC} "
readonly C_SUCC="${C_GREEN}==>${C_NC} "
readonly C_INFO="${C_BLUE}==>${C_NC} "
readonly C_NOTE="${C_CYAN}==>${C_NC} "

readonly C_USB_CONF="/etc/modprobe.d/usb-storage.conf"

###
### [ Configurable Variables ]
###

# Whether to completely disable USB storage devices or just blacklist the module.
# Options:
#   "disable"   - Completely disable USB storage devices.
#   "blacklist" - Just blacklist the usb-storage module.
# Default: "disable"
readonly C_USB_DISABLE_METHOD="disable"


####[ Functions ]###########################################################################


is_usb_loaded() {
    if lsmod | grep -i 'usb_storage' &> /dev/null; then
        return 0 # Loaded
    else
        return 1 # Not loaded
    fi
}

# TODO: Modify to check for blacklist as well...
is_usb_disabled() {
    local modprobe_output return_code
    modprobe_output="$(modprobe -n -v usb-storage 2>&1)"  # TODO: Verify 2>&1 is necessary
    return_code=$?

    # Not loadable (disabled via install rule)
    if [[ $modprobe_output =~ ^install[[:space:]]+/bin/(false|true)[[:space:]]*$ ]]; then
        return 1
    fi

    if [[ $return_code -ne 0 && "$modprobe_output" =~ [Nn]ot[[:space:]]+found ]]; then
        return 1
    fi

    return 0  # Loadable
}


####[ Prepping ]############################################################################


if (( EUID != 0 )); then
    echo "${C_ERROR}Please run this script as or with root privilege" >&2
    exit 1
fi

# TODO: Ensure $C_USB_DISABLE_METHOD is valid


####[ Main ]################################################################################


echo -n "${C_NOTE}We will now '$C_USB_DISABLE_METHOD' the usb-storage kernel module. "
read -rp "Press [Enter] to continue."

echo "${C_INFO}Checking if USB devices are already disabled..."

if is_usb_loaded; then
    echo "${C_INFO}USB storage module is currently loaded. Unloading..."
else
    echo "${C_SUCC}USB storage module is not loaded."
fi

if is_usb_disabled; then
    echo "${C_INFO}USB storage module is loadable. Disabling..."
else
    echo "${C_SUCC}USB storage module is already disabled."
fi
