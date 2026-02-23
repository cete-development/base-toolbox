# ~/.bash_logout: executed by bash(1) when login shell exits.

if [ "$SHLVL" = 1 ]; then
    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
fi

# Clear command history upon logout
history -c      # Clears the current session's history
history -w      # Overwrites the history file with the cleared history

