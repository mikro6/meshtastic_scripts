#!/bin/bash

# Display banner
echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
echo "-=      Waveshare LoRA HAT for Raspberry Pi Configuration Script             =-"
echo "-=    by Jason Hawks - Website: https://fixedbit.com | Discord: fixedbit     =-"
echo "-=          Shoutout to the North Carolina Meshtastic Community!             =-"
echo "-=    Website https://ncmesh.net | Discord: https://discord.gg/xUzRAjHZk8    =-"
echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"

# Check if the script is running as root or with sudo
if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as root or with sudo privileges."
    exit 1
fi

# Check if the system is a Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null; then
    echo "This script is designed to run on a Raspberry Pi. Exiting..."
    exit 1
fi

CONFIG_FILE="/boot/firmware/config.txt"

echo "Configuring SPI and I2C support on your Raspberry Pi..."

# Enable SPI using raspi-config
echo "Enabling SPI support..."
raspi-config nonint set_config_var dtparam spi on "$CONFIG_FILE"

# Enable I2C using raspi-config
echo "Enabling I2C support..."
raspi-config nonint set_config_var dtparam i2c_arm on "$CONFIG_FILE"

# Ensure dtoverlay=spi0-0cs is set in the config file
echo "Configuring dtoverlay for SPI..."
sed -i -e '/^\s*#\?\s*dtoverlay\s*=\s*vc4-kms-v3d/! s/^\s*#\?\s*(dtoverlay|dtparam\s*=\s*uart0)\s*=.*/dtoverlay=spi0-0cs/' "$CONFIG_FILE"

# Insert dtoverlay=spi0-0cs after dtparam=spi=on if not already present
if ! grep -q '^\s*dtoverlay=spi0-0cs' "$CONFIG_FILE"; then
    echo "Adding dtoverlay=spi0-0cs to $CONFIG_FILE..."
    sed -i '/^\s*dtparam=spi=on/a dtoverlay=spi0-0cs' "$CONFIG_FILE"
fi

echo "All changes applied. Please reboot your Raspberry Pi to enable the changes."

# Prompt user to reboot now or later
read -p "Would you like to reboot now? (yes/no) [Default: yes]: " reboot_choice
reboot_choice=${reboot_choice:-yes}

if [[ "$reboot_choice" == "yes" ]]; then
    echo "Rebooting the system now..."
    reboot
else
    echo "Reboot skipped. Please manually reboot the system for changes to take effect."
fi
