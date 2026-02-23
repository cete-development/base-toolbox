#!/bin/bash

BINPATH="$HOME/base-toolbox/bin"
DEST="$HOME/.local/bin"
BACKUP="$HOME/.local/bin_backup_$(date +%Y%m%d_%H%M%S)"

# Check if source directory exists
if [[ -d "$BINPATH" ]]; then
    # Create destination if it doesn't exist
    mkdir -p "$DEST"

    # Backup existing files if any
    if compgen -G "$DEST/*" > /dev/null; then
        echo "Backing up existing files to $BACKUP"
        mkdir -p "$BACKUP"
        cp -rf "$DEST/"* "$BACKUP/"
    fi

    # Copy and overwrite files
    echo "Copying files from $BINPATH to $DEST"
    cp -rf "$BINPATH/"* "$DEST/"

    echo "Done."
else
    echo "Source directory $BINPATH does not exist!"
    exit 1
fi