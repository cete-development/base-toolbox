#!/bin/bash

set -e

# Color setup
RED='\033[0;31m'
GRN='\033[0;32m'
YEL='\033[1;33m'
BLU='\033[1;34m'
NC='\033[0m' # No Color

# Ensure dependencies exist
for cmd in gpg tar shred; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Error:${NC} Required tool '$cmd' is not installed."
        read -p "Press any key to exit..."  # Wait before exiting
        exit 1
    fi
done

# Ensure the argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error:${NC} No argument provided."
    read -p "Press any key to exit..."  # Wait before exiting
    exit 1
fi

path="$1"

# Check if it's a folder or .gpg file
if [[ -d "$path" ]]; then
    action="e"
    folder="$path"
elif [[ -f "$path" && "$path" =~ \.gpg$ ]]; then
    action="d"
    encrypted_file="$path"
else
    echo -e "${RED}Error:${NC} Invalid argument. Please provide a folder to encrypt or a .gpg file to decrypt."
    read -p "Press any key to exit..."  # Wait before exiting
    exit 1
fi

# Securely shred a folder by shredding all files inside it
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

if [[ "$action" == "e" ]]; then
    if [[ ! -d "$folder" ]]; then
        echo -e "${RED}Error:${NC} Folder not found."
        read -p "Press any key to exit..."  # Wait before exiting
        exit 1
    fi

    archive="${folder%/}.tar.gz"
    encrypted="${archive}.gpg"

    echo -e "${GRN}Compressing folder...${NC}"
    tar -czf "$archive" "$folder"

    echo -e "${GRN}Encrypting with AES-256...${NC}"
    gpg --cipher-algo AES256 -c "$archive"

    echo -e "${GRN}Encrypted file created:${NC} $encrypted"

    shred -u "$archive"

    read -rp "$(echo -e "${YEL}Do you want to shred the original folder? (y/n): ${NC}")" shred_choice
    if [[ "$shred_choice" == "y" ]]; then
        echo -e "${YEL}Shredding files...${NC}"
        securely_shred_folder "$folder"
        echo -e "${GRN}Originals securely removed.${NC}"
    fi

elif [[ "$action" == "d" ]]; then
    if [[ ! -f "$encrypted_file" ]]; then
        echo -e "${RED}Error:${NC} Encrypted file not found."
        read -p "Press any key to exit..."  # Wait before exiting
        exit 1
    fi

    archive="${encrypted_file%.gpg}"
    echo -e "${GRN}Decrypting...${NC}"
    gpg -o "$archive" -d "$encrypted_file"
    
    echo -e "${GRN}Decompressing...${NC}"
    tar -xzf "$archive"

    folder="${archive%.tar.gz}"
    echo -e "${GRN}Decrypted and extracted folder:${NC} $folder"
    shred -u "$archive"

else
    echo -e "${RED}Error:${NC} Invalid action. Something went wrong."
    read -p "Press any key to exit..."  # Wait before exiting
    exit 1
fi

