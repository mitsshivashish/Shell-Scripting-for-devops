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

# ==============================================================================
# VALIDATION
# ==============================================================================
 
validate_args() {
    [[ -z "$target" ]] && {
        log_error "Missing required argument: target"
        echo "Try '$SCRIPT_NAME --help' for usage." >&2
        exit $EXIT_USAGE
    }
 
    [[ -n "$config_file" && ! -f "$config_file" ]] && {
        die "Config file not found: $config_file"
    }
}
 
# ==============================================================================
# CLEANUP
# ==============================================================================
 
cleanup() {
    log_debug "Cleaning up..."
    # Add cleanup tasks here
}
 
trap cleanup EXIT
 
# ==============================================================================
# MAIN LOGIC
# ==============================================================================
 
do_work() {
    log_info "Processing target: $target"
 
    if [[ "$dry_run" == "true" ]]; then
        log_info "[DRY RUN] Would process $target"
        return 0
    fi
 
    # Main logic here
    log_debug "Doing the work..."
 
    log_info "Done!"
}
 
# ==============================================================================
# ENTRY POINT
# ==============================================================================
 
main() {
    parse_args "$@"
    validate_args
    do_work
}
 
# Only run main if executed (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```
 
---
 
## Library/Module Template
 
For reusable functions that get sourced by other scripts.
 
```bash
#!/usr/bin/env bash
#
# lib-name.sh - Reusable library for [purpose]
#
# Usage: source lib-name.sh
#
# Provides:
#   function1 - Description
#   function2 - Description
#
 
# Prevent double-sourcing
[[ -n "${_LIB_NAME_LOADED:-}" ]] && return 0
readonly _LIB_NAME_LOADED=1
 
# ==============================================================================
# CONFIGURATION
# ==============================================================================
 
# Library defaults (can be overridden before sourcing)
: "${LIB_DEBUG:=false}"
: "${LIB_LOG_FILE:=}"
 
# ==============================================================================
# INTERNAL FUNCTIONS
# ==============================================================================
 
_lib_log() {
    [[ "$LIB_DEBUG" == "true" ]] && echo "[lib-name] $*" >&2
}
 
_lib_validate() {
    # Internal validation
    :
}
 
# ==============================================================================
# PUBLIC API
# ==============================================================================
 
# @description Does something useful
# @param $1 input - The input value
# @return 0 on success, 1 on failure
# @example
#   result=$(lib_function1 "input")
lib_function1() {
    local input="${1:?Usage: lib_function1 <input>}"
 
    _lib_log "Processing: $input"
 
    # Implementation
    echo "Processed: $input"
    return 0
}
 
# @description Another useful function
# @param $1 arg1 - First argument
# @param $2 arg2 - Second argument (optional)
lib_function2() {
    local arg1="$1"
    local arg2="${2:-default}"
 
    _lib_log "Args: $arg1, $arg2"
 
    # Implementation
    return 0
}
 
# ==============================================================================
# INITIALIZATION
# ==============================================================================
 
_lib_validate
 
# Self-test when run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Running lib-name.sh self-test..."
    LIB_DEBUG=true
 
    echo "Testing lib_function1:"
    lib_function1 "test input"
 
    echo "Testing lib_function2:"
    lib_function2 "arg1" "arg2"
 
    echo "All tests passed!"
fi
```
 
---
 
## Service/Daemon Template
 
For long-running background scripts with signal handling.
 
```bash
#!/usr/bin/env bash
#
# service-name - Long-running service script
#
 
set -euo pipefail
 
readonly SCRIPT_NAME="$(basename "$0")"
readonly PID_FILE="/var/run/${SCRIPT_NAME}.pid"
readonly LOG_FILE="/var/log/${SCRIPT_NAME}.log"
 
running=true
 
# ==============================================================================
# LOGGING
# ==============================================================================
 
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$$] $*" | tee -a "$LOG_FILE"
}
 
# ==============================================================================
# SIGNAL HANDLERS
# ==============================================================================
 
handle_shutdown() {
    log "Received shutdown signal"
    running=false
}
 
handle_reload() {
    log "Reloading configuration..."
    # Reload logic here
}
 
trap handle_shutdown SIGTERM SIGINT
trap handle_reload SIGHUP
 
# ==============================================================================
# PID FILE MANAGEMENT
# ==============================================================================
 
create_pid_file() {
    echo $$ > "$PID_FILE"
    log "Created PID file: $PID_FILE"
}
 
remove_pid_file() {
    rm -f "$PID_FILE"
    log "Removed PID file"
}
 
check_already_running() {
    if [[ -f "$PID_FILE" ]]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            log "Already running with PID $pid"
            exit 1
        fi
        log "Removing stale PID file"
        rm -f "$PID_FILE"
    fi
}
 
# ==============================================================================
# MAIN LOOP
# ==============================================================================
 
do_work() {
    # Your service logic here
    log "Doing periodic work..."
    sleep 1
}
 
main() {
    check_already_running
    create_pid_file
 
    trap remove_pid_file EXIT
 
    log "Service started"
 
    while [[ "$running" == "true" ]]; do
        do_work
    done
 
    log "Service stopped"
}
 
main "$@"
```
 
---
 
## Template Comparison
 
| Template | Best For | Features |
|----------|----------|----------|
| Minimal | Quick scripts, prototypes | Error handling, cleanup |
| CLI | User-facing tools | Args, help, logging, validation |
| Library | Reusable functions | Sourcing guard, documentation |
| Service | Background processes | Signals, PID file, main loop |
 
---
 
## Summary
 
- **Start with templates** — don't reinvent the wheel
- **Minimal** — quick tasks with basic safety
- **CLI** — full-featured command-line tools
- **Library** — reusable code with source guard
- **Service** — long-running with signal handling
- **Customize** — add/remove features as needed
 
