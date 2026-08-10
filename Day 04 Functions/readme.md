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

$1      → First argument
$2      → Second argument
$3      → Third argument
$@      → All arguments
$*      → All arguments
$#      → Number of arguments

Example:

show() {
    echo "First: $1"
    echo "Second: $2"
    echo "Count: $#"
}

show "alpha" "beta gamma"

## "$@" vs "$*"

"$@" → Preserves each argument separately
"$*" → Joins all arguments into one string

Example:

show() {
    for arg in "$@"; do
        echo "[$arg]"
    done
}

show "alpha beta" gamma

Output:

[alpha beta]
[gamma]

Prefer "$@" when iterating or forwarding arguments.

## shift

shift removes the first argument and moves the remaining arguments left.

process() {
    while (( $# )); do
        echo "Processing: $1"
        shift
    done
}

process "one" "two" "three"

Flow:

one → shift → two → shift → three → shift → done

## Forward Arguments

# ❌ Wrong
caller() {
    callee $@
}

# ✅ Correct
caller() {
    callee "$@"
}

Always use "$@" to preserve spaces and argument boundaries.

## Quick Cheat Sheet

$1, $2...  → Positional arguments
$#         → Argument count
"$@"       → All arguments separately
"$*"       → All arguments as one string
shift      → Remove first argument

## Golden Rules

"$@" → Preferred for iteration/forwarding
"$*" → Use when you intentionally want one string
Quote "$@" and "$*"
Avoid unquoted $@ / $* because spaces can break arguments.

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
