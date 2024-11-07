#!/bin/bash

# Check if already connected
if pgrep -x "openconnect" > /dev/null; then
    echo "VPN is already connected. Disconnecting..."
    sudo killall openconnect
    sleep 2
fi

# Prompt for passwords
read -s -p "Enter your sudo password: " SUDO_PASSWD
echo
read -s -p "Enter your UT EID password: " UT_PASSWORD
echo

# Export passwords as environment variables
export SUDO_PASSWD
export UT_PASSWORD

# Run the expect script
"$(dirname "$0")/utvpn"

# Clean up
unset SUDO_PASSWD
unset UT_PASSWORD 