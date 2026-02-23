#!/bin/bash
alias cls='clear'
alias h='history'
alias open='start'

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -i'

alias ll='ls -avhlF'
alias ls='ls --color -a'

alias lsize="du -shc * | awk '/total/ {print \"\033[1;33m\" \$0 \"\033[0m\"; next} {print}'"
alias ld='ls -alhd */ .*/'

alias lfind='ll | grep '

alias lpuid="awk -F: '{print $3, $1}' /etc/passwd | sort -n"
alias lpgid="awk -F: '{print $3, $1}' /etc/group | sort -n"

alias lcommitall='git add . && git commit -m'
alias gs='git status'

alias sr="reboot now"

## System stuff
alias lsys='systemctl list-units --type=service'
alias lupdate='sudo apt update; sudo apt upgrade -y; sudo apt autoremove -y'
alias lbin="ls -avhgF /home/$USER/.local/bin"
alias lerrors="journalctl -p 3 -xb"
alias lhardware="hwinfo --short"
alias lusers="cut -d: -f1 /etc/passwd | sort"
alias lgroups="getent group"
alias lrecentpacks='grep " install " /var/log/dpkg.log | tail -15'

alias alert='notify-send --urgency=low \
-i "$([ $? = 0 ] && echo terminal || echo error)" \
"$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
