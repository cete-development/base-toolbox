#!/bin/bash

backup() { cp -f -- "$1" "$1.bak.$(date +%Y%m%d-%H%M%S)"; }

lssh() {
	[ -z "$1" ] && echo "Usage: lssh <keyfile>" && return 1
	eval "$(ssh-agent -s)"
	ssh-add "$HOME/.ssh/$1"
}

lextract() {
	local file="$1"

	[ ! -f "$file" ] && {
		echo "'$file' is not a valid file"
		return 1
	}

	case "$file" in
	*.tar.bz2) tar xjf "$file" ;;
	*.tar.gz) tar xzf "$file" ;;
	*.tbz2) tar xjf "$file" ;;
	*.tgz) tar xzf "$file" ;;
	*.tar.xz) tar xf "$file" ;;
	*.tar.zst) tar xf "$file" ;;
	*.tar) tar xf "$file" ;;
	*.bz2) bunzip2 "$file" ;;
	*.gz) gunzip "$file" ;;
	*.zip) unzip "$file" ;;
	*.rar) unrar x "$file" ;;
	*.7z) 7z x "$file" ;;
	*.Z) uncompress "$file" ;;
	*.deb) ar x "$file" ;;
	*) echo "'$file' cannot be extracted" ;;
	esac
}

lmksshkey() {
	local name="$1"
	[ -z "$name" ] && {
		echo "Usage: lmksshkey <name>"
		return 1
	}

	ssh-keygen -o -a 100 -t ed25519 -C "$name" -f "$HOME/.ssh/$name"
}

clone_repo() {
	printf "repo Username: "
	read usrn
	printf "repo Name: "
	read rpnm

	#git clone https://github.com/$usrn/$rpnm   #for https
	git clone git@github.com:$usrn/$rpnm.git
}

gl() {
	command -v git >/dev/null 2>&1 || {
		echo "git not found"
		return 1
	}
	command -v fzf >/dev/null 2>&1 || {
		echo "fzf not found"
		return 1
	}
	git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
		echo "not a git repo"
		return 1
	}

	git log --graph --color=always \
		--format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
		fzf --ansi --no-sort --reverse --tiebreak=index --toggle-sort=\` \
			--bind "ctrl-m:execute:
        echo '{}' |
        grep -o '[a-f0-9]\{7\}' |
        head -1 |
        xargs -I % sh -c 'git show --color=always % | less -R'"
}

get_path() {
	find "$(pwd)" -type f -name "$1" -print -quit
}

# Templatefy script of file.
# Argument 1: File to copy.
# Argument 2: New name of the template.
function new_template() {
	if [ "$#" -lt 2 ]; then
		cp $1 ~/base-toolbox/templates/"$(basename "$1")"
		nvim ~/base-toolbox/templates/"$(basename "$1")"
	else
		file_ex="${1##*.}"
		cp $1 ~/base-toolbox/templates/"$2".$file_ex
		nvim ~/base-toolbox/templates/"$2".$file_exs
	fi
}

# List all custom functions
function list_functions() {
	declare -F | awk '{print $3}' | grep -v -e '^_' -e 'git'
}

# Dynamically get the ip range
# Linux only
function lnmapd() {
	if command -v nmap >/dev/null 2>&1; then
		echo "nmap is installed"
		local network_prefix
		network_prefix=$(ip addr show | grep -oP 'inet \K[\d.]+' | grep -v '127.0.0.1' | head -n 1 | cut -d. -f1-3)
		if [ -n "$network_prefix" ]; then
			nmap -sn "$network_prefix.0/24"
		else
			echo "Unable to determine the network prefix."
		fi
	else
		echo "nmap is not installed"
	fi
}

function lcopy() {
	local file="$1"

	if [[ -z "$file" || ! -f "$file" ]]; then
		echo "Usage: copy_to_clipboard <file>"
		return 1
	fi

	if command -v xclip >/dev/null 2>&1; then
		xclip -selection clipboard <"$file"
	elif command -v wl-copy >/dev/null 2>&1; then
		wl-copy <"$file"
	elif command -v pbcopy >/dev/null 2>&1; then
		pbcopy <"$file"
	elif command -v clip >/dev/null 2>&1; then
		clip <"$file"
	else
		echo "No clipboard utility found."
		return 1
	fi
}
