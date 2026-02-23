#!/bin/bash

set -euo pipefail

echo "Starting Neovim installation script..."

# Check dependencies
for cmd in curl unzip git fc-cache nodejs npm xclip; do
    if ! command -v $cmd &> /dev/null; then
        echo "Required command '$cmd' is not installed. Please install it first."
        read -p "exiting script.."
        exit 1
    fi
done

# Install Neovim
echo "Updating package list and installing Neovim..."
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt upgrade -y
sudo apt install neovim

# Setup font
FONT_DEST="${HOME}/.local/share/fonts"

echo "Do you want to install a font? (y/n)"
read -r install_font

if [[ "$install_font" =~ ^[Yy]$ ]]; then
    echo "Which font do you want to install?"
    echo "1) Hack Solo"
    echo "2) JetBrains Mono"
    read -r font_choice

    mkdir -p "${FONT_DEST}"

    if [[ "$font_choice" == "1" ]]; then
        echo "Installing Hack Solo to ${FONT_DEST}..."
        cd "${FONT_DEST}" || exit
        curl -L -o HackSolo.zip https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip
        unzip -o HackSolo.zip
        # move all ttf files to font directory (overwrite if needed)
        mv -f *.ttf "${FONT_DEST}/"
        rm HackSolo.zip
    elif [[ "$font_choice" == "2" ]]; then
        echo "Installing JetBrains Mono NerdFont to ${FONT_DEST}..."
        cd "${FONT_DEST}" || exit
        curl -L -o JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.zip
        unzip -o JetBrainsMono.zip
        # move all ttf files to font directory (overwrite if needed)
        mv -f *.ttf "${FONT_DEST}/"
        rm JetBrainsMono.zip
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi

    echo "Refreshing font cache..."
    fc-cache -fv
    echo "Font installation complete. You may need to restart your terminal."
else
    echo "Font installation skipped."
fi

# Remove old Neovim configs if they exist
NVIM_CONFIG="$HOME/.config/nvim"
NVIM_DATA="$HOME/.local/share/nvim"

echo "Cleaning old Neovim configuration..."
for path in "$NVIM_CONFIG" "$NVIM_DATA"; do
    if [ -d "$path" ]; then
        echo "Removing $path"
        rm -rf "$path"
    fi
done

# Clone NvChad
echo "Cloning NvChad config..."
git clone -b v2.0 https://github.com/NvChad/NvChad "$NVIM_CONFIG" --depth 1

# Tree-sitter cli
echo "Installing treesitter cli"
sudo npm install -g tree-sitter-cli

echo "Installation complete. Please restart your terminal if needed."

