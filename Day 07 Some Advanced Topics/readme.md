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
