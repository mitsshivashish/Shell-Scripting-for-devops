# Bash Best Practices — Cheatsheet

Writing Bash scripts that work is one thing; writing scripts that are readable, maintainable, and robust is another. These practices help make scripts production-ready.

## Code Style

- Use consistent indentation: 2 or 4 spaces.
- Keep lines around 80–100 characters when practical.
- Always quote variables: `"$var"`.
- Prefer `[[ ]]` for tests.
- Prefer `func_name() {}` for functions.
- Always use a shebang: `#!/usr/bin/env bash` or `#!/bin/bash` when a specific path is required.

## Naming Conventions

Variables       → `lowercase_snake_case`
Constants       → `UPPERCASE_SNAKE_CASE`
Functions       → `lowercase_snake_case`
Private funcs   → `_function_name`
Booleans        → `is_`, `has_`, `can_`
Arrays          → Plural names

Examples:

user_name="john"
max_retries=3
config_file="/etc/app.conf"

readonly MAX_CONNECTIONS=100
readonly DEFAULT_TIMEOUT=30

get_user_input() { ... }
validate_config() { ... }
process_file() { ... }

is_valid=true
has_error=false
can_write=true

declare -a users=()
declare -a log_files=()
declare -A config_options=()

Prefer descriptive names:

user_count    # Good
cnt           # Less clear

config_file   # Good
cf            # Less clear

## Variable Scope

Use `local` inside functions to avoid accidentally changing global variables.

scope_demo() {
    local local_var="I'm local"
    global_var="I'm global"
    echo "Inside function: $local_var"
}

## Dependency Checks

Use `command -v` to check whether a required command exists.

check_command() {
    if command -v "$1" &>/dev/null; then
        echo "$1 is available"
    else
        echo "$1 is NOT available"
    fi
}

check_command "bash"
check_command "curl"

For multiple dependencies:

deps=(curl jq awk)

for cmd in "${deps[@]}"; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "Required command not found: $cmd" >&2
        exit 1
    }
done

## Script Organization

Recommended structure:

1. Shebang and header
2. Configuration / strict mode
3. Global variables
4. Functions
5. Main logic
6. Execution guard

Example:

#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

readonly DEFAULT_ENV="staging"
readonly DEFAULT_TIMEOUT=60

usage() {
    echo "Usage: $SCRIPT_NAME [OPTIONS]"
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

die() {
    echo "ERROR: $*" >&2
    exit 1
}

main() {
    # Parse arguments
    # Validate inputs
    # Execute logic
    log "Operation complete"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

## Strict Mode

set -euo pipefail

-e           → Exit on command failure
-u           → Error on unset variables
-o pipefail  → Pipeline fails if any command fails

These help catch common scripting errors early. However, `set -e` has edge cases, so explicit checks may still be necessary.

## Defensive Programming

Validate inputs:

validate_input() {
    local input="$1"

    [[ -z "$input" ]] && die "Input required"
    [[ "$input" =~ ^[a-zA-Z0-9_-]+$ ]] || die "Invalid characters"

    return 0
}

Use safe defaults:

config_file="${CONFIG_FILE:-/etc/default.conf}"
timeout="${TIMEOUT:-30}"

Check files before operations:

[[ -f "$config_file" ]] || die "Config not found: $config_file"
[[ -r "$config_file" ]] || die "Config not readable: $config_file"

Check dependencies:

command -v curl >/dev/null 2>&1 || die "curl is required"

## Temporary Files

Use `mktemp` instead of predictable temporary filenames.

temp_file=$(mktemp) || die "Failed to create temp file"
trap 'rm -f "$temp_file"' EXIT

This ensures temporary files are cleaned up when the script exits.

## Quoting

Always quote variable expansions:

process_file "$input_file"    # Good
process_file $input_file      # Bad

Wrong:

rm -rf $dir/*
[ -f $file ]

Correct:

rm -rf "$dir"/*
[[ -f "$file" ]]

Quoting prevents unwanted word splitting and glob expansion.

## Modern Bash Syntax

Avoid deprecated/old syntax:

Wrong:

result=`command`
[ $a -eq $b ]
function myFunc {

Correct:

result=$(command)
[[ $a -eq $b ]]
myFunc() {

Prefer:

`$(command)` → Command substitution
`[[ ]]` → Bash conditional testing
`func_name() {}` → Function declaration

## Hardcoded Paths

Avoid fragile hardcoded paths:

Wrong:

cd /home/user/project
source /home/user/config.sh

Better:

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"
source "$SCRIPT_DIR/config.sh"

This makes scripts more portable.

## Error Handling

Don't blindly ignore important command failures.

Wrong:

cp important.txt backup/
rm important.txt

Better:

cp important.txt backup/ || die "Copy failed"
rm important.txt

Or use:

set -e

cp important.txt backup/
rm important.txt

For important operations, explicitly checking the exit status is often clearer.

## Documentation

A useful script header can contain:

#!/usr/bin/env bash
#
# backup.sh - Automated MySQL backup script
#
# Usage: backup.sh [-d database] [-o output_dir]
#
# Environment:
#   MYSQL_HOST     - Database host
#   MYSQL_USER     - Database user
#   MYSQL_PASSWORD - Database password
#
# Exit Codes:
#   0 - Success
#   1 - General error
#   2 - Missing dependency
#   3 - Configuration error

Document non-obvious functions:

# Validates database connection
# $1 = hostname
# $2 = username
# Returns 0 on success, 1 on failure
validate_connection() {
    local host="$1"
    local user="$2"
}

Use inline comments for complex logic, not obvious code.

## Common Mistakes

Not quoting variables:

rm -rf $dir/*
[ -f $file ]

Use:

rm -rf "$dir"/*
[[ -f "$file" ]]

Using old syntax:

result=`command`
[ $a -eq $b ]

Use:

result=$(command)
[[ $a -eq $b ]]

Hardcoding paths:

cd /home/user/project

Use:

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

Ignoring exit codes:

cp important.txt backup/
rm important.txt

Use:

cp important.txt backup/ || die "Copy failed"

## Quick Reference

Shebang       → `#!/usr/bin/env bash`
Strict mode   → `set -euo pipefail`
Variables     → `"$var"`
Tests         → `[[ condition ]]`
Functions     → `func_name() {}`
Local scope   → `local variable=value`
Dependencies  → `command -v command`
Temp files    → `mktemp`
Cleanup       → `trap`
Command       → `$(command)`
Constants     → `readonly CONSTANT=value`
Arrays        → `declare -a`
Associative   → `declare -A`

## Script Structure

Shebang
↓
Configuration
↓
Globals
↓
Functions
↓
main()
↓
Execution guard

## Golden Rules

1. Use `#!/usr/bin/env bash`.
2. Use `set -euo pipefail` when appropriate.
3. Always quote variable expansions.
4. Prefer `[[ ]]` over `[ ]`.
5. Use `$(command)` instead of backticks.
6. Use `local` inside functions.
7. Use descriptive names.
8. Validate inputs and dependencies early.
9. Check files before operating on them.
10. Use `mktemp` for temporary files.
11. Use `trap` for cleanup.
12. Avoid hardcoded paths.
13. Check important exit codes.
14. Document non-obvious logic.
15. Keep scripts readable rather than overly clever.

**Write Bash as if someone else will maintain it — because eventually, that someone might be you.**
