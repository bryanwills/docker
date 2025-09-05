#!/bin/bash

# Linkwarden Database Backup Script
# This script creates automated backups of the Linkwarden PostgreSQL database

set -e  # Exit on any error

# Configuration
BACKUP_DIR="/home/bryanwi09/docker/backups/linkwarden"
CONTAINER_NAME="linkwarden-postgres"
DB_NAME="linkwarden"
DB_USER="linkwarden"
RETENTION_DAYS=30  # Keep backups for 30 days
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/linkwarden_backup_${DATE}.sql"
BACKUP_FILE_COMPRESSED="${BACKUP_FILE}.gz"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    log "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi

# Check if PostgreSQL container is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    error "PostgreSQL container '$CONTAINER_NAME' is not running!"
    exit 1
fi

log "Starting backup of Linkwarden database..."

# Create database dump
log "Creating database dump..."
if docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" -d "$DB_NAME" > "$BACKUP_FILE"; then
    log "Database dump created successfully: $BACKUP_FILE"
else
    error "Failed to create database dump!"
    exit 1
fi

# Compress the backup
log "Compressing backup..."
if gzip "$BACKUP_FILE"; then
    log "Backup compressed: $BACKUP_FILE_COMPRESSED"
    BACKUP_FILE="$BACKUP_FILE_COMPRESSED"
else
    error "Failed to compress backup!"
    exit 1
fi

# Get backup size
BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
log "Backup completed successfully! Size: $BACKUP_SIZE"

# Clean up old backups
log "Cleaning up backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -name "linkwarden_backup_*.sql.gz" -type f -mtime +$RETENTION_DAYS -delete
CLEANED_COUNT=$(find "$BACKUP_DIR" -name "linkwarden_backup_*.sql.gz" -type f | wc -l)
log "Cleanup completed. $CLEANED_COUNT backup files remaining."

# Create a symlink to the latest backup for easy access
LATEST_BACKUP="$BACKUP_DIR/latest_backup.sql.gz"
if [ -L "$LATEST_BACKUP" ]; then
    rm "$LATEST_BACKUP"
fi
ln -s "$(basename "$BACKUP_FILE")" "$LATEST_BACKUP"
log "Latest backup symlink created: $LATEST_BACKUP"

log "Backup process completed successfully!"
