#!/bin/bash

# Exit on any error
set -e

echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "Installing Python 3, pip, and venv..."
sudo apt install -y python3 python3-pip python3-venv

echo
read -p "Do you want to set up the virtual environment in the current folder? (y/n): " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Creating virtual environment in ./venv..."
    python3 -m venv venv
    echo "Virtual environment created successfully."
else
    echo
    echo "To create a virtual environment manually, run:"
    echo "  python3 -m venv venv"
fi

echo
cat <<EOF
Instructions:

1. To activate the virtual environment:
   source venv/bin/activate

2. To deactivate the virtual environment:
   deactivate

You can now install packages using pip and start developing your Python project.
EOF

