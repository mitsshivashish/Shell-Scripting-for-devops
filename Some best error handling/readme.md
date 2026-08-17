# Error Handling — Bash

Production scripts must handle errors gracefully. A script that silently continues after a failure can cause serious damage. Error handling helps you catch failures early, clean up resources, and provide meaningful feedback.

---

## The `set` Options

Bash's `set` builtin enables important error-handling behaviors.

### Essential Options

| Option | Effect | Why Use It |
|---|---|---|
| `set -e` | Exit on error | Stops the script when a command fails |
| `set -u` | Exit on undefined variable | Catches typos and missing variables |
| `set -o pipefail` | Pipeline returns failure if a command fails | Detects errors inside pipelines |
| `set -E` | ERR trap inherited by functions | Makes error handlers work inside functions |

### Standard Production Header

```bash
#!/usr/bin/env bash
set -euo pipefail
```

This catches many common scripting errors automatically.

> `set -e` has edge cases with pipelines, conditions, and subshells. Use explicit checks when precise behavior is required.

---

## Exit Codes

Every command returns an exit status.

```text
0       → Success
1       → General error
2       → Misuse of command
126     → Permission denied
127     → Command not found
128+N   → Fatal error caused by signal N
```

Check the last command's exit code:

```bash
command
echo "$?"
```

A better approach is often to test the command directly:

```bash
if ! command; then
    echo "Command failed"
fi
```

### Custom Exit Codes

```bash
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
```

Always document your script's exit codes in the header so users and other scripts know what each status means.

---

## `&&` and `||`

Run the second command only when the first succeeds:

```bash
command && echo "Success"
```

Run the fallback only when the first command fails:

```bash
command || echo "Failed"
```

Examples:

```bash
ls /tmp >/dev/null && echo "Directory exists"

ls /nonexistent 2>/dev/null || echo "Directory not found"
```

---

## The `trap` Command

Use `trap` to execute cleanup or error-handling code when a script exits or receives a signal.

### Cleanup on Exit

```bash
cleanup() {
    rm -f "$temp_file"
    echo "Cleanup complete"
}

trap cleanup EXIT
```

`EXIT` runs whenever the script exits, including after an error.

### Handle Specific Signals

```bash
trap 'echo "Interrupted!"; exit 130' INT
trap 'echo "Terminated!"; exit 143' TERM
```

### Error Handler

```bash
on_error() {
    local line="$1"
    local code="$2"

    echo "Error on line $line: exit code $code" >&2
}

trap 'on_error "$LINENO" "$?"' ERR
```

---

## Common Signals

| Signal | Number | Cause |
|---|---:|---|
| `EXIT` | N/A | Script exits normally or with an error |
| `ERR` | N/A | Command returns non-zero |
| `INT` | 2 | `Ctrl+C` / interrupt |
| `TERM` | 15 | Termination request |
| `HUP` | 1 | Terminal closed |

---

## Multiple Cleanup Actions

For scripts managing multiple resources, centralize cleanup:

```bash
declare -a cleanup_tasks=()

add_cleanup() {
    cleanup_tasks+=("$1")
}

run_cleanup() {
    for task in "${cleanup_tasks[@]}"; do
        eval "$task" || true
    done
}

trap run_cleanup EXIT
```

Example:

```bash
temp_file=$(mktemp)
add_cleanup "rm -f '$temp_file'"

temp_dir=$(mktemp -d)
add_cleanup "rm -rf '$temp_dir'"
```

This makes sure all registered cleanup actions are attempted when the script exits.

---

## Error Recovery Patterns

Not every error should immediately terminate the script. Some failures are temporary or expected and can be handled gracefully.

### Retry with Exponential Backoff

```bash
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

    echo "All $max_attempts attempts failed" >&2
    return 1
}
```

Usage:

```bash
retry 3 2 curl -sf "https://api.example.com/health"
```

The delay increases after every failure:

```text
2s → 4s → 8s
```

This is useful for transient failures such as network requests.

### Try/Catch-Style Pattern

Bash does not have a traditional `try/catch`, but you can build a similar pattern:

```bash
try() {
    local result

    result=$("$@" 2>&1) && echo "$result" || {
        echo "Error: $result" >&2
        return 1
    }
}
```

### Fallback Chain

Try multiple sources until one succeeds:

```bash
get_config() {
    cat "$1" 2>/dev/null ||
    cat "$HOME/.config/app.conf" 2>/dev/null ||
    cat "/etc/app/default.conf" 2>/dev/null ||
    echo "default_value"
}
```

---

## Temporarily Disabling `set -e`

Sometimes a command is expected to fail and you need to inspect its exit status manually.

```bash
set +e

risky_command
status=$?

set -e

if [[ $status -ne 0 ]]; then
    handle_error "$status"
fi
```

> Use `set +e` sparingly. Re-enable `set -e` immediately after the specific operation.

---

## Assertion Functions

Assertions make common validation checks reusable.

```bash
assert_not_empty() {
    local name="$1"
    local value="$2"

    [[ -n "$value" ]] ||
        die "Assertion failed: $name must not be empty"
}

assert_file_exists() {
    local file="$1"

    [[ -f "$file" ]] ||
        die "Assertion failed: File not found: $file"
}

assert_directory_exists() {
    local dir="$1"

    [[ -d "$dir" ]] ||
        die "Assertion failed: Directory not found: $dir"
}

assert_command_exists() {
    local cmd="$1"

    command -v "$cmd" &>/dev/null ||
        die "Assertion failed: Command not found: $cmd"
}

assert_root() {
    [[ $EUID -eq 0 ]] ||
        die "This script must be run as root"
}
```

Usage:

```bash
assert_command_exists "curl"
assert_file_exists "$config_file"
assert_not_empty "API_KEY" "$API_KEY"
```

The script continues only if the required assertions pass.

---

## Common Mistakes

### 1. Not Checking Command Success

❌ Wrong:

```bash
cd /nonexistent
rm -rf *
```

If `cd` fails, the script may continue in the wrong directory.

✅ Correct:

```bash
cd /nonexistent || exit 1
rm -rf *
```

Or use strict mode:

```bash
set -e
cd /nonexistent
```

---

### 2. Ignoring Pipeline Errors

Without `pipefail`:

```bash
cat missing.txt | grep pattern
```

The final command's status can hide the failure of `cat`.

Use:

```bash
set -o pipefail
cat missing.txt | grep pattern
```

Now a failure in `cat` can cause the pipeline to fail.

---

### 3. Not Cleaning Up on Errors

❌ Wrong:

```bash
temp=$(mktemp)

process_data > "$temp"

rm "$temp"
```

If `process_data` fails, the temporary file may remain.

✅ Correct:

```bash
temp=$(mktemp)

trap 'rm -f "$temp"' EXIT

process_data > "$temp"
```

The `EXIT` trap ensures cleanup when the script exits.

---

## Quick Reference

| Syntax | Purpose |
|---|---|
| `set -e` | Exit on command failure |
| `set -u` | Detect unset variables |
| `set -o pipefail` | Detect pipeline failures |
| `set -E` | Inherit `ERR` traps |
| `$?` | Last exit status |
| `return N` | Return function status |
| `exit N` | Exit script |
| `cmd && cmd2` | Run `cmd2` on success |
| `cmd \|\| cmd2` | Run `cmd2` on failure |
| `trap ... EXIT` | Cleanup on exit |
| `trap ... ERR` | Handle errors |
| `trap ... INT` | Handle `Ctrl+C` |
| `command -v` | Check dependencies |
| `mktemp` | Create temporary files |

---

## Golden Rules

1. Start production scripts with `set -euo pipefail` when appropriate.
2. Check important command failures explicitly.
3. Use `pipefail` to detect failures inside pipelines.
4. Use `trap ... EXIT` for reliable cleanup.
5. Send error messages to `stderr`.
6. Document custom exit codes.
7. Validate files, directories, commands, and required variables before using them.
8. Use retries with backoff for temporary failures.
9. Disable `set -e` only when necessary and re-enable it immediately.
10. Never leave temporary resources behind after an error.

## Remember

**Detect → Handle → Clean Up → Exit Safely**
