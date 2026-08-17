# Error Handling — Bash Cheatsheet

Production Bash scripts should fail safely, detect errors early, clean up resources, and provide meaningful feedback.

## Standard Header

#!/usr/bin/env bash
set -euo pipefail

-e           → Exit on command failure
-u           → Exit on undefined variables
-o pipefail  → Pipeline fails if any command fails
-E           → ERR trap is inherited by functions

## Exit Codes

Every command returns an exit status:

0       → Success
1       → General error
2       → Command misuse
126     → Permission denied
127     → Command not found
128+N   → Fatal error caused by signal N

Check status:

command
echo "$?"

Better:

if ! command; then
    echo "Command failed" >&2
fi

Custom exit codes:

readonly EXIT_SUCCESS=0
readonly EXIT_ERROR=1
readonly EXIT_USAGE=2
readonly EXIT_CONFIG=3

die() {
    echo "ERROR: $*" >&2
    exit "$EXIT_ERROR"
}

validate_config() {
    [[ -f "$config" ]] || return "$EXIT_CONFIG"
    return "$EXIT_SUCCESS"
}

Always document your script's exit codes.

## && and ||

Run only when previous command succeeds:

command && echo "Success"

Run fallback when previous command fails:

command || echo "Failed"

Examples:

ls /tmp >/dev/null && echo "Directory exists"

ls /nonexistent 2>/dev/null || echo "Directory not found"

## trap — Cleanup & Error Handling

Use `trap` to execute code when the script exits or receives signals.

cleanup() {
    rm -f "$temp_file"
    echo "Cleanup complete"
}

trap cleanup EXIT

Handle signals:

trap 'echo "Interrupted!"; exit 130' INT
trap 'echo "Terminated!"; exit 143' TERM

Error handler:

on_error() {
    local line="$1"
    local code="$2"
    echo "Error on line $line: exit code $code" >&2
}

trap 'on_error "$LINENO" "$?"' ERR

## Common Signals

EXIT  → Any script exit
ERR   → Command returns non-zero
INT   → Ctrl+C (signal 2)
TERM  → Termination request (signal 15)
HUP   → Terminal closed (signal 1)

## Multiple Cleanup Actions

cleanup_tasks=()

add_cleanup() {
    cleanup_tasks+=("$1")
}

run_cleanup() {
    for task in "${cleanup_tasks[@]}"; do
        eval "$task" || true
    done
}

trap run_cleanup EXIT

Example:

temp_file=$(mktemp)
add_cleanup "rm -f '$temp_file'"

temp_dir=$(mktemp -d)
add_cleanup "rm -rf '$temp_dir'"

## Retry Pattern

Retry failed commands with exponential backoff:

retry() {
    local max_attempts=${1:-3}
    local delay=${2:-1}
    local cmd="${@:3}"
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
        if eval "$cmd"; then
            return 0
        fi

        echo "Attempt $attempt failed, retrying in ${delay}s..." >&2
        sleep "$delay"
        ((attempt++))
        ((delay *= 2))
    done

    echo "All attempts failed" >&2
    return 1
}

Usage:

retry 3 2 curl -sf "https://api.example.com/health"

## Fallback Chain

Try multiple sources until one succeeds:

get_config() {
    cat "$1" 2>/dev/null ||
    cat "$HOME/.config/app.conf" 2>/dev/null ||
    cat "/etc/app/default.conf" 2>/dev/null ||
    echo "default_value"
}

## Temporarily Disable `set -e`

Use sparingly:

set +e
risky_command
status=$?
set -e

if [[ $status -ne 0 ]]; then
    handle_error "$status"
fi

Always re-enable `set -e` immediately.

## Assertions

Create reusable validation functions:

assert_not_empty() {
    local name="$1"
    local value="$2"
    [[ -n "$value" ]] || die "Assertion failed: $name must not be empty"
}

assert_file_exists() {
    local file="$1"
    [[ -f "$file" ]] || die "Assertion failed: File not found: $file"
}

assert_directory_exists() {
    local dir="$1"
    [[ -d "$dir" ]] || die "Assertion failed: Directory not found: $dir"
}

assert_command_exists() {
    local cmd="$1"
    command -v "$cmd" &>/dev/null ||
        die "Assertion failed: Command not found: $cmd"
}

assert_root() {
    [[ $EUID -eq 0 ]] || die "This script must be run as root"
}

Usage:

assert_command_exists "curl"
assert_file_exists "$config_file"
assert_not_empty "API_KEY" "$API_KEY"

## Common Mistakes

Bad:

cd /nonexistent
rm -rf *

If `cd` fails, commands may execute in the wrong directory.

Better:

cd /nonexistent || exit 1
rm -rf *

Or:

set -e
cd /nonexistent

## Pipeline Errors

Without `pipefail`, only the final command's status may be considered:

cat missing.txt | grep pattern

Use:

set -o pipefail
cat missing.txt | grep pattern

Now a failure in `cat` can make the pipeline fail.

## Cleanup on Errors

Bad:

temp=$(mktemp)
process_data > "$temp"
rm "$temp"

If `process_data` fails, cleanup may not happen.

Better:

temp=$(mktemp)
trap 'rm -f "$temp"' EXIT

process_data > "$temp"

The `EXIT` trap ensures the temporary file is removed when the script exits.

## Quick Reference

set -euo pipefail → Strict error handling
$?                → Last exit status
return N          → Return function status
exit N             → Exit script with status
&&                 → Run on success
||                 → Run on failure
trap ... EXIT      → Cleanup on exit
trap ... ERR       → Handle errors
trap ... INT       → Handle Ctrl+C
command -v         → Check dependency
mktemp             → Safe temporary file
die()              → Centralized fatal-error handling

## Golden Rules

1. Start production scripts with `set -euo pipefail` when appropriate.
2. Check important command failures explicitly.
3. Use `pipefail` for reliable pipeline error detection.
4. Use `trap ... EXIT` for cleanup.
5. Keep error messages meaningful and send them to `stderr`.
6. Document custom exit codes.
7. Validate files, directories, commands, and required variables before using them.
8. Use retries with backoff for transient failures.
9. Disable `set -e` only when necessary and re-enable it immediately.
10. Never leave temporary resources behind after an error.

**Detect → Handle → Clean Up → Exit Safely**
