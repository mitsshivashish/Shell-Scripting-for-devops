# Bash Script Templates
 
Battle-tested templates to use as starting points for your own scripts. Copy, paste, and customize.
 
## Table of Contents
 
- [Minimal Script Template](#minimal-script-template)
- [Full CLI Application Template](#full-cli-application-template)
- [Library/Module Template](#librarymodule-template)
- [Service/Daemon Template](#servicedaemon-template)
- [Template Comparison](#template-comparison)
- [Summary](#summary)
---
 
## Minimal Script Template
 
For quick scripts that still need basic safety features.
 
**Includes:** `set -euo pipefail` for safety, script directory detection, basic logging functions, cleanup trap, main function pattern.
 
**When to use:** Small utility scripts, automation tasks, quick prototypes. Add more structure as the script grows.
 
```bash
#!/usr/bin/env bash
#
# script-name - Brief description of what this script does
#
 
set -euo pipefail
IFS=$'\n\t'
 
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
output_dir="${1:-/tmp}"
 
# ==============================================================================
# LOGGING
# ==============================================================================
 
log() { echo "[$(date '+%H:%M:%S')] $*"; }
 
die() {
    log "ERROR: $*" >&2
    exit 1
}
 
# ==============================================================================
# CLEANUP
# ==============================================================================
 
cleanup() {
    log "Cleaning up..."
}
 
trap cleanup EXIT
 
# ==============================================================================
# MAIN
# ==============================================================================
 
main() {
    log "Script started"
    log "Script dir: $SCRIPT_DIR"
    log "Output dir: $output_dir"
 
    # Your logic here
    log "Doing work..."
 
    # Example: check dependencies
    command -v bash &>/dev/null || die "bash not found"
 
    # Example: validate inputs
    [[ -d "$output_dir" ]] || die "Output dir not found: $output_dir"
 
    log "Script completed successfully"
}
 
# Run main
main "$@"
 
# ==============================================================================
# TEMPLATE NOTES
# ==============================================================================
#
# This minimal template includes:
#   - set -euo pipefail for safety
#   - Script directory detection
#   - Basic logging functions
#   - Cleanup trap
#   - Main function pattern
#
# Add as needed:
#   - Argument parsing (getopts or manual)
#   - More detailed help/usage
#   - Configuration file loading
#   - More sophisticated logging
```
 
**Example output:**
 
```
[17:54:30] Script started
[17:54:30] Script dir: /code
[17:54:30] Output dir: /tmp
[17:54:30] Doing work...
[17:54:30] Script completed successfully
```
 
---
 
## Full CLI Application Template
 
For user-facing command-line tools with argument parsing, help, and logging.
 
```bash
#!/usr/bin/env bash
#
# script-name - Brief description of what this script does
#
# Usage: script-name [OPTIONS] <target>
#
# Author: Your Name
# Date: 2024-01-15
# Version: 1.0.0
#
 
set -euo pipefail
IFS=$'\n\t'
 
# ==============================================================================
# CONSTANTS
# ==============================================================================
 
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VERSION="1.0.0"
 
# Exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_ERROR=1
readonly EXIT_USAGE=2
 
# ==============================================================================
# DEFAULTS
# ==============================================================================
 
verbose=false
dry_run=false
config_file=""
log_level="INFO"
 
# ==============================================================================
# LOGGING
# ==============================================================================
 
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
log_info() { log "INFO: $*"; }
log_warn() { log "WARN: $*" >&2; }
log_error() { log "ERROR: $*" >&2; }
log_debug() { [[ "$verbose" == "true" ]] && log "DEBUG: $*"; }
 
die() {
    log_error "$*"
    exit $EXIT_ERROR
}
 
# ==============================================================================
# USAGE
# ==============================================================================
 
show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] <target>
 
Brief description of what this script does.
 
Arguments:
    target              Description of required argument
 
Options:
    -c, --config FILE   Configuration file path
    -n, --dry-run       Show what would be done
    -v, --verbose       Enable verbose output
    -h, --help          Show this help message
    --version           Show version number
 
Examples:
    $SCRIPT_NAME -v target
    $SCRIPT_NAME --config=app.conf target
 
Environment:
    SCRIPT_CONFIG       Default config file path
    SCRIPT_LOG_LEVEL    Log level (DEBUG, INFO, WARN, ERROR)
EOF
}
 
show_version() {
    echo "$SCRIPT_NAME version $VERSION"
}
 
# ==============================================================================
# ARGUMENT PARSING
# ==============================================================================
 
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit $EXIT_SUCCESS
                ;;
            --version)
                show_version
                exit $EXIT_SUCCESS
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -n|--dry-run)
                dry_run=true
                shift
                ;;
            -c|--config)
                config_file="$2"
                shift 2
                ;;
            --config=*)
                config_file="${1#*=}"
                shift
                ;;
            --)
                shift
                break
                ;;
            -*)
                die "Unknown option: $1"
                ;;
            *)
                break
                ;;
        esac
    done
 
    # Remaining args are positional
    target="${1:-}"
}
