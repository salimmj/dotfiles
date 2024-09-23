#!/bin/bash

echo "Current Shell Environment Information:"
echo "--------------------------------------"

# Get current login shell
echo "Current login shell: $SHELL"

# Get default login shell from /etc/passwd
echo "Default login shell: $(grep "^$USER" /etc/passwd | cut -d: -f7)"

# Locate shell config files
echo "Shell config files:"
for file in ~/.bashrc ~/.bash_profile ~/.zshrc ~/.profile; do
    if [ -f "$file" ]; then
        echo "  $file exists"
    else
        echo "  $file does not exist"
    fi
done

# Check if starship is installed
if command -v starship &> /dev/null; then
    echo "starship is installed: $(which starship)"
else
    echo "starship is not installed"
fi

# List all shells in /etc/shells
echo "Available shells:"
cat /etc/shells

echo "--------------------------------------"
