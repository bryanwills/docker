#!/bin/bash

# Linkwarden Database Restore Script
# This script restores the Linkwarden PostgreSQL database from a backup

set -e  # Exit on any error

# Configuration
BACKUP_DIR="/home/bryanwi09/docker/backups/linkwarden"
CONTAINER_NAME="linkwarden-postgres"
DB_NAME="linkwarden"
DB_USER="linkwarden"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO:${NC} $1"
}

# Function to list available backups
list_backups() {
    log "Available backups:"
    if [ -d "$BACKUP_DIR" ]; then
        ls -la "$BACKUP_DIR"/*.sql.gz 2>/dev/null | while read -r line; do
            echo "  $line"
        done
    else
        warning "No backup directory found: $BACKUP_DIR"
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS] [BACKUP_FILE]"
    echo ""
    echo "Options:"
    echo "  -l, --list          List available backups"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Arguments:"
    echo "  BACKUP_FILE         Path to backup file (optional, defaults to latest)"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Restore from latest backup"
    echo "  $0 -l                                 # List available backups"
    echo "  $0 linkwarden_backup_20241201_120000.sql.gz  # Restore specific backup"
}

# Parse command line arguments
BACKUP_FILE=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -l|--list)
            list_backups
            exit 0
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        -*)
            error "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            BACKUP_FILE="$1"
            shift
            ;;
    esac
done

# If no backup file specified, use the latest
if [ -z "$BACKUP_FILE" ]; then
    LATEST_BACKUP="$BACKUP_DIR/latest_backup.sql.gz"
    if [ -L "$LATEST_BACKUP" ] && [ -f "$LATEST_BACKUP" ]; then
        BACKUP_FILE="$LATEST_BACKUP"
        log "Using latest backup: $BACKUP_FILE"
    else
        error "No backup file specified and no latest backup found!"
        list_backups
        exit 1
    fi
fi

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    error "Backup file not found: $BACKUP_FILE"
    list_backups
    exit 1
fi

# Check if PostgreSQL container is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    error "PostgreSQL container '$CONTAINER_NAME' is not running!"
    log "Please start the container first: docker start $CONTAINER_NAME"
    exit 1
fi

# Confirm restore operation
warning "This will completely replace the current database with the backup!"
warning "All current data will be lost!"
echo ""
info "Backup file: $BACKUP_FILE"
info "Database: $DB_NAME"
info "Container: $CONTAINER_NAME"
echo ""
read -p "Are you sure you want to continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    log "Restore operation cancelled."
    exit 0
fi

# Stop Linkwarden container to prevent data corruption
log "Stopping Linkwarden container to prevent data corruption..."
if docker ps | grep -q "linkwarden$"; then
    docker stop linkwarden
    log "Linkwarden container stopped."
else
    warning "Linkwarden container was not running."
fi

# Drop and recreate database
log "Dropping and recreating database..."
docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -c "DROP DATABASE IF EXISTS $DB_NAME;"
docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -c "CREATE DATABASE $DB_NAME;"
log "Database recreated successfully."

# Restore from backup
log "Restoring database from backup..."
if [[ "$BACKUP_FILE" == *.gz ]]; then
    # Compressed backup
    if zcat "$BACKUP_FILE" | docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME"; then
        log "Database restored successfully from compressed backup!"
    else
        error "Failed to restore database from compressed backup!"
        exit 1
    fi
else
    # Uncompressed backup
    if docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" < "$BACKUP_FILE"; then
        log "Database restored successfully from uncompressed backup!"
    else
        error "Failed to restore database from uncompressed backup!"
        exit 1
    fi
fi

# Start Linkwarden container
log "Starting Linkwarden container..."
docker start linkwarden
log "Linkwarden container started."

# Wait a moment for the container to fully start
sleep 5

# Check if Linkwarden is healthy
if docker ps | grep -q "linkwarden.*healthy"; then
    log "Linkwarden is running and healthy!"
    log "You can access it at: http://localhost:3000 or https://links.bryanwills.dev"
else
    warning "Linkwarden container started but may not be fully ready yet."
    log "Check container status with: docker ps"
fi

log "Restore process completed successfully!"
