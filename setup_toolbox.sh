#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

load_if_exists() {
  if [ -f "$1" ]; then
    cp "$1" ~
    printf '\033[34m%s imported.\033[0m\n' "$2"
  fi
}

load_if_exists "$SCRIPT_DIR/base_aliases.sh" "aliases"
load_if_exists "$SCRIPT_DIR/basebin/base_functions.sh" "functions"
load_if_exists "$SCRIPT_DIR/.bashrc" "bashrc"


