#!/usr/bin/env bash
# logging.sh - Reusable logging library
#
#
# Task: Build a reusable logging library!

# Requirements:

# - Support DEBUG, INFO, WARN, ERROR levels
# - Include timestamps and PID
# - Output to both console and file
# - Configurable via environment variables

# Configuration (via environment)
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FILE="${LOG_FILE:-}"
LOG_FORMAT="${LOG_FORMAT:-text}"  # text or json

# Level values
declare -A LOG_LEVELS=(
    [DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3
)

# Initialize
_log_init() {
    if [[ -n "$LOG_FILE" ]]; then
        mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null
    fi
}

# Core log function
_log() {
    local level="$1"
    local message="$2"

    # Check level threshold
    local level_val=${LOG_LEVELS[$level]:-1}
    local threshold=${LOG_LEVELS[$LOG_LEVEL]:-1}
    [[ $level_val -lt $threshold ]] && return 0

    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local output

    if [[ "$LOG_FORMAT" == "json" ]]; then
        output=$(printf '{"ts":"%s","level":"%s","pid":%d,"msg":"%s"}' \\
            "$timestamp" "$level" "$$" "$message")
    else
        output="[$timestamp] [$$] $level: $message"
    fi

    # Output to console
    if [[ "$level" == "ERROR" || "$level" == "WARN" ]]; then
        echo "$output" >&2
    else
        echo "$output"
    fi

    # Output to file
    [[ -n "$LOG_FILE" ]] && echo "$output" >> "$LOG_FILE"
}

# Public functions
log_debug() { _log "DEBUG" "$*"; }
log_info()  { _log "INFO" "$*"; }
log_warn()  { _log "WARN" "$*"; }
log_error() { _log "ERROR" "$*"; }

# Initialize on source
_log_init

# Example usage when run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    log_debug "Debug message"
    log_info "Info message"
    log_warn "Warning message"
    log_error "Error message"
fi
