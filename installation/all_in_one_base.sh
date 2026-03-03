#!/usr/bin/env bash

# =========================  CONFIG & COLORS  =========================
RESET=$(tput sgr0)
RED=$(tput setaf 1)     # echo "${RED}PLACEHOLDER ${RESET}"
GREEN=$(tput setaf 2)   # echo "${GREEN}PLACEHOLDER ${RESET}"
YELLOW=$(tput setaf 3)  # echo "${YELLOW}PLACEHOLDER ${RESET}"
BLUE=$(tput setaf 4)    # echo "${BLUE}PLACEHOLDER ${RESET}"
MAGENTA=$(tput setaf 5) # echo "${MAGENTA}PLACEHOLDER ${RESET}"
CYAN=$(tput setaf 6)    # echo "${CYAN}PLACEHOLDER ${RESET}"
WHITE=$(tput setaf 7)   # echo "${WHITE}PLACEHOLDER ${RESET}"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# USE: example_file="$DIR/filename"

# =========================  SCRIPT-FUNCTIONS  =========================
# Help message
show_help() {
	cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Functionality:
    Script to install all basic necessities for any system.
    
Options:
  -h, --help     Show this help message and exit
  -t, --test     test flag functionality

Example:
  $(basename "$0") --help
EOF
}

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

# Print banner-like messages
# ex:   big_print "$YELLOW" "Starting setup..." "Package installed" "Cleaning up"
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

required_packages() {
	local pkgs=("$@")
	[ ${#pkgs[@]} -eq 0 ] && return

	for pkg in "${pkgs[@]}"; do
		if ! dpkg -s "$pkg" &>/dev/null && ! command -v "$pkg" &>/dev/null; then
			echo "Missing required package or command: $pkg"
			exit 1
		fi
	done
}

# Use these like this: check_file "path/to/file.sh" && rest_of_command.sh "path/to/file.sh"
check_file() { [[ -f "$1" ]] && echo "${GREEN}File exists. ${RESET}" || {
	echo "${RED}File not found. ${RESET}"
	return 1
}; }
check_folder() { [[ -d "$1" ]] && echo "${GREEN}Folder exists ${RESET}" || {
	echo "${RED}Folder not found. ${RESET}"
	return 1
}; }

# =========================  USER-FUNCTIONS  =========================

process_files() {
	local file_matrix=("$@") # take all arguments
	local total=${#file_matrix[@]}

	for ((i = 0; i < total; i += 3)); do
		local fname="$DIR/${file_matrix[i]}"
		local color="${file_matrix[i + 1]}"
		local desc="${file_matrix[i + 2]}"

		big_print "$color" "$desc"

		if [[ "$fname" == *.bash ]]; then
			echo "Special handling for .bash file: $fname"
			check_file "$fname" && bash "$fname"
		else
			check_file "$fname" && . "$fname"
		fi
	done
}

# =========================  ARGUMENTS  =========================

# Make sure at least one argument is given.
ARGUMENT_REQUIRED=false
if $ARGUMENT_REQUIRED && [ $# -lt 1 ]; then
	echo "Error: No arguments provided."
	show_help
	exit 1
fi

# Parse flags
while [[ $# -gt 0 ]]; do
	case "$1" in
	-h | --help)
		show_help
		exit 0
		;;
	# -t | --test)
	# 	testflag_function
	# 	shift
	# 	;;
	# -u | --user-input)
	# 	USER_INPUT="$2"
	# 	shift 2 # <-- pay attention, shift twice
	# 	;;
	*)
		echo "${RED}Unknown option: $1${RESET}" >&2
		show_help
		exit 1
		;;
	esac
done

# =========================  MAIN  =========================
big_print "$GREEN" "Starting all for all in one installation script"
required_packages # ex. curl git xdotool

main() {
	echo "${GREEN}Make sure ssh-keys are added to ssh-agent...${RESET}"
	if ask_confirmation; then
		echo "${GREEN}Continuing.. ${RESET}"
	else
		echo "${RED}Aborting script...${RESET}"
		sleep 2
		exit 1
	fi

	base_matrix=(
		"install_dots.sh" "$YELLOW" "Installing dots.."
		"install_bins.sh" "$YELLOW" "Installing bins.."
		"install_configs.bash" "$YELLOW" "Installing configs.."
	)

	rest_matrix=(
		"install_base_apt.sh" "$BLUE" "Installing apt packages.."
		"install_unattended.bash" "$BLUE" "Installing and setting up unattended package.."
		"install_hblock.sh" "$CYAN" "Installing hblock.."
	)

	process_files "${base_matrix[@]}"
	process_files "${rest_matrix[@]}"
}

main
echo "${GREEN}Script complete.${RESET}"
