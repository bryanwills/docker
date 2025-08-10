#!/bin/bash
# Affine Database Backup Script
# Runs daily at midnight to backup PostgreSQL database

# Configuration
BACKUP_DIR="/home/bryanwi09/docker/affine/backups"
DOCKER_COMPOSE_DIR="/home/bryanwi09/docker/affine"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="affine_backup_$DATE.sql"
LOG_FILE="$BACKUP_DIR/backup.log"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Log function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Change to docker-compose directory
cd "$DOCKER_COMPOSE_DIR" || {
    log_message "ERROR: Failed to change to directory $DOCKER_COMPOSE_DIR"
    exit 1
}

# Check if containers are running
if ! docker-compose ps | grep -q "affine_postgres.*Up"; then
    log_message "ERROR: PostgreSQL container is not running"
    exit 1
fi

# Create backup
log_message "Starting database backup..."
if docker exec affine_postgres pg_dump -U affine -d affine > "$BACKUP_DIR/$BACKUP_FILE" 2>> "$LOG_FILE"; then
    log_message "SUCCESS: Backup created: $BACKUP_FILE"

    # Compress the backup
    gzip "$BACKUP_DIR/$BACKUP_FILE"
    log_message "SUCCESS: Backup compressed: $BACKUP_FILE.gz"

    # Keep only last 30 backups (about 1 month)
    find "$BACKUP_DIR" -name "affine_backup_*.sql.gz" -mtime +30 -delete
    log_message "INFO: Cleaned up old backups (kept last 30)"

    # Show backup size
    BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE.gz" | cut -f1)
    log_message "INFO: Backup size: $BACKUP_SIZE"

else
    log_message "ERROR: Backup failed"
    exit 1
fi

log_message "Backup process completed"



# If you ever need to restore:
# gunzip -c /home/bryanwi09/docker/affine/backups/affine_backup_YYYYMMDD_HHMMSS.sql.gz | docker exec -i affine_postgres psql -U affine -d affine