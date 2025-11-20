#!/usr/bin/env bash
# backup_rotation.sh
# Simple rotating backup script. Creates timestamped archives of a source directory and keeps N latest.
#
# Usage:
#   ./backup_rotation.sh /path/to/src /path/to/backup_dir 7
# Where the last arg is number of backups to keep (default 7)

set -euo pipefail

SRC=${1:-}
DEST_DIR=${2:-/var/backups}
KEEP=${3:-7}

if [ -z "$SRC" ]; then
  echo "Usage: $0 /path/to/source /path/to/backup_dir [keep]"
  exit 1
fi

if [ ! -d "$SRC" ]; then
  echo "Source directory $SRC not found."
  exit 1
fi

mkdir -p "$DEST_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BASENAME=$(basename "$SRC")
ARCHIVE="${DEST_DIR}/${BASENAME}_backup_${TIMESTAMP}.tar.gz"

echo "Creating archive $ARCHIVE ..."
tar -czf "$ARCHIVE" -C "$(dirname "$SRC")" "$BASENAME"

echo "Removing backups older than the $KEEP newest..."
ls -1t "${DEST_DIR}/${BASENAME}_backup_"*.tar.gz 2>/dev/null | tail -n +$((KEEP+1)) | xargs -r rm --

echo "Backup complete."
