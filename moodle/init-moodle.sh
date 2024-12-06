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

# Add these lines after creating directories but before starting containers
echo "Setting up Nginx cache directories..."
docker compose exec nginx mkdir -p /var/cache/nginx/client_temp \
    /var/cache/nginx/proxy_temp \
    /var/cache/nginx/fastcgi_temp \
    /var/cache/nginx/uwsgi_temp \
    /var/cache/nginx/scgi_temp

docker compose exec nginx chown -R nginx:nginx /var/cache/nginx
docker compose exec nginx chmod -R 755 /var/cache/nginx

# Start containers
docker compose up -d

# Wait for database to be ready
echo "Waiting for database to be ready..."
max_tries=30
counter=0
while ! docker compose exec db mysqladmin ping -h localhost -u root -pAdmin@123 --silent; do
    sleep 5
    counter=$((counter + 1))
    echo "Waiting for database (attempt $counter/$max_tries)..."
    
    if [ $counter -ge $max_tries ]; then
        echo "Database failed to start after $max_tries attempts"
        echo "Checking database logs:"
        docker compose logs db
        exit 1
    fi
done

echo "Database is ready!"

# Set permissions in containers
docker compose exec -T php bash -c "chown -R www-data:www-data /var/www/html /var/www/moodledata"
docker compose exec -T php bash -c "chmod -R 755 /var/www/html"
docker compose exec -T php bash -c "chmod -R 777 /var/www/moodledata"

echo "Moodle initialization complete. Please visit http://localhost to complete the installation."

# Add after the existing code
echo "Testing network connectivity..."
docker compose exec nginx curl -I localhost:80
echo "If you cannot access the site, check:"
echo "1. Firewall settings (sudo ufw status)"
echo "2. Security group rules if running in cloud"
echo "3. Correct IP address in config.php"
echo "4. Network interface configuration" 
