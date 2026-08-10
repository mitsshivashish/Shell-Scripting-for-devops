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

