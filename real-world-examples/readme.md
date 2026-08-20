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

#!/usr/bin/env bash
#
# monitor.sh - System monitoring script demonstration
#
# This is a simplified demo that shows monitoring concepts.
#

set -euo pipefail

echo "=== System Monitoring Demo ==="
echo ""

# Configuration
WARN_CPU=80
CRIT_CPU=90
WARN_MEM=80
CRIT_MEM=90
WARN_DISK=80
CRIT_DISK=90

# Status codes
readonly STATUS_OK=0
readonly STATUS_WARN=1
readonly STATUS_CRIT=2

# Logging
timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

#!/usr/bin/env bash
#
# deploy.sh - Application deployment with rollback
#
set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly DEPLOY_DIR="/var/www/app"
readonly RELEASES_DIR="$DEPLOY_DIR/releases"
readonly CURRENT_LINK="$DEPLOY_DIR/current"
readonly SHARED_DIR="$DEPLOY_DIR/shared"
readonly KEEP_RELEASES=5

# Logging
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
die() { log "ERROR: $*" >&2; exit 1; }

# Create new release directory
create_release() {
    local release_id="$(date +%Y%m%d%H%M%S)"
    local release_dir="$RELEASES_DIR/$release_id"

    log "Creating release: $release_id"

    mkdir -p "$release_dir"
    echo "$release_dir"
}

# Deploy code to release directory
deploy_code() {
    local release_dir="$1"
    local source="${2:-.}"

    log "Deploying code to $release_dir"

    # Copy application code
    rsync -av --exclude='.git' --exclude='node_modules' \
        "$source/" "$release_dir/"

    # Link shared directories
    ln -sf "$SHARED_DIR/logs" "$release_dir/logs"
    ln -sf "$SHARED_DIR/.env" "$release_dir/.env"
}

# Switch current symlink to new release
switch_release() {
    local release_dir="$1"

    log "Switching to release: $(basename "$release_dir")"

    ln -sfn "$release_dir" "$CURRENT_LINK"
}

# Cleanup old releases
cleanup_old_releases() {
    log "Cleaning up old releases (keeping $KEEP_RELEASES)"

    local releases=($(ls -1t "$RELEASES_DIR"))
    local to_delete=("${releases[@]:$KEEP_RELEASES}")

    for release in "${to_delete[@]}"; do
        log "Removing old release: $release"
        rm -rf "$RELEASES_DIR/$release"
    done
}

# Rollback to previous release
rollback() {
    local releases=($(ls -1t "$RELEASES_DIR"))

    [[ ${#releases[@]} -lt 2 ]] && die "No previous release to rollback to"

    local previous="${releases[1]}"
    log "Rolling back to: $previous"

    switch_release "$RELEASES_DIR/$previous"
    log "Rollback complete"
}

# Main deployment
deploy() {
    local source="${1:-.}"

    log "Starting deployment..."

    # Create release
    local release_dir
    release_dir=$(create_release)

    # Deploy code
    deploy_code "$release_dir" "$source"

    # Run build/install commands
    log "Installing dependencies..."
    (cd "$release_dir" && npm install --production 2>/dev/null || true)

    # Switch to new release
    switch_release "$release_dir"

    # Restart service
    log "Restarting application..."
    systemctl restart myapp 2>/dev/null || true

    # Cleanup
    cleanup_old_releases

    log "Deployment complete!"
}

# Parse arguments
case "${1:-deploy}" in
    deploy)   deploy "${2:-.}" ;;
    rollback) rollback ;;
    *)        echo "Usage: $SCRIPT_NAME {deploy|rollback} [source]" ;;
esac


#!/usr/bin/env bash
#
# log-analyzer.sh - Analyze access logs and generate reports
#
set -euo pipefail

readonly LOG_FILE="${1:-/var/log/nginx/access.log}"

log() { echo "[$(date '+%H:%M:%S')] $*"; }

analyze_logs() {
    [[ -f "$LOG_FILE" ]] || { echo "Log file not found: $LOG_FILE"; exit 1; }

    echo "=== Log Analysis Report ==="
    echo "File: $LOG_FILE"
    echo "Generated: $(date)"
    echo ""

    # Total requests
    local total=$(wc -l < "$LOG_FILE")
    echo "Total Requests: $total"
    echo ""

    # Requests per status code
    echo "--- Status Codes ---"
    awk '{print $9}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -10
    echo ""

    # Top 10 IPs
    echo "--- Top 10 IP Addresses ---"
    awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -10
    echo ""

    # Top 10 URLs
    echo "--- Top 10 URLs ---"
    awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -10
    echo ""

    # Requests per hour
    echo "--- Requests per Hour ---"
    awk '{print $4}' "$LOG_FILE" | cut -d: -f2 | sort | uniq -c
    echo ""

    # Error rate
    local errors=$(awk '$9 >= 400' "$LOG_FILE" | wc -l)
    local error_rate=$(echo "scale=2; $errors * 100 / $total" | bc)
    echo "Error Rate: $error_rate% ($errors errors)"
}

# Run with error handling
analyze_logs 2>/dev/null || echo "Analysis failed"
