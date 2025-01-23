
# Waveshare LoRa HAT and Meshtastic Setup Scripts

This project contains a collection of scripts designed to streamline the setup and configuration of the Waveshare LoRaWAN/GNSS HAT and Meshtastic on Raspberry Pi devices.

The "meshtastic_setup.sh" script will more than likely work just fine to install / update meshtasticd on other systems too.

## Features
- Automated setup for the Waveshare LoRaWAN/GNSS HAT with SPI and I2C configuration.
- Easy installation and update of Meshtastic CLI and Meshtasticd service.
- Backup and restore of Meshtastic configurations.
- Support for multiple architectures: `amd64`, `arm64`, `armhf`.
- Example configuration file for customizing your setup.

---

## Table of Contents
1. [Requirements](#requirements)
2. [Setup Instructions](#setup-instructions)
   - [Raspberry Pi LoRa HAT Configuration](#raspberry-pi-lora-hat-configuration)
   - [Meshtastic Setup](#meshtastic-setup)
3. [Example Configuration](#example-configuration)
4. [Credits](#credits)

---

## Requirements
### Hardware
- Raspberry Pi (any model supported by Meshtastic and Waveshare LoRa HAT).
- Waveshare SX1262 XXXM LoRaWAN/GNSS HAT ([Product Page](https://www.waveshare.com/wiki/SX1262_XXXM_LoRaWAN/GNSS_HAT)).

### Software
- Raspberry Pi OS or another Debian-based Linux distribution.
- `bash` shell for running scripts.

---

## Setup Instructions

### Raspberry Pi LoRa HAT Configuration
1. Clone this repository:
   ```bash
   git clone https://github.com/FixedBit/meshtastic_scripts.git
   cd meshtastic_scripts
   ```

2. Run the LoRa HAT configuration script:
   ```bash
   sudo ./lora_hat_setup.sh
   ```
   - This script will enable SPI and I2C, configure the necessary device overlays, and ensure your Raspberry Pi is ready for the LoRaWAN/GNSS HAT.
   - The script will prompt for a reboot to apply changes.

---

### Meshtastic Setup
1. Run the Meshtastic setup script:
   ```bash
   sudo ./meshtastic_setup.sh
   ```
   - The script will:
     - Check and install required dependencies.
     - Set up a Python virtual environment for the Meshtastic CLI.
     - Install or update the `meshtasticd` service.
     - Back up existing Meshtastic configurations.
     - Start and optionally enable the Meshtasticd service.

2. Follow the prompts to install the latest Meshtastic CLI and configure the `meshtasticd` service.

---

## Example Configuration
An example configuration file for the Waveshare LoRaWAN/GNSS HAT is included in this repository. You can find it at `example_config/config.yaml`.

### Key Configuration Parameters
- **LoRa Module**: Specifies the module (e.g., `sx1262`) and pin mappings.
- **GPS**: Defines the serial path for GPS (optional).
- **Logging**: Adjusts logging levels and output files.
- **Webserver**: Configures the port and root path for the Meshtastic web server.
- **General**: Controls limits for nodes, messages, and MAC address source.

To use the configuration:
1. Copy the example file to the appropriate location:
   ```bash
   sudo mkdir -p /etc/meshtasticd && sudo cat example_config/config.yaml > /etc/meshtasticd/config.yaml
   ```

2. Edit the file to suit your setup:
   ```bash
   sudo nano /etc/meshtasticd/config.yaml
   ```

3. Restart the Meshtasticd service:
   ```bash
   sudo systemctl restart meshtasticd
   ```

---

## Credits
- **Author**: Jason Hawks  
  - Website: [FixedBit Technologies](https://fixedbit.com)  
  - Discord: `fixedbit`

- **Shoutout**: North Carolina Meshtastic Community  
  - Website: [NCMesh](https://ncmesh.net)  
  - Discord: [Join Here](https://discord.gg/xUzRAjHZk8)

---

Happy Meshing! 🌐
