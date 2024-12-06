#!/bin/bash

# Ensure script is run with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Please run with sudo"
    exit 1
fi

# Stop any running containers
docker compose down -v

# Clean up old directories if they exist
rm -rf moodle moodledata

# Clone Moodle first
git clone -b MOODLE_402_STABLE git://git.moodle.org/moodle.git

# Create moodledata directory
mkdir -p moodledata

# Get the actual user who ran sudo
REAL_USER=$(logname || echo $SUDO_USER)
REAL_USER_ID=$(id -u $REAL_USER)
REAL_GROUP_ID=$(id -g $REAL_USER)

# Set proper permissions
chown -R $REAL_USER:$REAL_USER moodle moodledata
chmod -R 755 moodle
chmod -R 777 moodledata

# Copy config file to moodle directory
cp config.php moodle/
chown $REAL_USER:$REAL_USER moodle/config.php
chmod 644 moodle/config.php

# Ensure docker-compose is executable
chmod +x /usr/local/bin/docker-compose

# Start containers
docker compose up -d

# Wait for database to be ready
echo "Waiting for database to be ready..."
sleep 30

# Set permissions in containers
docker compose exec -T php bash -c "chown -R www-data:www-data /var/www/html /var/www/moodledata"
docker compose exec -T php bash -c "chmod -R 755 /var/www/html"
docker compose exec -T php bash -c "chmod -R 777 /var/www/moodledata"

echo "Moodle initialization complete. Please visit http://localhost to complete the installation." 
