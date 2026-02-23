#!/bin/sh

ldocker_enter() {
  command -v docker >/dev/null || {
    echo "Docker not installed." >&2
    return 1
  }

  [ -z "$1" ] && { echo "Usage: ldocker_enter <container>"; return 1; }

  docker ps --format '{{.Names}}' | grep -wq "$1" || {
    echo "Container '$1' not running."
    return 1
  }

  docker exec -it "$1" bash 2>/dev/null || docker exec -it "$1" sh
}

###################
# Completion
###################
# _denter_completion() {
#   COMPREPLY=( $(compgen -W "$(docker ps --format '{{.Names}}')" -- "${COMP_WORDS[1]}") )
# }
# complete -F _denter_completion ldocker_enter
