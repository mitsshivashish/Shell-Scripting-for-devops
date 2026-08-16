# Regular Expressions — Bash Cheatsheet

Regular expressions (regex) are patterns used to search, extract, validate, and transform text.

## grep -E

`grep -E` enables **Extended Regular Expressions (ERE)**.

    grep -E 'pattern' file
    grep -Eo 'pattern' file

## Regex Symbols

    ^        → Start of line
    $        → End of line
    .        → Any character
    *        → Zero or more
    +        → One or more
    ?        → Zero or one
    [abc]    → One character: a, b, or c
    [a-z]    → Character range
    [0-9]    → Digit
    {n}      → Exactly n times
    {n,m}    → Between n and m times
    |        → OR
    (...)     → Group
    \        → Escape special character

## Common grep Options

    grep -E 'pattern' file       → Extended regex
    grep -i 'foo' file           → Case-insensitive
    grep -w 'foo' file           → Whole-word match
    grep -o 'pattern' file       → Only matching text
    grep -v 'foo' file           → Lines NOT matching
    grep -n 'foo' file           → Show line numbers
    grep -F 'text' file          → Fixed-string match

## Examples

    # Extract email addresses
    grep -Eo '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' data.txt

    # Lines starting with lowercase letters
    grep -E '^[a-z]+' data.txt

    # Extract ID
    echo 'user:alice id:42' | grep -oE 'id:[0-9]+'

## sed -E

`sed -E` enables extended regex and is mainly used to transform text.

    sed -E 's/old/new/g' file

    s → Substitute
    g → Replace all matches on each line

## Capture Groups

    sed -E 's/(\b[0-9]{3})-([0-9]{3})-([0-9]{4})/\1-XXX-\3/g' data.txt

    (...) → Capture group
    \1    → First captured group
    \2    → Second captured group
    \3    → Third captured group

    555-123-4567 → 555-XXX-4567

## Select Matching Lines with sed

    sed -n '/@example\.org/p' data.txt

    -n → Suppress normal output
    /p → Print matching lines

## grep vs sed

    grep → Search / filter / extract
    sed  → Search / replace / transform

## Quick Regex Patterns

    ^pattern       → Starts with pattern
    pattern$       → Ends with pattern
    [a-z]           → Lowercase letter
    [A-Z]           → Uppercase letter
    [0-9]           → Digit
    [0-9]+          → One or more digits
    [0-9]{3}        → Exactly 3 digits
    foo|bar         → foo OR bar
    (foo)            → Group / capture
    \.              → Literal dot
    .*              → Any number of characters

## Important Notes

    grep -E → Extended Regular Expressions (ERE)
    grep -P → PCRE; may not be available everywhere
    grep -o → Extract only matching text
    grep -n → Show line numbers
    grep -F → Fixed-string matching

> Prefer explicit flags such as `-E` and `-F` for clarity.

## Golden Rules

1. Use `grep -E` for searching with extended regex.
2. Use `grep -o` when you only need matched text.
3. Use `grep -n` when line numbers are useful.
4. Use `sed -E` for regex-based transformations.
5. Escape special characters when you need their literal meaning.
6. Remember: `grep` searches/extracts; `sed` transforms.


# Regular Expressions — Bash Cheatsheet

Regular expressions (regex) are patterns used to search, extract, and transform text using `grep -E` and `sed -E`.

## grep -E

`grep -E` enables Extended Regular Expressions (ERE).

    grep -E 'pattern' file
    grep -Eo 'pattern' file

## Regex Patterns

    ^        → Start of line
    $        → End of line
    .        → Any character
    *        → Zero or more
    +        → One or more
    ?        → Zero or one
    [abc]    → a, b, or c
    [a-z]    → Character range
    [0-9]    → Digit
    {n}      → Exactly n times
    {n,m}    → Between n and m times
    |        → OR
    (...)    → Group / capture
    \        → Escape special character

## Examples

    # Extract email addresses
    grep -Eo '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' data.txt

    # Lines starting with lowercase names
    grep -E '^[a-z]+' data.txt

    # Extract ID
    echo 'user:alice id:42' | grep -oE 'id:[0-9]+'

    # Case-insensitive search
    grep -i 'foo' words.txt

    # Whole-word match
    grep -w 'foo' words.txt

    # Invert match
    grep -v 'bar' words.txt

    # Show line numbers
    grep -n 'foo' words.txt

## sed -E

`sed -E` enables extended regex and is mainly used to transform text.

    sed -E 's/old/new/g' file

    s → Substitute
    g → Replace all matches on each line

## Capture Groups

    sed -E 's/(\b[0-9]{3})-([0-9]{3})-([0-9]{4})/\1-XXX-\3/g' data.txt

    (...) → Capture group
    \1    → First captured group
    \2    → Second captured group
    \3    → Third captured group

    555-123-4567 → 555-XXX-4567

## Select Matching Lines

    sed -n '/@example\.org/p' data.txt

    -n → Suppress normal output
    /p → Print matching lines

## grep Options

    -E → Extended regex
    -i → Case-insensitive
    -w → Whole-word match
    -o → Output only matches
    -v → Invert match
    -n → Show line numbers
    -F → Fixed-string matching

## grep vs sed

    grep → Search / filter / extract
    sed  → Search / replace / transform

## Quick Regex Reference

    ^pattern       → Starts with pattern
    pattern$       → Ends with pattern
    [a-z]          → Lowercase letter
    [A-Z]          → Uppercase letter
    [0-9]          → Digit
    [0-9]+         → One or more digits
    [0-9]{3}       → Exactly 3 digits
    foo|bar        → foo OR bar
    (foo)          → Group / capture
    \.             → Literal dot
    .*             → Any number of characters

## Important Notes

    grep -E → ERE support
    grep -P → PCRE; may not be available everywhere
    grep -o → Extract only matching text
    grep -n → Show line numbers
    grep -F → Fixed-string matching

> Use `-o` to extract only matches and `-n` to show line numbers.

> Some shells may alias `grep`; prefer explicit flags such as `-E` and `-F` for clarity.

## Golden Rules

1. Use `grep -E` for extended regex searching.
2. Use `grep -o` when you only need matched text.
3. Use `grep -n` when line numbers are useful.
4. Use `sed -E` for regex-based transformations.
5. Escape special characters when you need their literal meaning.
6. Remember: `grep` searches/extracts; `sed` transforms.


# AWK — Bash Cheatsheet

AWK is a text-processing language used to scan, filter, extract, transform, calculate, and generate reports from structured text such as CSV/TSV files.

## Basic Syntax

awk 'pattern { action }' file
awk -F, 'NR>1 { print $2 }' people.csv

`-F` sets the field separator.

## Fields & Built-ins

$0        → Entire line  
$1,$2...  → First, second, ... field  
$NF       → Last field  
NF        → Number of fields  
NR        → Current line/record number

Example:

awk -F, 'NR>1 { print $1, $2, $3 }' people.csv

## Filtering

awk -F, 'NR>1 && $2>28 { print $1 ":" $3 }' people.csv

NR>1  → Skip header  
$2>28 → Age greater than 28  
$1    → Name  
$3    → City

## Common Commands

awk -F, '{ print $2 }' file.csv          # Print column 2
awk -F, '$2 > 30 { print $1 }' file.csv  # Filter by column
awk 'NR==1 { print }' file                # Print first line
awk 'NF > 0' file                         # Ignore empty lines
awk '{ print $1, $NF }' file             # First + last field

## BEGIN / END

BEGIN { ... } → Runs before input processing  
END { ... }   → Runs after all input is processed

Example:

awk -F"\t" 'BEGIN { sum=0 } { sum += $2 } END { printf "total=%d\n", sum }' data.tsv

Use `BEGIN` for initialization and `END` for final calculations/reports.

## Arrays

Associative arrays are useful for counting and grouping.

printf "a\nb\na\nc\na\n" | awk '{ count[$1]++ } END { for (k in count) printf "%s %d\n", k, count[k] }' | sort

Output:

a 3
b 1
c 1

## printf

Use `printf` for formatted/aligned output.

awk '{ printf "%-15s %5s\n", $1, $2 }' file

%s → String  
%d → Integer  
%f → Floating-point number

## Field Separators

awk -F, '...' file.csv        # CSV
awk -F'\t' '...' file.tsv     # TSV
awk -F: '...' /etc/passwd     # Colon-separated

Or:

awk 'BEGIN { FS="," } { print $1 }' file.csv

## Quick Reference

-F,           → Set comma separator  
$1..$n        → Access fields  
$0            → Entire line  
$NF           → Last field  
NF            → Number of fields  
NR            → Current line number  
BEGIN { ... } → Before input  
{ ... }       → For each record  
END { ... }   → After input  
array[key]    → Associative array  
printf        → Formatted output

## grep vs sed vs awk

grep → Search / filter / extract  
sed  → Search / replace / transform  
awk  → Fields / filtering / calculations / reports

## Important Notes

- Use `-F` to split input into fields.
- Use `$1..$n` to access columns.
- Use conditions and actions for per-line processing.
- Use `BEGIN` for setup and `END` for aggregation/final output.
- Use arrays for counting and grouping.
- Use `printf` for formatted reports.
- AWK is especially useful for CSV/TSV and report generation.
- Be careful with complex CSV files containing quoted commas; dedicated CSV tools may be better.

## Golden Rules

1. `-F` → Define the field separator.
2. `$1`, `$2`, etc. → Access columns.
3. `NR` → Current record/line number.
4. `NF` → Number of fields.
5. `BEGIN` → Setup/initialization.
6. `END` → Final calculations/output.
7. Arrays → Counting/grouping.
8. `printf` → Formatted reports.
9. **grep searches, sed transforms, awk processes structured text and generates reports.**


# Signal Handling — Bash Cheatsheet

Signal handling lets Bash scripts respond to events such as `Ctrl+C` and perform cleanup before exiting. Use `trap` to intercept signals and run commands or functions.

## trap Syntax

trap 'commands' SIGNAL

Example:

trap 'echo "Caught SIGINT"; cleanup; exit 130' INT
trap 'echo "Exiting"; cleanup' EXIT

`INT` → Interrupt signal, usually generated by `Ctrl+C`  
`EXIT` → Runs when the script exits

## Cleanup Function

Keep cleanup logic inside a function so it can be reused by multiple traps.

cleanup() {
    echo "Cleaning up..."
    rm -f tmpfile 2>/dev/null || true
}

trap 'cleanup' EXIT

## Practical Example

#!/usr/bin/env bash

cleanup() {
    echo "Cleaning up..."
    rm -f tmpfile 2>/dev/null || true
}

trap 'echo "Caught SIGINT"; cleanup; exit 130' INT
trap 'echo "Exiting"; cleanup' EXIT

echo "Creating tmpfile and sleeping (try Ctrl-C)"
touch tmpfile
sleep 1
echo "Done"

## Important Signals

INT  → Interrupt (`Ctrl+C`)  
EXIT → Script is exiting  
TERM → Request to terminate  
HUP  → Hangup / terminal closed

Some signals cannot be trapped, such as:

SIGKILL → `kill -9`  
SIGSTOP → Stop process

## Why Use trap?

- Clean temporary files
- Stop/clean child processes
- Handle `Ctrl+C`
- Perform cleanup on normal or abnormal exits
- Make scripts exit predictably

## Best Practices

- Always consider `trap ... EXIT` for final cleanup.
- Put cleanup logic in one function instead of duplicating it.
- Quote trap commands: `trap 'cleanup' INT`
- Remove temporary artifacts on every exit path.
- Use `|| true` when a cleanup command failing should not stop cleanup.

## Quick Reference

trap 'command' SIGNAL       → Run command when signal occurs
trap 'cleanup' EXIT         → Cleanup whenever script exits
trap - SIGNAL               → Remove a trap
trap -l                     → List available signals

## Golden Rule

**Create → Trap → Cleanup → Exit**

Use `trap` whenever your script creates temporary files, processes, or other resources that must be cleaned up when the script exits.


# Background Jobs — Bash Cheatsheet

Background jobs let Bash run tasks concurrently using `&`. Track their PIDs with `$!` and use `wait` to wait for completion. In non-interactive scripts, prefer `wait` instead of `fg/bg`.

## Start Background Jobs

command &

`&` → Runs the command in the background.

Example:

long_task() {
    echo "[$1] start"
    sleep "$2"
    echo "[$1] done"
}

long_task A 1 &
pid1=$!

long_task B 2 &
pid2=$!

`$!` → PID of the most recent background command.

## Wait for Jobs

wait "$pid1" "$pid2"

`wait` → Pauses the script until the specified background jobs finish.

Example:

echo "Waiting for jobs $pid1 and $pid2"
wait "$pid1" "$pid2"
echo "All jobs finished"

## Complete Example

#!/usr/bin/env bash

long_task() {
    echo "[$1] start"
    sleep "$2"
    echo "[$1] done"
}

long_task A 1 &
pid1=$!

long_task B 2 &
pid2=$!

echo "Waiting for jobs $pid1 and $pid2"
wait "$pid1" "$pid2"

echo "All jobs finished"

## Useful Commands

command &       → Run command in background
$!              → PID of latest background job
wait PID        → Wait for a specific job
wait PID1 PID2  → Wait for multiple jobs
wait            → Wait for all currently known background jobs

## Why Use Background Jobs?

- Run independent tasks concurrently.
- Reduce total execution time.
- Run multiple servers, files, or processes at the same time.
- Useful for parallel automation tasks.

Example:

task1 &
task2 &
task3 &
wait

Without background execution, tasks run one after another. With `&`, they can run concurrently and `wait` ensures the script doesn't continue until they finish.

## Logging

Use descriptive logs with job IDs and timestamps:

echo "[$(date '+%H:%M:%S')] Starting job A"

This makes parallel jobs easier to monitor and debug.

## Important Notes

- `$!` only refers to the most recently started background process.
- Save each PID immediately after starting the job.
- Use `wait` to ensure background tasks finish before continuing.
- `fg` and `bg` depend on interactive job control and may not work in non-interactive scripts.
- Prefer `wait` in automation, CI/CD, and other non-interactive environments.

## Quick Reference

&       → Run in background
$!      → Get latest background PID
wait    → Wait for completion
fg      → Bring job to foreground (interactive)
bg      → Resume job in background (interactive)

## Golden Rule

**Start → Save PID → Wait**

Use `&` for concurrency, `$!` to track jobs, and `wait` to synchronize them.
