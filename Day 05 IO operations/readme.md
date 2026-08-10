# Bash `read` Command — Cheatsheet

`read` is used to take input from the user, files, or streams.

---

## Basic Input

    read name
    echo "Hello, $name"

## Prompt with `-p`

    read -p "Enter name: " name

`-p` → Displays a prompt before reading input.

Without `-p`:

    echo "Enter name: "
    read name

With `-p`:

    read -p "Enter name: " name

---

## Read Full Line

    read -r -p "Enter sentence: " line

`-r` → Prevents `\` from being treated as an escape character.

**Best practice:** Use `read -r` for normal text input.

---

## Hidden Input

    read -s -p "Password: " pass
    echo

`-s` → Hides typed characters.

---

## Multiple Variables

    read first last <<< "John Doe"

Input is split using `IFS`.

    IFS=, read first last <<< "John,Doe"

`IFS` → Controls how input is split.

---

## Arrays

    read -r -a words <<< "one two three"

    echo "${words[0]}"
    echo "${words[1]}"
    echo "${words[2]}"

`-a` → Stores input fields in an array.

---

## Read File Line by Line

    while IFS= read -r line; do
        echo "$line"
    done < file.txt

`IFS=` → Preserves leading/trailing whitespace.

`read -r` → Preserves backslashes.

---

## Custom Delimiter

    read -r -d ':' token rest <<< "key:value:more"

`-d ':'` → Stops reading when `:` is found instead of newline.

---

## Timeout

    if read -r -t 2 -p "Type quickly: " input; then
        echo "You typed: $input"
    else
        echo "Timed out"
    fi

`-t 2` → Waits up to 2 seconds.

---

## Read Single Character

    read -n 1 key

`-n 1` → Reads one character without waiting for Enter.

---

## `mapfile` / `readarray`

    printf "a\nb\nc\n" | mapfile -t arr

    echo "${#arr[@]}"
    echo "${arr[*]}"

`mapfile` / `readarray` → Reads lines directly into an array.

`-t` → Removes trailing newlines.

---

## Here-String

    read name <<< "Alice"

`<<<` → Sends a string as input to a command.

---

## Quick Cheat Sheet

    read name                    → Read input
    read -p "Prompt: " name      → Read with prompt
    read -r name                 → Read literally
    read -s password             → Hidden input
    read -a arr                  → Read into array
    read -d ':' value            → Custom delimiter
    read -t 2 value              → Timeout
    read -n 1 key                → Read one character
    IFS=, read a b               → Split using comma
    mapfile -t arr               → Read lines into array
    <<< "text"                   → Here-string input

---

## Golden Rules

    -p  → Prompt
    -r  → Preserve backslashes
    -s  → Hide input
    -a  → Array
    -d  → Custom delimiter
    -t  → Timeout
    -n  → Number of characters

**Best practice:** Use `read -r` for text, `read -p` for prompts, and `IFS= read -r` when reading files line-by-line.


# Bash I/O Redirection — Cheatsheet

Bash uses **file descriptors (FDs)** to control input, output, and errors.

## File Descriptors

| FD | Name | Purpose |
|---|---|---|
| `0` | stdin | Input to command |
| `1` | stdout | Normal output |
| `2` | stderr | Errors/diagnostics |

## Output Redirection

    echo "hello" > out.txt

`>` → Redirects stdout to a file and **overwrites** it.

    echo "world" >> out.txt

`>>` → Redirects stdout and **appends** to the file.

## Error Redirection

    ls /no/such/path 2> err.txt

`2>` means:

    2       → stderr
    >       → redirect
    err.txt → destination

So:

    command 2> err.txt

means **send only errors (stderr) to `err.txt`**.

Normal output (stdout) still goes to the terminal.

## Why `2>`?

    ls /no/such/path > out.txt

`>` only redirects stdout, so the error still appears on the screen.

    ls /no/such/path 2> err.txt

`2>` redirects stderr, so the error goes into `err.txt`.

## Merge stdout + stderr

    command > both.txt 2>&1

Meaning:

    stdout → both.txt
    stderr → same place as stdout

Both outputs go into `both.txt`.

## Send Output to stderr

    echo "Error message" >&2

`>&2` → Sends stdout to stderr.

Equivalent:

    echo "Error message" 1>&2

Useful for separating normal output from errors in scripts.

## Discard Output

    command > /dev/null

`/dev/null` → Discards output.

Discard both stdout and stderr:

    command > /dev/null 2>&1

## Quick Cheat Sheet

    0           → stdin
    1           → stdout
    2           → stderr

    > file      → stdout → file (overwrite)
    >> file     → stdout → file (append)
    2> file     → stderr → file
    2>> file    → stderr → file (append)
    > file 2>&1 → stdout + stderr → file
    >&2         → stdout → stderr
    /dev/null   → Discard output

## Golden Rule

    >          → Normal output
    2>         → Errors
    2>&1       → Merge errors with normal output
    >&2        → Send message to stderr
    /dev/null  → Throw output away

# Bash Pipes & Pipelines

A pipe (`|`) sends the **stdout** of one command to the **stdin** of another command.

    command1 | command2 | command3

## Basic Example

    echo "hello world" | wc -w

    # Output: 2

## Word Counting Pipeline

    text="The quick brown fox jumps over the lazy dog the THE"

    printf "%s\n" "$text" |
    tr '[:upper:]' '[:lower:]' |
    tr -cs '[:alpha:]' '\n' |
    sort |
    uniq -c |
    sort -nr

    printf       → Safely prints text
    tr           → Converts uppercase to lowercase
    tr -cs       → Converts non-letters into new lines
    sort         → Sorts words
    uniq -c      → Counts duplicate words
    sort -nr     → Sorts counts highest → lowest

    # Example:
    # 3 the
    # 1 quick
    # 1 over

    # `sort` is needed before `uniq` because `uniq` only detects
    # consecutive duplicate lines.

## grep + awk

    printf "user:alice\nuser:bob\nrole:admin\n" |
    grep '^user:' |
    awk -F: '{print $2}'

    # Output:
    # alice
    # bob

    grep '^user:'       → Keeps lines starting with "user:"
    awk -F:             → Uses : as field separator
    '{print $2}'        → Prints the second field

## tee

`tee` saves output to a file while also passing it to the next command.

    echo "important output" |
    tee saved.txt |
    sed 's/.*/[&]/'

    # Terminal:
    # [important output]

    # saved.txt:
    # important output

    echo "saved.txt:"
    cat saved.txt

    # Flow:
    # echo → tee → saved.txt
    #          ↓
    #         sed → terminal

## Common Pipeline Commands

    cat file.txt | grep "error"        # Filter lines
    cat file.txt | sort                # Sort lines
    cat file.txt | sort | uniq         # Remove duplicates
    cat file.txt | wc -l               # Count lines
    cat file.txt | grep "error" | wc -l # Count matching lines
    command | tee output.txt           # Display + save output

## Important Commands

    |                       → Pipe stdout → stdin
    grep "text"            → Search/filter lines
    grep '^user:'          → Lines starting with user:
    awk -F: '{print $2}'   → Print second : separated field
    sort                   → Sort lines
    uniq                   → Remove consecutive duplicates
    uniq -c                → Count duplicates
    sort -nr               → Numeric reverse sorting
    tr                     → Translate/replace characters
    sed                    → Transform text
    tee                    → Save + pass output
    wc -l                  → Count lines

## Quick Reference

    cmd1 | cmd2            → cmd1 output becomes cmd2 input
    cmd1 | cmd2 | cmd3     → Multi-stage pipeline
    tee file               → Save output and continue pipeline

## Golden Rule

    Input → Command → Pipe → Command → Pipe → Command → Output

**Pipelines allow multiple small Linux commands to work together to process data efficiently.**

# Bash Here-Documents & Here-Strings

Bash provides **Here-Documents (`<<`)** and **Here-Strings (`<<<`)** to feed text directly into commands without creating temporary files.

---

## Here-Document `<<`

Used for **multiline input**.

    cat <<EOF
    Line 1
    Line 2
    EOF

`EOF` is the delimiter. Bash keeps reading until the delimiter appears alone on a line.

### Variable & Command Expansion

By default, variables and commands are expanded:

    cat <<EOF
    User: $USER
    Message: $(echo hi)
    EOF

    $USER       → Variable expansion
    $(...)      → Command substitution

---

## Prevent Expansion

Quote the delimiter to treat the content as literal text:

    cat <<'EOF'
    User: $USER
    Date: $(date)
    EOF

Output contains the literal:

    $USER
    $(date)

> Useful when generating scripts or configuration files.

---

## `<<-` — Remove Leading Tabs

    cat <<-EOF
    	Indented text
    	Another line
    EOF

`<<-` removes **leading TAB characters** from each line.

> It removes tabs, **not spaces**.

Useful when indenting Here-Docs inside functions or conditions.

---

## Here-String `<<<`

Used for **short, single-line input**.

    wc -w <<< "one two three"

Output:

    3

`<<< "text"` sends the string to the command's stdin and automatically adds a newline.

Instead of:

    echo "one two three" | wc -w

You can use:

    wc -w <<< "one two three"

---

## Here-Doc vs Here-String

| Syntax | Purpose |
|---|---|
| `<<EOF` | Multiline input |
| `<<'EOF'` | Multiline literal input |
| `<<-EOF` | Multiline input, removes leading tabs |
| `<<< "text"` | Single-line input |

---

## Common Patterns

    # Multiline text
    cat <<EOF
    Hello
    World
    EOF

    # Literal text
    cat <<'EOF'
    $USER
    $(date)
    EOF

    # Write directly to a file
    cat <<EOF > config.txt
    NAME=app
    PORT=8080
    EOF

    # Single-line input
    grep "hello" <<< "hello world"

---

## Quick Cheat Sheet

    <<EOF       → Here-Document
    <<'EOF'     → Here-Document without expansion
    <<-EOF      → Here-Document, remove leading tabs
    <<< "text"  → Here-String

    $var        → Expanded in normal Here-Doc
    $(cmd)      → Executed in normal Here-Doc
    'EOF'       → Prevents expansion

## Golden Rules

- Use `<<` for **multiline input**.
- Use `<<<` for **quick single-line input**.
- Quote the delimiter when you need **literal text**.
- `<<-` removes **tabs only**, not spaces.
- Here-Docs can be redirected directly into files.
