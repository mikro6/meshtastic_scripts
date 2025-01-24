#!/bin/bash

# Define the URLs for the scripts
SCRIPTS=(
    "LoRA Raspberry Pi HAT Setup|https://raw.githubusercontent.com/FixedBit/meshtastic_scripts/refs/heads/main/lora_hat_setup.sh"
    "Meshtasticd and Meshtastic CLI Setup / Update|https://raw.githubusercontent.com/FixedBit/meshtastic_scripts/refs/heads/main/meshtastic_setup.sh"
    "North Carolina Mesh / NCMesh.net Configuration|https://raw.githubusercontent.com/FixedBit/meshtastic_scripts/refs/heads/main/ncmesh_connect.sh"
)

HISTORY_FILE="$HOME/.fixedbit/meshtastic_history"
ALIAS_FILE="$HOME/.bash_aliases"
ALIAS_NAME="meshtastic-update"
ALIAS_COMMAND="curl -sL https://raw.githubusercontent.com/FixedBit/meshtastic_scripts/refs/heads/main/live_install_scripts/live.sh | bash"

# Ensure history file exists
mkdir -p "$(dirname "$HISTORY_FILE")"
touch "$HISTORY_FILE"

# Function to ensure alias is written to a permanent location
write_alias() {
    if [ -f "$ALIAS_FILE" ]; then
        # Add to ~/.bash_aliases
        if ! grep -q "^alias $ALIAS_NAME=" "$ALIAS_FILE"; then
            echo "alias $ALIAS_NAME='$ALIAS_COMMAND'" >> "$ALIAS_FILE"
        fi
    else
        # Add to ~/.bashrc if ~/.bash_aliases does not exist
        if ! grep -q "^alias $ALIAS_NAME=" "$HOME/.bashrc"; then
            echo "alias $ALIAS_NAME='$ALIAS_COMMAND'" >> "$HOME/.bashrc"
        fi
    fi
}

# Function to update the history file
update_history() {
    local TASK="$1"
    if ! grep -q "^${TASK}$" "$HISTORY_FILE"; then
        echo "$TASK" >> "$HISTORY_FILE"
    fi
}

# Function to display the menu
show_menu() {
    echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
    echo "-=          FixedBit Meshtastic Setup and Configuration Script               =-"
    echo "-=            by Jason Hawks - Website: https://fixedbit.com                 =-"
    echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
    echo ""
    echo "Choose an option:"
    for i in "${!SCRIPTS[@]}"; do
        SCRIPT_NAME=$(echo "${SCRIPTS[$i]}" | cut -d'|' -f1)
        if grep -q "^${SCRIPT_NAME}$" "$HISTORY_FILE"; then
            echo "$((i + 1))) $SCRIPT_NAME (DONE)"
        else
            echo "$((i + 1))) $SCRIPT_NAME (Not yet done)"
        fi
    done

    # Check alias status
    if grep -q "^Create an alias for Meshtastic updates$" "$HISTORY_FILE"; then
        echo "$(( ${#SCRIPTS[@]} + 1 ))) Create an alias for Meshtastic updates (DONE)"
    else
        echo "$(( ${#SCRIPTS[@]} + 1 ))) Create an alias for Meshtastic updates (Not yet done)"
    fi

    echo "$(( ${#SCRIPTS[@]} + 2 ))) Exit"
    echo ""
}

# Function to execute the selected script
run_script() {
    local SCRIPT_NAME="$1"
    local SCRIPT_URL="$2"

    echo "Running $SCRIPT_NAME..."
    curl -sL "$SCRIPT_URL" | bash
    if [ $? -eq 0 ]; then
        update_history "$SCRIPT_NAME"
        echo "Successfully completed $SCRIPT_NAME."
    else
        echo "Failed to run $SCRIPT_NAME. Please check for errors."
    fi
    echo ""
}

# Function to create an alias for Meshtastic updates
create_alias() {
    echo "Creating an alias for Meshtastic updates..."
    write_alias
    source "$HOME/.bashrc" 2>/dev/null || true
    source "$ALIAS_FILE" 2>/dev/null || true
    update_history "Create an alias for Meshtastic updates"
    echo "Alias 'meshtastic-update' created! You can now run this command to access the menu."
    echo "Note: You may need to log out and log back in for the alias to work in new sessions."
    echo ""
}

# Main menu loop
while true; do
    show_menu
    read -p "Enter your choice: " CHOICE

    # Validate if CHOICE is an integer
    if [[ "$CHOICE" =~ ^[0-9]+$ ]]; then
        if [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le "${#SCRIPTS[@]}" ]; then
            SCRIPT_ENTRY="${SCRIPTS[$((CHOICE - 1))]}"
            SCRIPT_NAME=$(echo "$SCRIPT_ENTRY" | cut -d'|' -f1)
            SCRIPT_URL=$(echo "$SCRIPT_ENTRY" | cut -d'|' -f2)
            if grep -q "^${SCRIPT_NAME}$" "$HISTORY_FILE"; then
                read -p "$SCRIPT_NAME has already been completed. Do you want to run it again? (yes/no): " CONFIRM
                if [[ "$CONFIRM" =~ ^[Yy][Ee][Ss]|[Yy]$ ]]; then
                    run_script "$SCRIPT_NAME" "$SCRIPT_URL"
                fi
            else
                run_script "$SCRIPT_NAME" "$SCRIPT_URL"
            fi
        elif [ "$CHOICE" -eq "$(( ${#SCRIPTS[@]} + 1 ))" ]; then
            create_alias
        elif [ "$CHOICE" -eq "$(( ${#SCRIPTS[@]} + 2 ))" ]; then
            echo "Exiting. Have a great day!"
            exit 0
        else
            echo "Invalid choice. Please select a valid option."
        fi
    else
        echo "Invalid input. Please enter a number corresponding to the menu options."
    fi
done
