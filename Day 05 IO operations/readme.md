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
