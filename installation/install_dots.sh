#!/bin/bash

# Source directory containing the individual dotfiles
SOURCE_DOTS=~/base-toolbox/dots
TARGET_DIR=~

# Function to ask for user confirmation
ask_confirmation() {
    while true; do
        read -p "Do you want to add $1? [y/n] " yn
        case $yn in
            [Yy]* ) return 0;;  # Yes, proceed
            [Nn]* ) return 1;;  # No, skip
            * ) echo "Please answer yes or no.";;
        esac
    done
}

shopt -s dotglob

# Loop through each file in the SOURCE_DOTS
for file in "$SOURCE_DOTS"/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        target="$TARGET_DIR/$filename"  # Assuming you want the dotfiles to be hidden in the target
        
        # Ask for user confirmation before creating the symlink
		echo $file
        if ask_confirmation "$filename"; then
            # Check if the symlink or file already exists
            if [ -e "$target" ]; then
                echo "Target $target already exists. Skipping."
            else
                ln -sfn "$file" "$target"
                echo "Symlink created for $filename"
            fi
        else
            echo "Skipped symlink for $filename."
        fi
    fi
done

echo "All done."
