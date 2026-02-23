#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Trap errors
trap 'echo -e "${RED}[ERROR] Script failed at line $LINENO.${NC}" >&2' ERR

# Define packages
packages=(
	# Network
	nmap			# Network scan tool

	# System Tools
	hw-probe 		# Hardware probe tool - look for missing drivers

	# File Management & Utilities
	speedtest-cli 	# Speedtest CLI tool
	curl          	# Transfer data with URLs
	bat           	# Cat command with syntax highlighting
	btop          	# Resource monitor

	# Rest
	gpg      		# encryption software
	tealdeer 		# short and easy manpages alt
	fzf      		# fuzzy finder, used in gl function
	tmux     		# terminal spitter
	eza				# ls replacement
)

echo -e "${YELLOW}Installing packages: ${packages[*]}${NC}"

# Update first
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

# Install each package
for pkg in "${packages[@]}"; do
	echo -e "${GREEN}Installing: $pkg${NC}"
	sudo apt install -y "$pkg"
done

echo -e "${GREEN}All packages installed successfully.${NC}"
