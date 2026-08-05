In day 2 i learns about varibales and strings and Arrays

"Special Variables Reference:"
echo "- \$0     : Script name"
echo "- \$1-\$9  : First 9 arguments"
echo "- \$#     : Number of arguments"
echo "- \$@     : All arguments (separate)"
echo "- \$*     : All arguments (one string)"
echo "- \$\$     : Current process ID"
echo "- \$?     : Exit status of last command"
echo "- \$!     : PID of last background job"

Exit Code	Meaning	Example
0	Success	ls found files
1	General error	grep found nothing
2	Misuse of command	ls with invalid option
126	Command not executable	Permission denied
127	Command not found	Command doesn't exist
130	Terminated by Ctrl+C	User interruption

Important: Always use "$@" when passing arguments to other commands! This preserves spaces in arguments and handles special characters correctly. Unquoted $@ or $* can break with arguments containing spaces.
 ex:- 
Imagine you run your script with two folder names:./make_folders.sh "Project Alpha" "Project Beta"bash#!/bin/bash

# WRONG WAY: Unquoted $@
# Bash splits "Project Alpha" into two folders: "Project" and "Alpha"
echo "--- Trying unquoted \$@ ---"
mkdir $@ 

# RIGHT WAY: Quoted "$@"
# Bash correctly passes "Project Alpha" and "Project Beta" as two folders
echo "--- Trying quoted \"\$@\" ---"
mkdir "$@"
Use code with caution.The Resulting Files on Your SystemUsing unquoted $@: You get 4 accidental folders:ProjectAlphaProject (overwritten or errors)BetaUsing quoted "$@": You get exactly the 2 folders you wanted:Project AlphaProject Beta

# Bash Arrays

## 📚 What I Learned

- Declared indexed and associative arrays.
- Accessed single and multiple array elements.
- Found array length and element length.
- Modified, added, and removed array elements.
- Iterated through arrays with and without indices.
- Performed array slicing.
- Copied, reindexed, and concatenated arrays.
- Created arrays from command output.

## 🛠️ Commands & Syntax

```bash
# Declare arrays
arr=(a b c)
declare -A person

# Access elements
${arr[0]}
${arr[@]}
${arr[*]}

# Array size
${#arr[@]}
${#arr[0]}

# Modify & Add
arr[1]="x"
arr+=("d" "e")

# Loop through array
for item in "${arr[@]}"; do
    echo "$item"
done

# Loop with indices
for i in "${!arr[@]}"; do
    echo "${arr[$i]}"
done

# Associative array
person[name]="Alice"
${person[name]}
${!person[@]}

# Array slicing
${arr[@]:1:2}

# Get indices
${!arr[@]}

# Check element exists
[[ -v arr[2] ]]

# Remove element
unset arr[2]

# Copy array
copy=("${arr[@]}")

# Reindex array
newArr=("${arr[@]}")

# Concatenate arrays
combined=("${arr1[@]}" "${arr2[@]}")

# Array from command output
files=($(ls))
```

## ✅ Key Takeaways

- Arrays are **zero-indexed**.
- Use `"${array[@]}"` while looping to preserve spaces.
- `${#array[@]}` → Total elements.
- `${!array[@]}` → All indices/keys.
- `unset` removes an element but leaves index gaps.
- Bash supports both **indexed** and **associative** arrays.

# Bash String Operations

## What I Learned

- Assign variables: `var="value"` (no spaces around `=`)
- Use **double quotes** (`" "`) for variable expansion.
- Use **single quotes** (`' '`) for literal strings.
- Get string length: `${#var}`
- Extract substring: `${var:start:length}`
- Replace first occurrence: `${var/old/new}`
- Replace all occurrences: `${var//old/new}`
- Convert to uppercase: `${var^^}`
- Convert to lowercase: `${var,,}`
- Remove shortest prefix: `${var#pattern}`
- Remove longest prefix: `${var##pattern}`
- Remove shortest suffix: `${var%pattern}`
- Remove longest suffix: `${var%%pattern}`
- Use fallback value (without assigning): `${var:-default}`
- Set a default value if variable is empty/unset: `${var:=default}`

## Example

```bash
name="Shivashish"
file="backup.tar.gz"

echo ${#name}          # Length
echo ${name:0:4}       # Substring
echo ${name/i/I}       # Replace first occurrence
echo ${name//i/I}      # Replace all occurrences
echo ${name^^}         # Uppercase
echo ${name,,}         # Lowercase

echo ${file#*.}        # Remove shortest prefix
echo ${file##*.}       # Remove longest prefix
echo ${file%.*}        # Remove shortest suffix
echo ${file%%.*}       # Remove longest suffix

echo ${user:-Guest}    # Fallback value
echo ${user:=Guest}    # Set default value
```
