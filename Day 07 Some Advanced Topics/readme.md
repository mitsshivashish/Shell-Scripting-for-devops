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
