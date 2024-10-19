#!/bin/bash
#
# This script hardens the ssh server by modifying its configuration file, 'sshd_config'.
#
# Note:
#   These configurations align with the recommendations of the security auditing tool
#   known as Lynis (https://github.com/CISOfy/lynis).
#
# Version: v2.0.0
# License: MIT License
#          Copyright (c) 2020-2024 Hunter T. (StrangeRanger)
#
########################################################################################
####[ Global Variables ]################################################################


readonly C_CONFIG_FILE_BAK="/etc/ssh/sshd_config.bak"
readonly C_CONFIG_FILE="/etc/ssh/sshd_config"

## Used to colorize output.
C_YELLOW="$(printf '\033[1;33m')"
C_GREEN="$(printf '\033[0;32m')"
C_BLUE="$(printf '\033[0;34m')"
C_CYAN="$(printf '\033[0;36m')"
C_RED="$(printf '\033[1;31m')"
C_NC="$(printf '\033[0m')"
readonly C_GREEN C_CYAN C_RED C_NC

## Short-hand colorized messages.
readonly C_SUCCESS="${C_GREEN}==>${C_NC} "
readonly C_WARNING="${C_YELLOW}==>${C_NC} "
readonly C_ERROR="${C_RED}ERROR:${C_NC} "
readonly C_INFO="${C_BLUE}==>${C_NC} "
readonly C_NOTE="${C_CYAN}==>${C_NC} "

# Associative array containing the configuration settings for sshd_config.
declare -A C_SSHD_CONFIG=(
    ["LogLevel"]="VERBOSE"
    ["LogLevelRegex"]='^#?LogLevel\s+.*$'
    ["LoginGraceTime"]="30"
    ["LoginGraceTimeRegex"]='^#?LoginGraceTime\s+.*$'
    ["PermitRootLogin"]="no"
    ["PermitRootLoginRegex"]='^#?PermitRootLogin\s+.*$'
    ["MaxAuthTries"]="3"
    ["MaxAuthTriesRegex"]='^#?MaxAuthTries\s+.*$'
    ["MaxSessions"]="2"
    ["MaxSessionsRegex"]='^#?MaxSessions\s+.*$'
    ["PubkeyAuthentication"]="yes"
    ["PubkeyAuthenticationRegex"]='^#?PubkeyAuthentication\s+.*$'
    ["PermitEmptyPasswords"]="no"
    ["PermitEmptyPasswordsRegex"]='^#?PermitEmptyPasswords\s+.*$'
    ["ChallengeResponseAuthentication"]="no"
    ["ChallengeResponseAuthenticationRegex"]='^#?ChallengeResponseAuthentication\s+.*$'
    ["KbdInteractiveAuthentication"]="no"
    ["KbdInteractiveAuthenticationRegex"]='^#?KbdInteractiveAuthentication\s+.*$'
    ["UsePAM"]="yes"
    ["UsePAMRegex"]='^#?UsePAM\s+.*$'
    ["AllowAgentForwarding"]="no"
    ["AllowAgentForwardingRegex"]='^#?AllowAgentForwarding\s+.*$'
    ["AllowTcpForwarding"]="no"
    ["AllowTcpForwardingRegex"]='^#?AllowTcpForwarding\s+.*$'
    ["X11Forwarding"]="no"
    ["X11ForwardingRegex"]='^#?X11Forwarding\s+.*$'
    ["PrintMotd"]="no"
    ["PrintMotdRegex"]='^#?PrintMotd\s+.*$'
    ["TCPKeepAlive"]="no"
    ["TCPKeepAliveRegex"]='^#?TCPKeepAlive\s+.*$'
    ["Compression"]="no"
    ["CompressionRegex"]='^#?Compression\s+.*$'
    ["ClientAliveInterval"]="300"
    ["ClientAliveIntervalRegex"]='^#?ClientAliveInterval\s+.*$'
    ["ClientAliveCountMax"]="2"
    ["ClientAliveCountMaxRegex"]='^#?ClientAliveCountMax\s+.*$'
)
readonly C_SSHD_CONFIG


####[ Functions ]#######################################################################


####
# Cleanly exit the script.
#
# PARAMETERS:
#   - $1: exit_code (Required)
#       - The exit code to exit the script with.
clean_exit() {
    local exit_code="$1"

    case "$exit_code" in
        0)   exit 0 ;;
        1)   echo "" ;;
        130) echo -e "\n${C_WARNING}User interrupt detected" ;;
        *)   echo -e "\n${C_RED}==>${C_NC} Exiting with code: $exit_code" ;;
    esac

    echo -e "${C_INFO}Exiting..."
    exit "$exit_code"
}


####[ Trapping Logic ]##################################################################


# Catch some of the most common signals.
trap 'clean_exit $?' EXIT INT TERM HUP QUIT ERR


####[ Prepping ]########################################################################


## Check if the script was executed with root privilege.
if [[ $EUID != 0 ]]; then
    echo "${C_ERROR}This script requires root privilege" >&2
    exit 1
fi

## Confirm that 'sshd_config' exists.
if [[ ! -f $C_CONFIG_FILE ]]; then
    echo "${C_WARNING}'sshd_config' doesn't exist" >&2
    echo "${C_NOTE}openssh-server may not be installed"
    exit 1
fi


####[ Main ]############################################################################


read -rp "${C_NOTE}We will now harden sshd. Press [Enter] to continue."

###
### [ Backup 'sshd_config' ]
###

if [[ -f $C_CONFIG_FILE_BAK ]]; then
    printf "%sA backup of 'sshd_config' already exists. " "$C_NOTE"
    read -rp "Do you want to overwrite it? [y/N] " choice
    choice="${choice,,}"

    case "$choice" in
        y*)
            echo "${C_INFO}Overwriting backup of 'sshd_config'..."
            {
                rm $C_CONFIG_FILE_BAK && cp $C_CONFIG_FILE $C_CONFIG_FILE_BAK
            } || {
                echo "${C_ERROR}Failed to overwrite backup of 'sshd_config'" >&2
                exit 1
            }
            ;;
        *)
            echo "${C_INFO}Skipping backup of 'sshd_config'..."
            ;;
    esac

    unset choice
else
    echo "${C_INFO}Backing up 'sshd_config'..."
    cp $C_CONFIG_FILE $C_CONFIG_FILE_BAK || {
        echo "${C_ERROR}Failed to back up sshd_config" >&2
        echo "${C_NOTE}Please create a backup of the original 'sshd_config' before" \
            "continuing"
        exit 1
    }
fi

###
### [ Harden 'sshd_config' ]
###

for key in "${!C_SSHD_CONFIG[@]}"; do
    # Skip processing Regex keys directly.
    if [[ "$key" =~ Regex$ ]]; then
        continue
    fi

    regex_key="${key}Regex"
    sed_regex="0,/${C_SSHD_CONFIG[$regex_key]}/s/${C_SSHD_CONFIG[$regex_key]}/${key} ${C_SSHD_CONFIG[$key]}/"
    echo "${C_INFO}Checking '${key}'..."

    ## Check if the key is already set to the desired value.
    if grep -Eq "^${key} ${C_SSHD_CONFIG[$key]}$" "$C_CONFIG_FILE"; then
        echo "${C_SUCCESS}${key} already set to '${C_SSHD_CONFIG[$key]}'"
    ## Check if the configurations are present in the file.
    elif grep -Eq "${C_SSHD_CONFIG[$regex_key]}" "$C_CONFIG_FILE"; then
        echo "${C_INFO}Setting '${key} ${C_SSHD_CONFIG[$key]}'..."
        sed -Ei "$sed_regex" "$C_CONFIG_FILE" \
            || echo "${C_ERROR}Failed to set '${key} ${C_SSHD_CONFIG[$key]}'" >&2
    ## If the configuration is not present in the file.
    else
        echo "${C_WARNING}'${key}' not found in configuration file" >&2
    fi
done

###
### [ Finalizing ]
###

echo -e "\n${C_INFO}Restarting sshd..."
systemctl restart sshd || {
    echo "${C_ERROR}Failed to restart sshd" >&2
    exit 1
}

echo -e "\n${C_SUCCESS}Finished hardening sshd"
echo -e "${C_NOTE}It is highly recommended to manually:"
echo -e "${C_NOTE}  1) Change the default sshd port (22)"
echo -e "${C_NOTE}  2) Disable PasswordAuthentication in favor of PubkeyAuthentication"
echo -e "${C_NOTE}  3) Add 'AllowUsers [your username]' to the bottom of 'sshd_config'"

