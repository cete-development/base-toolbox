#!/usr/bin/env bash

# =========================  CONFIG & COLORS  =========================
RESET=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)

CONFIG_SOURCE="$HOME/base-toolbox/.config"
CONFIG_TARGET="$HOME/.config"
CURRENT_USER="$(whoami)"

# =========================  FUNCTIONS  =========================
show_help() {
	cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Restores ALL saved configs from:
  $CONFIG_SOURCE
to:
  $CONFIG_TARGET

Only backs up items that will actually be replaced.

Options:
  -h, --help     Show help
  -t, --test     Test flag
EOF
}

ask_confirmation() {
	while true; do
		read -rp "Confirm? [y/n] " yn
		case $yn in
			[Yy]*) return 0 ;;
			[Nn]*) return 1 ;;
			*) echo "Please answer yes or no." ;;
		esac
	done
}

big_print() {
	local color="${1:-$YELLOW}"
	shift
	echo
	echo "${color}################################################################"
	for msg in "$@"; do
		echo "###### $msg"
	done
	echo "################################################################${RESET}"
	echo
}

check_folder() {
	[[ -d "$1" ]] || {
		echo "${RED}Folder not found: $1 ${RESET}"
		exit 1
	}
}

required_packages() {
	command -v rsync &>/dev/null || {
		echo "${RED}rsync is required but not installed.${RESET}"
		exit 1
	}
}

# =========================  MAIN  =========================
main() {

	big_print "$CYAN" "Restoring saved configs"

	check_folder "$CONFIG_SOURCE"

	echo "${GREEN}Make sure you're logged in as the correct user (NOT root).${RESET}"
	ask_confirmation || { echo "${RED}Aborting.${RESET}"; exit 1; }

	# Create backup directory (only used if needed)
	BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
	BACKUP_CREATED=false

	echo "${YELLOW}Checking for configs that will be replaced...${RESET}"

	for item in "$CONFIG_SOURCE"/*; do
		name="$(basename "$item")"
		target_item="$CONFIG_TARGET/$name"

		if [[ -e "$target_item" ]]; then
			if [ "$BACKUP_CREATED" = false ]; then
				echo "${YELLOW}Creating backup directory: $BACKUP_DIR${RESET}"
				mkdir -p "$BACKUP_DIR"
				BACKUP_CREATED=true
			fi

			echo "${YELLOW}Backing up existing: $name${RESET}"
			rsync -a "$target_item" "$BACKUP_DIR/"
		fi
	done

	echo "${GREEN}Applying configs...${RESET}"
	rsync -a --progress "$CONFIG_SOURCE"/ "$CONFIG_TARGET"/

	echo "${GREEN}Fixing ownership...${RESET}"
	chown -R "$CURRENT_USER":"$CURRENT_USER" "$CONFIG_TARGET"

	echo "${GREEN}Restore complete.${RESET}"
	echo "${YELLOW}Log out or reboot for full effect.${RESET}"

	if ask_confirmation; then
		sudo reboot
	else
		echo "${YELLOW}Reboot manually later.${RESET}"
	fi
}

main