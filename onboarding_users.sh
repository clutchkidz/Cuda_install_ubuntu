#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

declare -A USERS
USERS=(
    ["hitman"]="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFaS6suIY1Ld3HMTRD1P3woowD8CQETb772tmCSy3hG tommy@TommyStiansen"
    ["trollboy"]="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElnauvqcUmA6Qo5NuInnEjZRZ662PYMa3TRoinZQnpX trollboy@datalake001"
    ["ops"]="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFaS6suIY1Ld3HMTRD1P3woowD8CQETb772tmCSy3hG tommy@TommyStiansen"
)

echo "🚀 Onboarding Making tiny homes and keys 🚀"

for USER in "${!USERS[@]}"; do
    echo "Creating user: $USER"
    
    # Create user if they don't exist
    if id "$USER" &>/dev/null; then
        echo "User $USER already exists, skipping..."
    else
        useradd -m -s /bin/bash "$USER"
        echo "User $USER created."
    fi

    # Set up SSH directory
    USER_HOME="/home/$USER"
    SSH_DIR="$USER_HOME/.ssh"
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"

    # Add SSH key
    echo "${USERS[$USER]}" > "$SSH_DIR/authorized_keys"
    chmod 600 "$SSH_DIR/authorized_keys"
    chown -R "$USER:$USER" "$SSH_DIR"
    
    echo "SSH key added for $USER."
done

echo "All users created and SSH keys set up."
