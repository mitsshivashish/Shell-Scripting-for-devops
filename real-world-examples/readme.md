# Real-World Examples

**Advanced ~35 min read**

Theory becomes powerful when applied to real problems. This final lesson presents complete, production-ready scripts that demonstrate everything you've learned. Study these examples, adapt them to your needs, and use them as references for your own projects!

## Example 1: Backup Script

A complete backup system with rotation, compression, and verification.

### Backup Script

```bash
#!/usr/bin/env bash
#
# backup.sh - Simple backup script demonstration
#
# This is a simplified demo version that runs in the tutorial.
# A full production version would have more features.
#

set -euo pipefail

echo "=== Backup Script Demo ==="
echo ""

# Configuration
BACKUP_DIR="/tmp/backup_demo"
SOURCE_DIR="/tmp/backup_source"
RETENTION_DAYS=7

# Logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >&2
}

# Cleanup handler
cleanup() {
    rm -rf "$SOURCE_DIR" "$BACKUP_DIR" 2>/dev/null || true
}

trap cleanup EXIT

# Setup demo environment
setup_demo() {
    log "Setting up demo environment..."

    # Create source files
    mkdir -p "$SOURCE_DIR"
    echo "Important data file 1" > "$SOURCE_DIR/data1.txt"
    echo "Important data file 2" > "$SOURCE_DIR/data2.txt"
    echo "Configuration settings" > "$SOURCE_DIR/config.conf"
    mkdir -p "$SOURCE_DIR/subdir"
    echo "Nested file" > "$SOURCE_DIR/subdir/nested.txt"

    # Create backup directory
    mkdir -p "$BACKUP_DIR"
}


## Key Features
- Configurable via environment or command-line
- Compression with gzip
- Automatic rotation of old backups
- Verification of backup integrity
- Logging with timestamps
- Error handling and cleanup
- Cron Setup

Schedule daily backups with:

# /etc/cron.d/backup
0 2 * * * root /opt/scripts/backup.sh -s /var/data -d /backup -r 7 >> /var/log/backup.log 2>&1
