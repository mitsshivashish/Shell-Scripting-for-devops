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

## Handling Long Options

For `--verbose` style options, use manual parsing or external tools.

```bash
# Manual long option parsing
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                verbose=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -f|--file)
                [[ $# -lt 2 ]] && {
                    echo "Option $1 requires an argument" >&2
                    exit 1
                }
                input_file="$2"
                shift 2
                ;;
            --file=*)
                input_file="${1#*=}"
                shift
                ;;
            -o|--output)
                [[ $# -lt 2 ]] && {
                    echo "Option $1 requires an argument" >&2
                    exit 1
                }
                output_file="$2"
                shift 2
                ;;
            --output=*)
                output_file="${1#*=}"
                shift
                ;;
            --)
                shift
                break
                ;;
            -*)
                echo "Unknown option: $1" >&2
                exit 1
                ;;
            *)
                # Positional argument
                positional+=("$1")
                shift
                ;;
        esac
    done

    # Set remaining positional args
    set -- "${positional[@]}"
}

# Usage:
# script.sh --verbose --file=data.txt output.txt
parse_args "$@"
```

### Option Styles

| Style | Example | Notes |
|---|---|---|
| Short flag | `-v` | Boolean, no value |
| Short with value | `-f file.txt` | Space-separated |
| Combined shorts | `-vf file.txt` | Multiple flags |
| Long flag | `--verbose` | Boolean, no value |
| Long with value | `--file file.txt` | Space-separated |
| Long with equals | `--file=file.txt` | Equals-separated |

## Professional Usage Messages

Good CLI tools provide helpful usage information.

```bash
#!/usr/bin/env bash

readonly SCRIPT_NAME="$(basename "$0")"
readonly VERSION="1.0.0"

show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Copy files with advanced options.

Arguments:
    source          Source file or directory
    destination     Destination path

Options:
    -r, --recursive     Copy directories recursively
    -f, --force         Overwrite existing files
    -v, --verbose       Show detailed output
    -n, --dry-run       Show what would be done
    -h, --help          Show this help message
    --version           Show version number

Examples:
    $SCRIPT_NAME file.txt backup/
    $SCRIPT_NAME -rv src/ dest/
    $SCRIPT_NAME --force --verbose data.db /backup/

Environment:
    COPY_OPTS       Default options (e.g., "-rv")

Exit Codes:
    0   Success
    1   General error
    2   Invalid arguments

Report bugs to: bugs@example.com
EOF
}

show_version() {
    echo "$SCRIPT_NAME version $VERSION"
}

# Parse -h and --version early
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    --version)
        show_version
        exit 0
        ;;
esac
```

## Complete Argument Parser

Putting it all together: a robust argument parsing template.

```bash
#!/usr/bin/env bash
set -euo pipefail

# Script info
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Defaults
verbose=false
dry_run=false
force=false
output_file=""
declare -a input_files=()

show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] FILE...

Process one or more files.

Options:
    -o, --output FILE   Output file (default: stdout)
    -f, --force         Overwrite existing output
    -n, --dry-run       Show what would be done
    -v, --verbose       Verbose output
    -h, --help          Show this help
EOF
}

die() {
    echo "Error: $*" >&2
    echo "Try '$SCRIPT_NAME --help' for more information." >&2
    exit 1
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -n|--dry-run)
                dry_run=true
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            -o|--output)
                [[ $# -lt 2 ]] && die "Option $1 requires an argument"
                output_file="$2"
                shift 2
                ;;
            --output=*)
                output_file="${1#*=}"
                shift
                ;;
            --)
                shift
                input_files+=("$@")
                break
                ;;
            -*)
                die "Unknown option: $1"
                ;;
            *)
                input_files+=("$1")
                shift
                ;;
        esac
    done
}

validate_args() {
    # Require at least one input file
    [[ ${#input_files[@]} -eq 0 ]] && die "No input files specified"

    # Check input files exist
    for file in "${input_files[@]}"; do
        [[ -f "$file" ]] || die "File not found: $file"
    done

    # Check output won't overwrite without --force
    if [[ -n "$output_file" && -f "$output_file" && "$force" != "true" ]]; then
        die "Output file exists: $output_file (use --force to overwrite)"
    fi
}

main() {
    parse_args "$@"
    validate_args

    [[ "$verbose" == "true" ]] && echo "Processing ${#input_files[@]} file(s)..."

    for file in "${input_files[@]}"; do
        [[ "$verbose" == "true" ]] && echo "  Processing: $file"
        # Process file...
    done

    echo "Done!"
}

main "$@"
```

## Common Mistakes

### 1. Not quoting `$@`

```bash
# Wrong - breaks on spaces
for arg in $@; do
    echo "$arg"
done

# Correct
for arg in "$@"; do
    echo "$arg"
done
```

### 2. Missing required argument check

```bash
# Wrong - crashes if no $2
-f)
    file="$2"
    shift 2
    ;;

# Correct
-f)
    [[ $# -lt 2 ]] && die "-f requires an argument"
    file="$2"
    shift 2
    ;;
```

### 3. Forgetting to shift

```bash
# Wrong - infinite loop!
-v)
    verbose=true
    ;;

# Correct
-v)
    verbose=true
    shift
    ;;
```

## Summary

- **Positional:** Access with `$1, $2, $@, $#`
- **getopts:** Use for short options (`-v, -f file`)
- **Long options:** Parse manually with while/case loop
- **Always quote:** Use `"$@"` to preserve spaces
- **shift:** Remove processed arguments with `shift`
- **Help:** Always provide `-h/--help` with clear usage
