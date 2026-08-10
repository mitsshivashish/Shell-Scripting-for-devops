# Bash Functions

Functions let you reuse logic in Bash scripts.

## Define & Call

```
function greet() {
    echo "Hello $1"
}

# OR
greet() {
    echo "Hello $1"
}

# Call
greet "Alice"
```

## Function Arguments

```
$1      # First argument
$2      # Second argument
$#      # Number of arguments
$@      # All arguments
```

## Return Status

```
success() { return 0; }
fail()    { return 1; }

success
echo "$?"    # Previous exit status
```

`return` is for status codes (`0-255`), not data.

## Return Data

```
add() {
    echo $(( $1 + $2 ))
}

sum=$(add 10 20)
echo "$sum"
```

Use `echo` + `$(...)` to return/capture data.

## Local Variables

```
name="Global"

test_func() {
    local name="Local"
    echo "$name"
}

test_func
echo "$name"    # Global
```

## Quick Reference

```
name() { ... }        → Define function
name "arg"            → Call function
$1, $2...             → Arguments
$#                    → Argument count
$@                    → All arguments
local var             → Local variable
return 0              → Success
return 1              → Failure
$?                    → Previous exit status
$(func)               → Capture output
```

## Best Practices

```
Use lowercase function names.
Use local for function variables.
Use return for success/failure.
Use echo + $(...) for data.
Handle errors explicitly.
Keep related functions together.
```

## Key Rules

```
return      → Status (0-255)
echo + $()  → Return/capture data
local       → Prevent global side effects
$?          → Previous command status
```

# Bash Function Parameters

Function parameters let you pass values into functions.

## Positional Parameters

`$1`      → First argument  
`$2`      → Second argument  
`$3`      → Third argument  
`$@`      → All arguments  
`$*`      → All arguments  
`$#`      → Number of arguments  

### Example

```bash
show() {
    echo "First: $1"
    echo "Second: $2"
    echo "Count: $#"
}

show "alpha" "beta gamma"
```

## "$@" vs "$*"

`"$@"` → Preserves each argument separately  
`"$*"` → Joins all arguments into one string  

### Example

```bash
show() {
    for arg in "$@"; do
        echo "[$arg]"
    done
}

show "alpha beta" gamma
```

Output:

```text
[alpha beta]
[gamma]
```

> **Prefer `"$@"` when iterating or forwarding arguments.**

## shift

`shift` removes the first argument and moves the remaining arguments left.

```bash
process() {
    while (( $# )); do
        echo "Processing: $1"
        shift
    done
}

process "one" "two" "three"
```

Flow:

`one → shift → two → shift → three → shift → done`

## Forward Arguments

```bash
# ❌ Wrong
caller() {
    callee $@
}

# ✅ Correct
caller() {
    callee "$@"
}
```

> Always use `"$@"` to preserve spaces and argument boundaries.

## Quick Cheat Sheet

| Syntax | Meaning |
|---|---|
| `$1`, `$2`... | Positional arguments |
| `$#` | Argument count |
| `"$@"` | All arguments separately |
| `"$*"` | All arguments as one string |
| `shift` | Remove first argument |

## Golden Rules

- `"$@"` → Preferred for iteration/forwarding
- `"$*"` → Use when you intentionally want one string
- Always quote `"$@"` and `"$*"`
- Avoid unquoted `$@` / `$*` because spaces can break arguments


# Bash Return Values — Commands Cheatsheet

```bash
# Return status
return 0              # Success
return 1              # Failure
echo "$?"             # Get previous exit status

# Function success/failure
success() { return 0; }
fail() { return 1; }

# Return data
add() {
    echo $(( $1 + $2 ))
}

sum=$(add 10 32)
echo "$sum"

# Check function status
if result=$(my_function); then
    echo "$result"
else
    echo "Error" >&2
fi

# Standard output
echo "data"

# Error/log output
echo "Error occurred" >&2
```


# Bash Function Scope — Cheatsheet

```bash
# Global variable
count=0

# Changes global variable
inc() {
    count=$((count + 1))
}

# Local variable
inc_local() {
    local count=0
    count=$((count + 1))
    echo "$count"
}

# Export variable to child processes
export APP_FLAG=yes

# Export function (Bash-specific)
export -f inc
```

## Quick Reference

| Syntax | Meaning |
|---|---|
| `var=value` | Global by default |
| `local var=value` | Function-local |
| `export VAR=value` | Available to child processes |
| `export -f func` | Export function |
| `. file.sh` | Source in current shell |

## Rules

- `local` → Prevent global side effects
- `export` → Share with child processes
- Use `local` for function variables
- Use prefixes like `APP_` for globals

# Bash Recursive Functions — Cheatsheet

Recursion = a function calling itself.

## Factorial

```bash
factorial() {
    local n=$1

    if (( n <= 1 )); then
        echo 1
    else
        echo $(( n * $(factorial $((n-1))) ))
    fi
}

echo "$(factorial 5)"    # 120
```

**Base case is mandatory** to stop recursion.

## Directory Traversal

```bash
traverse() {
    local dir=$1

    for entry in "$dir"/*; do
        [ -e "$entry" ] || continue
        echo "$entry"

        if [ -d "$entry" ]; then
            traverse "$entry"
        fi
    done
}

traverse "."
```

## Quick Rules

```text
Base case     → Stops recursion
Recursive call → Function calls itself
local         → Keep variables scoped
"$dir"/*      → Quote paths safely
```

- Prefer **loops** for deep/large recursion.
- Deep recursion can hit system limits.
- Use **memoization/caching** for expensive repeated calculations.
- Always quote paths in recursive directory operations.
