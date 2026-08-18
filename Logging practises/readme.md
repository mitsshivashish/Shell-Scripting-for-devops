# Logging

Advanced ~25 min read

Good logging transforms debugging from guesswork into detective work. Scripts that silently do their job are great—until something goes wrong. This lesson teaches you to implement professional logging that helps you understand exactly what your script did, when, and why it failed!

## Basic Logging Functions

Start with simple logging functions that add timestamps and identify message types.

### Essential Logging Functions

~~~bash
#!/usr/bin/env bash

# Timestamp function
timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Basic log function
log() {
    echo "[$(timestamp)] $*"
}

# Error logging (to stderr)
log_error() {
    echo "[$(timestamp)] ERROR: $*" >&2
}

# Warning logging
log_warn() {
    echo "[$(timestamp)] WARN: $*" >&2
}

# Info logging
log_info() {
    echo "[$(timestamp)] INFO: $*"
}

# Debug logging (controlled by variable)
log_debug() {
    [[ "${DEBUG:-false}" == "true" ]] && echo "[$(timestamp)] DEBUG: $*"
}
~~~

**stderr vs stdout:** Write errors and warnings to stderr (`>&2`) so they appear even when stdout is redirected. This keeps error messages visible: `./script.sh > output.log` still shows errors.

## Implementing Log Levels

Log levels let you control verbosity without changing code.

~~~bash
#!/usr/bin/env bash

# Define log levels as numbers
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3

# Current log level (configurable)
CURRENT_LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

# Color codes (optional, for terminal output)
readonly COLOR_DEBUG="\033[36m"  # Cyan
readonly COLOR_INFO="\033[32m"   # Green
readonly COLOR_WARN="\033[33m"   # Yellow
readonly COLOR_ERROR="\033[31m"  # Red
readonly COLOR_RESET="\033[0m"

# Core logging function
_log() {
    local level=$1
    local level_name=$2
    local color=$3
    shift 3
    local message="$*"

    # Check if we should log this level
    [[ $level -lt $CURRENT_LOG_LEVEL ]] && return 0

    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Output with color if terminal supports it
    if [[ -t 1 ]]; then
        echo -e "[${timestamp}] ${color}${level_name}${COLOR_RESET}: ${message}"
    else
        echo "[${timestamp}] ${level_name}: ${message}"
    fi
}
~~~

### Standard Log Levels

| Level | Value | When to Use |
|---|---:|---|
| DEBUG | 0 | Detailed diagnostic information |
| INFO | 1 | General progress information |
| WARN | 2 | Warning conditions, recoverable issues |
| ERROR | 3 | Error conditions, but script continues |
| FATAL | 4 | Critical errors, script will exit |

**Default Level:** Set INFO as default. Use DEBUG only when troubleshooting. In production, WARN or ERROR reduces noise.

## Logging to Files

For long-running scripts and services, log to files for later analysis.

~~~bash
# Setup log file
LOG_FILE="${LOG_FILE:-/var/log/myapp/app.log}"
LOG_DIR="$(dirname "$LOG_FILE")"

# Ensure log directory exists
setup_logging() {
    mkdir -p "$LOG_DIR" || {
        echo "Cannot create log directory: $LOG_DIR" >&2
        exit 1
    }

    # Test write access
    touch "$LOG_FILE" || {
        echo "Cannot write to log file: $LOG_FILE" >&2
        exit 1
    }
}

# Log to both file and stdout
log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] [$$] $*"
    echo "$message" | tee -a "$LOG_FILE"
}

# Log only to file (silent mode)
log_quiet() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$$] $*" >> "$LOG_FILE"
}

# Redirect all output to log file
exec_with_logging() {
    exec > >(tee -a "$LOG_FILE") 2>&1
}

# Log with rotation (simple)
rotate_log() {
    local max_size=${1:-10485760}  # 10MB default

    if [[ -f "$LOG_FILE" ]]; then
        local size
        size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE")

        if [[ $size -gt $max_size ]]; then
            mv "$LOG_FILE" "$LOG_FILE.$(date +%Y%m%d%H%M%S)"
            touch "$LOG_FILE"
            log "Log rotated"
        fi
    fi
}
~~~

**Log File Permissions:** Be careful with log file permissions. Sensitive data in logs should not be world-readable. Use `chmod 640` for log files.

## Structured Logging

For scripts that integrate with log aggregators, use structured formats like JSON.

~~~bash
# JSON logging
log_json() {
    local level="$1"
    local message="$2"
    shift 2

    # Build extra fields
    local extra=""
    while [[ $# -gt 0 ]]; do
        extra="$extra, \"$1\": \"$2\""
        shift 2
    done

    printf '{"timestamp":"%s","level":"%s","pid":%d,"message":"%s"%s}\n' \
        "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        "$level" \
        "$$" \
        "$message" \
        "$extra"
}

# Usage
log_json "INFO" "User logged in" "user" "john" "ip" "192.168.1.1"
~~~

**Output:**

~~~text
{"timestamp":"2024-01-15T10:30:00Z","level":"INFO","pid":1234,"message":"User logged in", "user": "john", "ip": "192.168.1.1"}
~~~

### Key-Value Logging

~~~bash
log_kv() {
    local level="$1"
    local message="$2"
    shift 2

    local kv=""
    while [[ $# -gt 0 ]]; do
        kv="$kv $1=\"$2\""
        shift 2
    done

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $level: $message$kv"
}

# Usage
log_kv "INFO" "Request completed" "method" "GET" "path" "/api" "status" "200"
~~~

## Debug Logging Techniques

Advanced techniques for troubleshooting complex scripts.

### Function Entry/Exit Logging

~~~bash
log_function() {
    local func="${FUNCNAME[1]}"
    log_debug "Entering: $func($*)"
}

log_function_exit() {
    local func="${FUNCNAME[1]}"
    local code="${1:-0}"
    log_debug "Exiting: $func (code=$code)"
}

# Wrap function with logging
process_data() {
    log_function "$@"

    # Do work...
    local result="success"

    log_function_exit 0
    return 0
}
~~~

### Variable Dump

~~~bash
dump_vars() {
    log_debug "=== Variable Dump ==="
    local var

    for var in "$@"; do
        log_debug "  $var=${!var:-}"
    done
}
~~~

### Execution Trace for Specific Section

~~~bash
trace_on() {
    set -x
}

trace_off() {
    set +x
}
~~~

### Conditional Trace

~~~bash
[[ "${TRACE:-false}" == "true" ]] && set -x
~~~

### Stack Trace on Error

~~~bash
print_stack() {
    local i

    echo "Stack trace:" >&2

    for ((i=1; i<${#FUNCNAME[@]}; i++)); do
        echo "  $i: ${FUNCNAME[i]}() at ${BASH_SOURCE[i]}:${BASH_LINENO[i-1]}" >&2
    done
}

trap 'print_stack' ERR
~~~

## Common Mistakes

### 1. Logging Sensitive Data

~~~bash
# Wrong - password in logs!
log "Connecting with password: $DB_PASSWORD"

# Correct - mask sensitive data
log "Connecting with password: ****"
log "Connecting as user: $DB_USER"
~~~

### 2. No Timestamps

~~~bash
# Wrong - no context
echo "Starting backup"
~~~

~~~bash
# Correct - when did it happen?
log "Starting backup"
~~~

### 3. Debug Code Left in Production

~~~bash
# Wrong - always prints debug
echo "DEBUG: var=$var"

# Correct - controlled by flag
log_debug "var=$var"
~~~

Enable it only when needed:

~~~bash
DEBUG=true ./script.sh
~~~

## Practical Logging Pattern

A reusable logging setup can make Bash scripts much easier to maintain.

~~~bash
#!/usr/bin/env bash

set -euo pipefail

LOG_LEVEL=${LOG_LEVEL:-1}

readonly LOG_DEBUG=0
readonly LOG_INFO=1
readonly LOG_WARN=2
readonly LOG_ERROR=3

timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

log() {
    local level="$1"
    local name="$2"
    shift 2

    [[ "$level" -lt "$LOG_LEVEL" ]] && return 0

    echo "[$(timestamp)] $name: $*"
}

debug() {
    log "$LOG_DEBUG" "DEBUG" "$@"
}

info() {
    log "$LOG_INFO" "INFO" "$@"
}

warn() {
    log "$LOG_WARN" "WARN" "$@" >&2
}

error() {
    log "$LOG_ERROR" "ERROR" "$@" >&2
}

info "Starting deployment"
debug "Environment: ${ENVIRONMENT:-staging}"

if [[ -f "config.conf" ]]; then
    info "Configuration file found"
else
    error "Configuration file not found"
    exit 1
fi

info "Deployment completed successfully"
~~~

## Logging in DevOps Automation

Logging becomes especially important in DevOps because scripts are often executed automatically by CI/CD pipelines, cron jobs, deployment systems, or monitoring tools.

For example, a deployment script should make it obvious:

~~~text
[2026-08-18 17:00:01] INFO: Starting deployment
[2026-08-18 17:00:02] INFO: Checking dependencies
[2026-08-18 17:00:03] INFO: Building application
[2026-08-18 17:01:15] INFO: Build completed
[2026-08-18 17:01:16] INFO: Deploying application
[2026-08-18 17:02:01] ERROR: Deployment failed
~~~

Instead of:

~~~text
Starting...
Done
Error
~~~

The first approach gives you enough context to understand **what happened, when it happened, and where it failed**.

## Quick Reference

| Command / Pattern | Purpose |
|---|---|
| `date '+%Y-%m-%d %H:%M:%S'` | Generate timestamps |
| `echo "msg"` | Write normal log output |
| `echo "msg" >&2` | Write to stderr |
| `tee -a "$LOG_FILE"` | Display and append to log |
| `>> "$LOG_FILE"` | Append output to a log file |
| `set -x` | Enable command tracing |
| `set +x` | Disable command tracing |
| `FUNCNAME` | Access function call information |
| `BASH_SOURCE` | Identify source file |
| `BASH_LINENO` | Identify source line |
| `trap '...' ERR` | Run handler on errors |
| `$$` | Current process ID |
| `DEBUG=true` | Enable custom debug logging |

## Best Practices

- Always include timestamps in important logs.
- Use different log levels such as `DEBUG`, `INFO`, `WARN`, and `ERROR`.
- Send errors and warnings to `stderr`.
- Never log passwords, API keys, tokens, or other secrets.
- Use structured logging when logs will be consumed by automation or log aggregation systems.
- Include process IDs when multiple instances may run simultaneously.
- Rotate large log files.
- Use `set -x` carefully because it can expose sensitive values.
- Keep debug logging disabled by default in production.
- Make logs explain **what happened, when it happened, and why it happened**.
- Prefer reusable logging functions instead of scattered `echo` statements.
