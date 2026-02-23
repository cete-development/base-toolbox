# Interactive shell guard #
case $- in
*i*) ;;
*) return ;;
esac

# Shell detection
IS_BASH=0
[ -n "$BASH_VERSION" ] && IS_BASH=1

# Source file
load_if_exists() {
	if [ -f "$1" ]; then
		. "$1"
		printf '\033[34m%s imported.\033[0m\n' "$2"
	fi
}

# Base
load_if_exists "$HOME/base-toolbox/bin/base_functions.sh" "Base functions"
load_if_exists "$HOME/base-toolbox/bin/base_aliases.sh" "Base aliases"
load_if_exists "$HOME/base-toolbox/bin/remote_functions.sh" "Remote functions"

# Pers
load_if_exists "$HOME/pers-toolbox/bin/pers_aliases.sh" "Pers functions"

# Eza replacement of ls (after alias sourcing)
if command -v eza >/dev/null 2>&1; then
	alias ll="eza -al --git --git-repos -o --header --hyperlink --icons --time-style '+%d-%m-%Y %H:%M'"
	alias lt="eza -al --git --git-repos -o --header --hyperlink --icons --time-style '+%d-%m-%Y %H:%M' -T"
fi

# Batcat replacement of cat
if command -v batcat >/dev/null 2>&1; then
	alias cat='batcat --paging never'
	alias less='batcat'
fi

# Fastfetch
if command -v fastfetch >/dev/null 2>&1; then
	alias ff="fastfetch"
fi

# Lesspipe
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# dircolors
if [ -x /usr/bin/dircolors ]; then
	[ -r "$HOME/.dircolors" ] &&
		eval "$(dircolors -b "$HOME/.dircolors")" ||
		eval "$(dircolors -b)"
fi

# PATH
export PATH="$HOME/.local/bin:$PATH"

# History
export HISTCONTROL=ignoreboth
export HISTSIZE=1000
export HISTFILESIZE=2000

# BASH prompt fallback
if [ -n "$BASH_VERSION" ]; then
	shopt -s histappend checkwinsize
	PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

	case "$TERM" in
	xterm* | rxvt*)
		PS1="\[\e]0;\u@\h: \w\a\]$PS1"
		;;
	esac
fi
