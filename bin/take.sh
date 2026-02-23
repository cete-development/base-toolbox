#!/usr/bin/env bash

#==============================
#        CONFIG & COLORS
#==============================
RESET=$(tput sgr0)          
RED=$(tput setaf 1)         # echo "${RED}PLACEHOLDER ${RESET}"
GREEN=$(tput setaf 2)       # echo "${GREEN}PLACEHOLDER ${RESET}"
YELLOW=$(tput setaf 3)      # echo "${YELLOW}PLACEHOLDER ${RESET}"
BLUE=$(tput setaf 4)        # echo "${BLUE}PLACEHOLDER ${RESET}"
MAGENTA=$(tput setaf 5)     # echo "${MAGENTA}PLACEHOLDER ${RESET}"
CYAN=$(tput setaf 6)        # echo "${CYAN}PLACEHOLDER ${RESET}"
WHITE=$(tput setaf 7)       # echo "${WHITE}PLACEHOLDER ${RESET}"

TEMPLATE_FOLDER="/home/$USER/base-toolbox/templates/"

#==============================
#         FUNCTIONS
#==============================
# Print banner-like messages
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

# Help message
show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Functionality: 
    Take a clean copy of a template, safe it in the current dir and open it in the default editor.

Options:
  -h, --help            Show this help message and exit.
  -l, --list-templates  Lists templates to pick from.
  -t, --take            [Followed by Template name] Copies template to your current directory

Example:
  $(basename "$0") -t base_script
EOF
}

# Use these like this: check_file "path/to/file.sh" && rest_of_command.sh "path/to/file.sh"
check_file() { [[ -f "$1" ]] && echo "${GREEN}File exists. ${RESET}" || { echo "${RED}File not found. ${RESET}"; return 1; }; }
check_folder() { [[ -d "$1" ]] && echo "${GREEN}Folder exists ${RESET}" || { echo "${RED}Folder not found. ${RESET}"; return 1; }; }

take_file(){
    search_result=$(find "$TEMPLATE_FOLDER" -type f -name "*$USER_INPUT*" | head -n 1)

    file_name=$(basename "$search_result")
    cp "$search_result" ./"$file_name"
    nvim ./"$file_name"
}

list_templates(){
    big_print "$YELLOW" "Templates to pick from:"
    find "$TEMPLATE_FOLDER" -maxdepth 1 -type f -exec basename {} \;
}


#==============================
#         ARGUMENTS
#==============================
# Default values for flags
HELP=false
LIST_TEMPS=false
USER_INPUT=""

# Make sure at least one argument is given.
if [[ $# -lt 1 ]]; then
    echo "Error: No arguments provided."
    show_help
    exit 1
fi

# Parse flags
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            HELP=true
            shift
            ;;
        -l|--list-templates)
            LIST_TEMPS=true
            shift
            ;;
        -t|--take)
            USER_INPUT="$2"
            shift 2
            ;;
        *)
            echo "${RED}Unknown option: $1${RESET}" >&2
            show_help
            exit 1
            ;;
    esac
done

#==============================
#           MAIN
#==============================
if $HELP; then
    show_help
    exit 0
fi

main() {
    echo "${YELLOW}Take file script.${RESET}"
    check_folder "$TEMPLATE_FOLDER" || exit 1

    if $LIST_TEMPS; then
    list_templates
    exit 1
    fi

    take_file

    echo "${GREEN}Script complete.${RESET}"
}

main

