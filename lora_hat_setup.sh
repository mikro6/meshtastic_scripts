#!/bin/bash

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

# Ensure the configuration file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Configuration file $CONFIG_FILE not found. Exiting..."
    exit 1
fi

echo "Configuring SPI and I2C support on your Raspberry Pi..."

# Enable SPI
echo "Enabling SPI support..."
sudo raspi-config nonint set_config_var dtparam=spi on "${CONFIG_FILE}"

# Enable I2C
echo "Enabling I2C support..."
sudo raspi-config nonint set_config_var dtparam=i2c_arm on "${CONFIG_FILE}"

# Ensure dtoverlay=spi0-0cs is set in /boot/firmware/config.txt without altering dtoverlay=vc4-kms-v3d or dtparam=uart0
echo "Configuring dtoverlay for SPI..."
sudo sed -i -e '/^\s*#\?\s*dtoverlay\s*=\s*vc4-kms-v3d/! s/^\s*#\?\s*(dtoverlay|dtparam\s*=\s*uart0)\s*=.*/dtoverlay=spi0-0cs/' "${CONFIG_FILE}"

# Insert dtoverlay=spi0-0cs after dtparam=spi=on if not already present
if ! sudo grep -q '^\s*dtoverlay=spi0-0cs' "${CONFIG_FILE}"; then
    sudo sed -i '/^\s*dtparam=spi=on/a dtoverlay=spi0-0cs' "${CONFIG_FILE}"
fi

echo "Enable GPS if installed on your HAT."
sudo raspi-config nonint do_serial_hw 0

echo "Disable serial console."
sudo raspi-config nonint do_serial_cons 1

# Offer to fetch and copy the Meshtasticd configuration
read -p "Would you like to fetch the Meshtasticd configuration for the Waveshare LoRa HAT? (yes/no) [Default: yes]: " config_choice
config_choice=${config_choice:-yes}

if [[ "$config_choice" == "yes" ]]; then
    CONFIG_DIR="/etc/meshtasticd"
    CONFIG_URL="https://raw.githubusercontent.com/FixedBit/meshtastic_scripts/refs/heads/main/example_config/config.yaml"
    TARGET_CONFIG_FILE="${CONFIG_DIR}/config.yaml"

    echo "Checking for existing Meshtasticd configuration..."
    if [[ -f "${TARGET_CONFIG_FILE}" ]]; then
        echo "Existing configuration found. Renaming to config.yaml.bk..."
        sudo mv "${TARGET_CONFIG_FILE}" "${TARGET_CONFIG_FILE}.bk"
    fi

    echo "Fetching configuration from ${CONFIG_URL}..."
    sudo mkdir -p "$CONFIG_DIR"
    curl -sL "$CONFIG_URL" | sudo tee "${TARGET_CONFIG_FILE}" > /dev/null

    if [[ $? -eq 0 ]]; then
        echo "Configuration fetched and saved successfully to ${TARGET_CONFIG_FILE}."
    else
        echo "Failed to fetch the configuration. Please check your internet connection and try again."
    fi
fi

echo "All changes applied. Please reboot your Raspberry Pi to enable the changes."

# Prompt user to reboot now or later
read -p "Would you like to reboot now? (yes/no) [Default: yes]: " reboot_choice
reboot_choice=${reboot_choice:-yes}

if [[ "$reboot_choice" == "yes" ]]; then
    echo "Rebooting the system now..."
    sudo reboot
else
    echo "Reboot skipped. Please manually reboot the system for changes to take effect."
fi
