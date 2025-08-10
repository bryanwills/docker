#!/bin/bash

# Source the .env file to get PG_HOST
source .env

# Function to perform backup
perform_backup() {
    echo "Enter the file name for the backup:"
    read backup_file_name
    docker exec -t --user postgres "$PG_HOST" pg_dumpall -c -U postgres > "$backup_file_name.sql"
    echo "Backup complete. File saved as: $backup_file_name.sql"
}

# Function to perform restore
perform_restore() {
    echo "Enter the name of the backup file to restore:"
    read restore_file_name
    cat "$restore_file_name" | docker exec -i --user postgres "$PG_HOST" psql -U postgres
}

# Main script
echo "Choose an operation:"
echo "1. Backup"
echo "2. Restore"
read choice

case $choice in
    1)
        perform_backup
        ;;
    2)
        perform_restore
        ;;
    *)
        echo "Invalid choice. Please choose 1 or 2."
        ;;
esac
