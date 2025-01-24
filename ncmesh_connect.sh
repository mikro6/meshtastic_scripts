#!/bin/bash

# Meshtastic Setup Script with User Input for Device Name, Short Name, Role, and Admin Key
echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
echo "-=    North Carolina Mesh Easy Setup (Based off instructions on the site.)   =-"
echo "-=    by Jason Hawks - Website: https://fixedbit.com | Discord: fixedbit     =-"
echo "-=          Shoutout to the North Carolina Meshtastic Community!             =-"
echo "-=    Website https://ncmesh.net | Discord: https://discord.gg/xUzRAjHZk8    =-"
echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"

# Function to execute and check commands
run_command() {
    echo "Executing: $1"
    eval "$1"
    if [ $? -ne 0 ]; then
        echo "Command failed: $1"
    fi
}

# Prompt user for device owner name
read -p "Enter the owner name for this device (long name): " owner_name
if [ -z "$owner_name" ]; then
    echo "Owner name is required. Exiting."
    exit 1
fi

# Prompt user for device short name
read -p "Enter the short name for this device (up to 4 characters): " short_name
if [ -z "$short_name" ] || [ ${#short_name} -gt 4 ]; then
    echo "Invalid short name. Please provide a name up to 4 characters. Exiting."
    exit 1
fi

# Prompt user for device mode
echo "Select the device mode:"
echo "1. Client"
echo "2. Client Mute"
echo "3. Router"
read -p "Enter your choice (1-3, default is 1): " device_mode

# Set default mode if no valid input is provided
case "$device_mode" in
    1) device_role=0 ;;  # Client
    2) device_role=1 ;;  # Client Mute
    3) device_role=2 ;;  # Router
    *) 
        echo "No valid selection made. Defaulting to Client mode."
        device_role=0 ;;
esac

# Configure device owner, short name, and role
echo "Configuring device owner, short name, and role..."
run_command "meshtastic --host localhost --set-owner '$owner_name' --set-owner-short '$short_name' --set device.role $device_role"

# Configure LoRa settings
echo "Configuring LoRa settings..."
run_command "meshtastic --host localhost --set lora.region US --set lora.tx_power 30 --set lora.hop_limit 4"

# Configure position settings
echo "Configuring position settings..."
run_command "meshtastic --host localhost --set position.gps_mode ENABLED --set position.gps_update_interval 1800 --set position.position_broadcast_secs 3600 --set position.broadcast_smart_minimum_interval_secs 1800 --set position.broadcast_smart_minimum_distance 100"

# Configure MQTT settings
echo "Configuring MQTT settings..."
run_command "meshtastic --host localhost --set mqtt.enabled true --set mqtt.address mqtt.ncmesh.net --set mqtt.username meshdev --set mqtt.password large4cats --set mqtt.proxy_to_client_enabled true --set mqtt.map_reporting_enabled true"

# Configure primary channel
echo "Configuring primary channel (LongFast)..."
run_command "meshtastic --host localhost --ch-set name 'LongFast' --ch-index 0 --ch-set uplink_enabled true --ch-set downlink_enabled true --ch-set module_settings.position_precision 1 --ch-index 0"

# Add and configure secondary channel
echo "Adding and configuring secondary channel (NCMesh)..."
run_command "meshtastic --host localhost --ch-add 1"
run_command "meshtastic --host localhost --ch-set name 'NCMesh' --ch-index 1 --ch-set uplink_enabled true --ch-set downlink_enabled true --ch-set module_settings.position_precision 1 --ch-index 1 --ch-set psk 'default' --ch-index 1"

# Final Confirmation
echo "Meshtastic device setup completed successfully!"
