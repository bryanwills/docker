#!/bin/bash

# Setup organized logging for bigbraincoding.com
# This script creates the necessary directory structure and sets up log rotation

# Create base logging directory
mkdir -p /home/bryanwi09/docker/nginx/logs/bigbraincoding.com

# Create year/month/day structure for current year
CURRENT_YEAR=$(date +%Y)
CURRENT_MONTH=$(date +%m)
CURRENT_DAY=$(date +%d)

# Create directories for current year
for month in {01..12}; do
    mkdir -p "/home/bryanwi09/docker/nginx/logs/bigbraincoding.com/$CURRENT_YEAR/$month"
done

# Create directories for next year (planning ahead)
NEXT_YEAR=$((CURRENT_YEAR + 1))
for month in {01..12}; do
    mkdir -p "/home/bryanwi09/docker/nginx/logs/bigbraincoding.com/$NEXT_YEAR/$month"
done

# Set proper permissions
sudo chown -R 101:101 /home/bryanwi09/docker/nginx/logs/bigbraincoding.com
sudo chmod -R 755 /home/bryanwi09/docker/nginx/logs/bigbraincoding.com

echo "Logging structure created for bigbraincoding.com"
echo "Base directory: /home/bryanwi09/docker/nginx/logs/bigbraincoding.com"
echo "Year/Month structure created for $CURRENT_YEAR and $NEXT_YEAR"