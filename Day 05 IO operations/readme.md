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
