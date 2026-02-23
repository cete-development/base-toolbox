#!/bin/bash

set -e

# Color setup
RED='\033[0;31m'
GRN='\033[0;32m'
YEL='\033[1;33m'
BLU='\033[1;34m'
NC='\033[0m' # No Color

if ! command -v shred &> /dev/null; then
    echo -e "${RED}Error:${NC} Required tool shred is not installed."
    read -p "Press any key to exit..."  # Wait before exiting
    exit 1
fi

# Ensure the argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error:${NC} No argument provided."
    read -p "Press any key to exit..."  # Wait before exiting
    exit 1
fi

securely_shred_folder() {
    target_dir="$1"

    # Basic safety checks to avoid disasters
    if [[ -z "$target_dir" || "$target_dir" == "/" || "$target_dir" == "$HOME" || "$target_dir" == "." ]]; then
        echo -e "${RED}Refusing to shred suspicious or dangerous target: '$target_dir'${NC}"
        return 1
    fi

    if [[ ! -d "$target_dir" ]]; then
        echo -e "${RED}Error:${NC} '$target_dir' is not a valid directory."
        return 1
    fi

    echo -e "${YEL}Shredding folder contents in: ${target_dir}${NC}"

    # Shred regular files (excluding symlinks)
    find "$target_dir" -type f ! -lname '*' -exec shred -u {} \; 2>/dev/null

    # Final safety check
    if [[ -d "$target_dir" ]]; then
        rm -rf "$target_dir"
    fi

    if [[ ! -e "$target_dir" ]]; then
        echo -e "${GRN}Folder securely shredded and removed: ${target_dir}${NC}"
    else
        echo -e "${RED}Warning:${NC} Some parts of the folder couldn't be removed. Check permissions."
    fi
}

securely_shred_folder "$1"
