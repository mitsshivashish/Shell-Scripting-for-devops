# Command Line Arguments

Advanced ~30 min read

Professional command-line tools accept arguments and options that control their behavior. This lesson teaches you to parse arguments using `getopts`, handle flags and options, and create user-friendly CLI interfaces that follow Unix conventions!

## Positional Arguments

Start with the basics: accessing arguments passed to your script.

### Example

```bash
#!/usr/bin/env bash

# Command Line Arguments Demo

echo "=== Positional Arguments Demo ==="
echo ""

# Simulating script arguments for demo
set -- "file1.txt" "file2.txt" "hello world" "--verbose"

echo "--- Special Variables ---"
echo "\$0 (script name): $0"
echo "\$# (arg count): $#"
echo "\$1 (first arg): $1"
echo "\$2 (second arg): $2"
echo "\$3 (third arg): $3"
echo "\$4 (fourth arg): $4"

echo ""

echo "--- \$@ vs \$* ---"
echo "Using \"\$@\" (preserves quoting):"
count=1
for arg in "$@"; do
    echo "  Arg $count: '$arg'"
    ((count++))
done

echo ""
echo "Using \$* (without quotes, word splitting):"
count=1
for arg in $*; do
    echo "  Arg $count: '$arg'"
    ((count++))
done

echo ""

# Using shift
echo "--- Using shift ---"
echo "Before shift:"
echo "  \$1 = $1"
echo "  \$2 = $2"
echo "  \$# = $#"

shift  # Remove first argument

echo "After shift:"
echo "  \$1 = $1"
echo "  \$2 = $2"
echo "  \$# = $#"

shift 2  # Remove next two arguments

echo "After shift 2:"
echo "  \$1 = $1"
echo "  \$# = $#"

echo ""

# Default values
echo "--- Default Values ---"

# Reset arguments
set -- "provided_value"

arg1="${1:-default1}"
arg2="${2:-default2}"
arg3="${3:-default3}"

echo "arg1 = $arg1 (was provided)"
echo "arg2 = $arg2 (used default)"
echo "arg3 = $arg3 (used default)"
```

### Special Variables

| Variable | Meaning | Example |
|---|---|---|
| `$0` | Script name | `./backup.sh` |
| `$1, $2...` | Positional arguments | First arg, second arg... |
| `$#` | Number of arguments | `3` |
| `$@` | All arguments (separate words) | `"a" "b" "c"` |
| `$*` | All arguments (single string) | `"a b c"` |

**Always quote `$@`:** Use `"$@"` to preserve arguments with spaces. `for arg in "$@"; do` handles `"hello world"` as one argument.

## Parsing with getopts

The `getopts` builtin handles short options like `-v`, `-f file`.

### Example

```bash
#!/usr/bin/env bash

# getopts Demo

echo "=== getopts Demo ==="
echo ""

# Reset for demo
OPTIND=1

# Initialize defaults
verbose=false
debug=false
output_file=""
input_file=""

# Demo with simulated arguments
set -- -v -d -o "output.txt" -f "input.txt" "extra_arg1" "extra_arg2"

echo "Arguments: $@"
echo ""

echo "--- Parsing with getopts ---"

# getopts string: "vdo:f:"
# v, d = flags (no argument)
# o:, f: = options (require argument)
# Leading : = silent error mode

while getopts ":vdo:f:" opt; do
    case $opt in
        v)
            verbose=true
            ;;
        d)
            debug=true
            ;;
        o)
            output_file="$OPTARG"
            ;;
        f)
            input_file="$OPTARG"
            ;;
        :)
            echo "Option -$OPTARG requires an argument" >&2
            exit 1
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

echo "verbose=$verbose"
echo "debug=$debug"
echo "output_file=$output_file"
echo "input_file=$input_file"
echo "Remaining arguments: $@"
```

### getopts Syntax

```bash
# getopts OPTSTRING VARNAME [ARGS]
#
# OPTSTRING format:
#   "vhf:"
#   v     - Flag (no argument)
#   h     - Flag (no argument)
#   f:    - Option (requires argument)
#   :     - Leading colon enables silent error mode

while getopts ":vhf:o:" opt; do
    case $opt in
        v)
            verbose=true
            ;;
        h)
            show_help
            exit 0
            ;;
        f)
            input_file="$OPTARG"
            ;;
        o)
            output_file="$OPTARG"
            ;;
        :)
            echo "Option -$OPTARG requires an argument" >&2
            exit 1
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Shift processed options away
shift $((OPTIND - 1))

# Remaining arguments are in $@
echo "Remaining args: $@"
```

**OPTIND:** After `getopts`, use `shift $((OPTIND - 1))` to remove processed options. Remaining positional arguments are then in `$1, $2, ...`
