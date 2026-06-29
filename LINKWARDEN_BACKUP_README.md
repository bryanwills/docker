# Linkwarden Database Backup & Restore Guide

This guide explains how to use the automated backup and restore system for your Linkwarden PostgreSQL database.

## 📁 Files Overview

- `backup-linkwarden.sh` - Automated backup script
- `restore-linkwarden.sh` - Database restore script
- `backups/linkwarden/` - Directory containing all backup files
- `LINKWARDEN_BACKUP_README.md` - This documentation file

## 🔄 Automated Backups

### Schedule
- **Frequency**: Every 6 hours (00:00, 06:00, 12:00, 18:00)
- **Retention**: 30 days (older backups are automatically deleted)
- **Location**: `/home/bryanwi09/docker/backups/linkwarden/`
- **Logs**: `/home/bryanwi09/docker/backups/linkwarden/backup.log`

### Backup Features
- ✅ Compressed backups (gzip) to save disk space
- ✅ Automatic cleanup of old backups (30-day retention)
- ✅ Symlink to latest backup for easy access
- ✅ Detailed logging with timestamps
- ✅ Error handling and validation
- ✅ Runs every 6 hours for frequent backups

## 🛠️ Manual Operations

### Create a Manual Backup
```bash
cd /home/bryanwi09/docker
./backup-linkwarden.sh
```

### List Available Backups
```bash
./restore-linkwarden.sh --list
```

### Restore from Latest Backup
```bash
./restore-linkwarden.sh
```

### Restore from Specific Backup
```bash
./restore-linkwarden.sh linkwarden_backup_20241201_120000.sql.gz
```

## 📊 Backup File Naming Convention

Backups are named with the following pattern:
```
linkwarden_backup_YYYYMMDD_HHMMSS.sql.gz
```

Example: `linkwarden_backup_20241201_143022.sql.gz`
- Date: December 1, 2024
- Time: 2:30:22 PM
- Format: Compressed SQL dump

## 🔧 Configuration

### Backup Settings
You can modify these settings in `backup-linkwarden.sh`:

```bash
BACKUP_DIR="/home/bryanwi09/docker/backups/linkwarden"
CONTAINER_NAME="linkwarden-postgres"
DB_NAME="linkwarden"
DB_USER="linkwarden"
RETENTION_DAYS=30  # Keep backups for 30 days
```

### Cron Job
The automated backup runs via cron:
```bash
# View current cron jobs
crontab -l

# Edit cron jobs
crontab -e
```

## 🚨 Disaster Recovery Process

If your Linkwarden database gets corrupted or you lose data:

1. **Stop Linkwarden** (if running):
   ```bash
   docker stop linkwarden
   ```

2. **List available backups**:
   ```bash
   ./restore-linkwarden.sh --list
   ```

3. **Restore from backup**:
   ```bash
   # Restore from latest backup
   ./restore-linkwarden.sh

   # OR restore from specific backup
   ./restore-linkwarden.sh linkwarden_backup_20241201_120000.sql.gz
   ```

4. **Verify restoration**:
   ```bash
   docker ps  # Check if containers are running
   # Visit https://links.bryanwills.dev to verify data
   ```

## 📈 Monitoring & Maintenance

### Check Backup Status
```bash
# View backup log
tail -f /home/bryanwi09/docker/backups/linkwarden/backup.log

# Check backup directory
ls -la /home/bryanwi09/docker/backups/linkwarden/

# Check disk usage
du -sh /home/bryanwi09/docker/backups/linkwarden/
```

### Manual Cleanup
```bash
# Remove backups older than 7 days
find /home/bryanwi09/docker/backups/linkwarden/ -name "*.sql.gz" -mtime +7 -delete
```

## ⚠️ Important Notes

1. **Backup Frequency**: Daily backups are sufficient for most use cases
2. **Storage Space**: Each backup is compressed and typically small (16KB for empty database)
3. **Database Lock**: Backups use `pg_dump` which doesn't lock the database
4. **Restore Process**: Restore will completely replace the current database
5. **Container Management**: Restore script automatically stops/starts containers

## 🔍 Troubleshooting

### Backup Fails
- Check if PostgreSQL container is running: `docker ps | grep postgres`
- Check backup directory permissions: `ls -la backups/linkwarden/`
- View error logs: `tail backup.log`

### Restore Fails
- Ensure PostgreSQL container is running
- Check backup file exists and is readable
- Verify database credentials in restore script

### Cron Job Not Running
- Check cron service: `systemctl status cron`
- Check cron logs: `grep CRON /var/log/syslog`
- Verify cron job syntax: `crontab -l`

## 📞 Support

If you encounter issues:
1. Check the backup log: `tail /home/bryanwi09/docker/backups/linkwarden/backup.log`
2. Verify container status: `docker ps`
3. Test manual backup: `./backup-linkwarden.sh`
4. Test manual restore: `./restore-linkwarden.sh --list`

---

**Last Updated**: September 5, 2025
**Backup System Version**: 1.0
