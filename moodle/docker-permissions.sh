#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run with sudo"
    exit 1
fi

# Get the actual user who ran sudo
REAL_USER=$(logname || echo $SUDO_USER)

echo "Setting up Docker permissions for user: $REAL_USER"

# Create docker group if it doesn't exist
if ! getent group docker > /dev/null; then
    groupadd docker
fi

# Add user to docker group
usermod -aG docker $REAL_USER

# Set permissions on Docker socket
chmod 666 /var/run/docker.sock

# Restart Docker daemon
systemctl restart docker

# Show current permissions
ls -l /var/run/docker.sock

echo "Permissions have been set. Please log out and log back in for changes to take effect."
echo "You can test the permissions by running: docker ps" 
