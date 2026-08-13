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


# Bash File Writing — Cheatsheet

Bash provides several ways to create, overwrite, append, format, and safely write files.

## Basic Writing

```bash
echo "Hello" > file.txt
echo "World" >> file.txt
```

`>` → Create/overwrite file  
`>>` → Create/append to file

```bash
printf "Name: %s\nAge: %d\n" "Alice" 25 > file.txt
```

`printf` → Precise and reliable formatted output.

## printf Formats

```text
%s      → String
%d      → Integer
%f      → Float
%.2f    → Float with 2 decimals
%10s    → Right-aligned, width 10
%-10s   → Left-aligned, width 10
%05d    → Zero-padded integer
```

```bash
printf "%05d\n" 42
# 00042

printf "%-15s %8d %10.2f\n" "Alice" 25 75000.50
```

## tee

```bash
echo "Hello" | tee file.txt
echo "World" | tee -a file.txt
```

`tee` → Write to file **and** display output.  
`tee -a` → Append instead of overwrite.

## Here-Documents

Write multiple lines at once:

```bash
cat > config.txt << 'EOF'
[settings]
debug=true
port=8080
host=localhost
EOF
```

```text
<< 'EOF' → No variable/command expansion
<< EOF   → Variables and commands are expanded
```

Example:

```bash
name="MyApp"
version="1.0"

cat > config.txt << EOF
app_name=$name
app_version=$version
generated=$(date)
EOF
```

Append with a Here-Document:

```bash
cat >> log.txt << EOF
[$(date)] New entry
EOF
```

Here-string:

```bash
cat <<< "Single line" > file.txt
```

## Safe File Writing

### Atomic Write

```bash
temp=$(mktemp)
echo "new content" > "$temp" && mv "$temp" target.txt
```

Write to a temporary file first, then replace the target only after a successful write.

### Backup Before Overwrite

```bash
cp file.txt file.txt.bak
echo "new content" > file.txt
```

### Check Write Success

```bash
if echo "data" > file.txt; then
    echo "Write succeeded"
else
    echo "Write failed!" >&2
    exit 1
fi
```

### Prevent Accidental Overwrite

```bash
set -o noclobber

echo "test" > existing.txt     # Fails if file exists
echo "test" >| existing.txt    # Force overwrite
```

## Quick Cheat Sheet

```text
> file       → Create/overwrite
>> file      → Create/append
tee file     → Write + display
tee -a file  → Append + display

printf       → Formatted output
<< EOF       → Multiline input with expansion
<< 'EOF'     → Multiline literal input
<<< "text"   → Single-line input

mktemp       → Create temporary file
noclobber    → Prevent accidental overwrite
>&2          → Send message to stderr
```

## Golden Rules

```text
>       → Be careful: destroys existing content
>>      → Use for appending/logs
printf  → Prefer for predictable formatting
<<'EOF' → Use when content must remain literal
mktemp  → Useful for safe/atomic writes
backup  → Create one before overwriting important files
```
