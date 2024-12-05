#!/bin/bash

# Stop any running containers
docker-compose down -v

# Clean up old directories if they exist
rm -rf moodle moodledata

# Clone Moodle first
git clone -b MOODLE_402_STABLE git://git.moodle.org/moodle.git

# Create moodledata directory with proper permissions
mkdir -p moodledata
chmod 777 moodledata

# Copy config file to moodle directory
cp config.php moodle/

# Start containers
docker-compose up -d

# Wait for database to be ready
echo "Waiting for database to be ready..."
sleep 30

# Set permissions using current user ID
USER_ID=$(id -u)
GROUP_ID=$(id -g)

# Set proper permissions
docker-compose exec -T php bash -c "chown -R ${USER_ID}:${GROUP_ID} /var/www/html /var/www/moodledata"
docker-compose exec -T php bash -c "chmod -R 755 /var/www/html"
docker-compose exec -T php bash -c "chmod -R 777 /var/www/moodledata"

echo "Moodle initialization complete. Please visit http://localhost to complete the installation." 