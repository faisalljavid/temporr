#!/bin/bash
# Directories to back up
DIRECTORIES=("/home" "/etc" "/var/www")
# Backup location
BACKUP_LOCATION="/backup"
# Number of days to keep backups
RETENTION_DAYS=7
# Email address for notifications
EMAIL="admin@lpu.com"
# Get current date
DATE=$(date +%Y-%m-%d)
# Ensure backup directory exists
ensure_backup_directory() {
if [ ! -d "$BACKUP_LOCATION" ]; then
mkdir -p "$BACKUP_LOCATION"
echo "Created backup directory: $BACKUP_LOCATION"
fi
}
# Create backup
create_backup() {
for DIR in "${DIRECTORIES[@]}"; do
BASENAME=$(basename "$DIR")
BACKUP_FILE="$BACKUP_LOCATION/${BASENAME}_backup_$DATE.tar.gz"
if tar -czf "$BACKUP_FILE" "$DIR"; then
echo "Backup of $DIR completed successfully."
else
echo "Backup of $DIR failed." >&2
exit 1
fi
done
}
# Cleanup old backups
cleanup_backups() {
find "$BACKUP_LOCATION" -type f -name "*.tar.gz" -mtime +$RETENTION_DAYS -exec
rm {} \;
}
# Send notification email
send_notification() {
SUBJECT="Backup Report for $DATE"
BODY="Backup completed successfully on $DATE. Old backups older than
$RETENTION_DAYS days have been deleted."
if ! echo "$BODY" | mail -s "$SUBJECT" "$EMAIL"; then
echo "Failed to send email notification" >&2
exit 1
fi
}
# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
echo "This script must be run as root" >&2
exit 1
fi
# Main script
ensure_backup_directory
create_backup
cleanup_backups
send_notification
echo "Backup process completed."
