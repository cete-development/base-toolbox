#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display help message
display_help() {
    echo -e "${BLUE}Usage:${NC} $0 [OPTION]"
    echo
    echo -e "${BLUE}List installed packages on the system.${NC}"
    echo
    echo -e "${GREEN}Options:${NC}"
    echo -e "  ${YELLOW}user${NC}      List user-installed packages."
    echo -e "  ${YELLOW}system${NC}    List system-installed packages."
    echo -e "  ${YELLOW}-h, --help${NC}    Display this help message."
    echo
    read -p "press any key to continue.."
    exit 1
}

# Function to list user-installed packages (Debian/Ubuntu)
list_user_packages() {
    if [ -x "$(command -v apt-mark)" ]; then
        echo -e "${GREEN}Listing user-installed packages (Debian/Ubuntu):${NC}"
        apt-mark showmanual
    elif [ -x "$(command -v rpm)" ]; then
        echo -e "${GREEN}Listing user-installed packages (RedHat/CentOS/Fedora):${NC}"
        rpm -qa --qf '%{NAME}\n' | while read pkg; do
            if rpm -qi $pkg | grep -q "User installed"; then
                echo -e "${YELLOW}$pkg${NC}"
            fi
        done
    else
        echo -e "${RED}Unsupported package manager detected.${NC}"
        exit 1
    fi
}

# Function to list system-installed packages (Debian/Ubuntu)
list_system_packages() {
    if [ -x "$(command -v apt-mark)" ]; then
        echo -e "${GREEN}Listing system-installed packages (Debian/Ubuntu):${NC}"
        apt-mark showauto
    elif [ -x "$(command -v rpm)" ]; then
        echo -e "${GREEN}Listing system-installed packages (RedHat/CentOS/Fedora):${NC}"
        rpm -qa --qf '%{NAME}\n' | while read pkg; do
            if ! rpm -qi $pkg | grep -q "User installed"; then
                echo -e "${YELLOW}$pkg${NC}"
            fi
        done
    else
        echo -e "${RED}Unsupported package manager detected.${NC}"
        exit 1
    fi
}

# Main function to handle the argument
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    display_help
elif [ "$1" == "user" ]; then
    list_user_packages
elif [ "$1" == "system" ]; then
    list_system_packages
else
    echo -e "${RED}Invalid option. Use -h or --help for usage information.${NC}"
    exit 1
fi


