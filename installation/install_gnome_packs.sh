#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ask_confirmation() {
	while true; do
		read -p "Confirm? [y/n] " yn
		case $yn in
		[Yy]*) return 0 ;; # Yes, proceed
		[Nn]*) return 1 ;; # No, skip
		*) echo "Please answer yes or no." ;;
		esac
	done
}

# Trap errors
trap 'echo -e "${RED}[ERROR] Script failed at line $LINENO.${NC}" >&2' ERR

# Define packages
packages=(
	ubuntu-restricted-extras # Usefull ubuntu stuff, must have
	# GNOME & Desktop Environment
	gdm-settings                  # GNOME display manager settings
	gnome-bluetooth               # GNOME Bluetooth manager
	gnome-shell-extension-manager # GNOME extension manager
	gnome-software                # Software management
	gnome-software-plugin-flatpak # Flatpak plugin for GNOME Software
	gnome-software-plugin-snap    # Snap plugin for GNOME Software
	gnome-tweaks                  # Customize GNOME settings
	gnome-weather                 # Weather app
)

echo "${GREEN}Confirm you want to install the following packages:${NC}"

for pkg in "${packages[@]}"; do
	echo -e "${YELLOW}$pkg${NC}"
done

if ask_confirmation; then
	echo "${GREEN}Continuing.. ${NC}"
else
	echo "${RED}Aborting script...${NC}"
	sleep 2
	exit 1
fi

echo -e "${YELLOW}Installing packages: ${packages[*]}${NC}"

# Update first
sudo apt update && sudo apt upgrade -y

#Install each package
for pkg in "${packages[@]}"; do
	echo -e "${GREEN}Installing: $pkg${NC}"
	sudo apt install -y "$pkg"
done

echo -e "${GREEN}All packages installed successfully.${NC}"
