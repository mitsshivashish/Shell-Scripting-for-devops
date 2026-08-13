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

# Bash File Manipulation — Cheatsheet

Bash provides commands to **copy, move, delete, create, modify permissions, and find files**.

## Basic File Operations

```bash
cp file.txt copy.txt
cp file.txt dir/
cp -r dir1 dir2
```

`cp` → Copy files/directories  
`-r` → Copy directories recursively  
`-p` → Preserve permissions/timestamps  
`-i` → Ask before overwrite

```bash
mv old.txt new.txt
mv file.txt dir/
```

`mv` → Move or rename files  
`-i` → Ask before overwrite  
`-n` → Don't overwrite

```bash
rm file.txt
rm -r directory
rm -i file.txt
rm -f file.txt
```

`rm` → Delete files  
`-r` → Delete directories recursively  
`-i` → Ask before deleting  
`-f` → Force deletion

> ⚠️ `rm -rf` is dangerous. Always verify the path before using it.

```bash
touch file.txt
mkdir dir
mkdir -p parent/child
rmdir empty_dir
```

`touch` → Create file/update timestamp  
`mkdir -p` → Create directories including missing parents  
`rmdir` → Remove empty directories

## File Permissions — `chmod`

Permissions:

```text
r = read     = 4
w = write    = 2
x = execute  = 1
```

Permission groups:

```text
u → user/owner
g → group
o → others
a → all
```

### Symbolic Mode

```bash
chmod u+x script.sh
chmod go-r file.txt
chmod a+r file.txt
chmod u+rw file.txt
```

```text
u+x   → Add execute for owner
go-r  → Remove read from group/others
a+r   → Add read for everyone
```

### Numeric Mode

```bash
chmod 755 script.sh
chmod 644 file.txt
chmod 700 private.txt
chmod 600 secret.txt
```

Common permissions:

```text
755 → Owner: rwx | Group: r-x | Others: r-x
644 → Owner: rw- | Group: r-- | Others: r--
700 → Owner: rwx | Group: --- | Others: ---
600 → Owner: rw- | Group: --- | Others: ---
```

## `find` — Locate Files

```bash
find /path -name "*.txt"
```

Find files by name.

```bash
find /path -iname "*.TXT"
```

Case-insensitive name search.

### Find by Type

```bash
find /path -type f    # Regular files
find /path -type d    # Directories
find /path -type l    # Symbolic links
```

### Find by Time

```bash
find /path -mtime -7    # Modified within 7 days
find /path -mtime +30   # Modified more than 30 days ago
find /path -mmin -60    # Modified within 60 minutes
```

### Find by Size

```bash
find /path -size +100M
find /path -size -1k
```

`+` → Greater than  
`-` → Less than

### Find by Permissions

```bash
find /path -perm 755
find /path -perm -u+x
```

`-perm 755` → Exact permissions  
`-perm -u+x` → User has execute permission

## Execute Commands with `find`

```bash
find /path -name "*.log" -delete
```

Delete matching files.

```bash
find /path -name "*.sh" -exec chmod +x {} \;
```

Make matching scripts executable.

```bash
find /path -type f -exec grep -l "error" {} \;
```

Find files containing `error`.

`{}` → Current file found by `find`  
`\;` → End of `-exec` command

## `find` + `xargs`

Useful when processing many files:

```bash
find /path -name "*.txt" | xargs grep "pattern"
```

For filenames containing spaces/special characters:

```bash
find /path -name "*.log" -print0 | xargs -0 rm -f
```

`-print0` + `xargs -0` → Safely handles spaces and special characters.

## Quick Cheat Sheet

```text
cp file copy             → Copy file
cp -r dir copy           → Copy directory
mv old new                → Move/rename
rm file                   → Delete file
rm -r dir                 → Delete directory
touch file                → Create/update file
mkdir -p dir              → Create directory tree

chmod 755 file            → Set permissions
chmod u+x file            → Add execute for owner
chmod go-w file           → Remove write from group/others

find /path -name "*.txt"  → Find by name
find /path -type f        → Find files
find /path -type d        → Find directories
find /path -mtime -7      → Modified within 7 days
find /path -size +100M    → Larger than 100 MB
find /path -exec cmd {} \; → Run command on results
```

## Golden Rules

```text
cp       → Copy
mv       → Move / Rename
rm       → Delete
chmod    → Change permissions
find     → Search files/directories

755 → Executable
644 → Normal file
600 → Private/sensitive file

Always quote paths:
cp "$source" "$destination"

Be extremely careful with:
rm -rf
find ... -delete
```
