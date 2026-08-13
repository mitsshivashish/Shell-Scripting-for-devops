# Bash File Reading — Cheatsheet

Bash provides several ways to read files depending on whether you need the whole file, individual lines, specific lines, or structured fields.

---

## Read Entire File

```
content=$(cat file.txt)
echo "$content"
```

`cat` → Reads the entire file at once.

---

## Read Line by Line

```
while IFS= read -r line; do
    echo "$line"
done < file.txt

IFS= → Preserves leading/trailing whitespace
-r   → Prevents backslash interpretation
```

> **Best practice:** Use `while IFS= read -r line` for safe line-by-line processing.

---

## Read File into Array

```
mapfile -t arr < file.txt

echo "${arr[0]}"
echo "${#arr[@]}"

mapfile -t → Reads each line into an array
-t         → Removes trailing newlines
```

---

## Input Redirection

```
command < file.txt
```

`< file` → Sends the file contents to the command's stdin.

---

## Read Parts of a File

```
head -n 5 file.txt       # First 5 lines
tail -n 5 file.txt       # Last 5 lines
tail -n +5 file.txt      # From line 5 to end
tail -f file.txt         # Follow new content
sed -n '5,10p' file.txt  # Lines 5–10
```

### Log Monitoring

```
tail -f /var/log/syslog | grep "error"
```

---

## Parse Fields with `IFS`

For comma-separated data:

```
while IFS=, read -r name age role; do
    echo "Name: $name, Age: $age, Role: $role"
done < users.csv
```

For colon-separated data:

```
while IFS=: read -r user pass uid gid desc home shell; do
    echo "User: $user | Shell: $shell"
done < /etc/passwd
```

`IFS` → Internal Field Separator; controls how `read` splits fields.

---

## Field Parsing Tools

```
cut -d',' -f1 file.csv
awk -F',' '{print $1}' file.csv
tr ',' '\n' file.csv

cut → Simple field extraction
awk → Powerful field processing
tr  → Replace/transform delimiters
```

---

## Read Command Output

Use process substitution when reading another command's output:

```
while IFS= read -r line; do
    echo "Process: $line"
done < <(ps aux | head -5)
```

---

## Read Multiple Files

```
for file in *.txt; do
    while IFS= read -r line; do
        echo "[$file] $line"
    done < "$file"
done
```

Always quote `"$file"` to safely handle spaces in filenames.

---

## Quick Cheat Sheet

```
cat file                 → Read entire file
while read               → Process line by line
mapfile -t arr < file    → Read lines into array
command < file           → Redirect file to stdin

head -n N file           → First N lines
tail -n N file           → Last N lines
tail -n +N file          → From line N onward
tail -f file             → Follow file changes
sed -n 'N,Mp' file       → Read specific lines

IFS=, read ...           → Parse comma-separated fields
cut -d',' -f1            → Extract field
awk -F',' '{print $1}'   → Extract/process field
tr ',' '\n'              → Replace delimiter
```

---

## Golden Rules

* Use `while IFS= read -r line` for safe line-by-line reading.
* Use `mapfile -t` when you need the file as an array.
* Use `head`, `tail`, and `sed` for partial reads.
* Use `IFS` with `read` for structured fields.
* Always quote file variables: `"$file"`.
* Use `read -r` to preserve backslashes.
* For binary data, prefer tools like `dd` or `xxd` instead of text-based `read`.



