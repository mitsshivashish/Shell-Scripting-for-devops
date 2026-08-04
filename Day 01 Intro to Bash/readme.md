# Day 1 - Bash & Linux Terminal Basics 🚀

## 📌 Overview
Today I started learning **Bash** and the fundamentals of the Linux terminal. I learned what Bash is, why it is used, how shell scripts work, and practiced essential terminal commands and Bash variables.

---

# What is Bash?

**Bash (Bourne Again Shell)** is a command-line interpreter (shell) used to communicate with the Linux operating system.

### Why Bash?
- Automates repetitive tasks
- Executes Linux commands
- Creates shell scripts
- Useful for DevOps, Cloud, and System Administration
- Makes workflow faster and more efficient

---

# Shell Script Basics

## Shebang

The first line of a shell script is called the **Shebang**.

```bash
#!/bin/bash
```

It tells Linux which interpreter should execute the script.

---

## Comments

Comments are ignored by Bash.

```bash
# This is a comment
```

---

## Making a Script Executable

Give execute permission:

```bash
chmod +x script-name.sh
```

Run the script:

```bash
./script-name.sh
```

---

## Practice

Created an introductory shell script:

```
intro.sh
```

---

# Linux Terminal Commands Learned

## Navigation

| Command | Purpose |
|----------|---------|
| `pwd` | Show current directory |
| `cd` | Change directory |
| `ls` | List files and folders |

---

## File & Directory Creation

| Command | Purpose |
|----------|---------|
| `touch` | Create file |
| `mkdir` | Create directory |

---

## File Operations

| Command | Purpose |
|----------|---------|
| `cp` | Copy files/directories |
| `mv` | Move or rename files |
| `rm` | Remove files |

---

## Useful Options

| Option | Meaning |
|---------|---------|
| `-r` | Recursive |
| `-f` | Force |
| `-i` | Interactive |
| `-a` | Show all files |
| `-l` | Long format |
| `-h` | Human-readable sizes |

---

## Special Directories

| Symbol | Meaning |
|---------|---------|
| `~` | Home directory |
| `.` | Current directory |
| `..` | Parent directory |
| `-` | Previous directory |

---

## Safety Tip

⚠️ Be careful with:

```bash
rm -rf
```

It permanently deletes files and directories without any undo.

Prefer using:

```bash
rm -i
```

to confirm before deletion.

---

## Other Useful Commands

```bash
cat
head
tail
find
grep
which
whoami
date
```

---

# Bash Variables

Variables do not require declaration.

Syntax:

```bash
variable=value
```

> **Note:** No spaces around `=`.

Example:

```bash
name="Rakesh"
```

Access variable:

```bash
echo $name
```

Remove a variable:

```bash
unset name
```

---

# Variable Naming Conventions

- Start with a letter or underscore
- Can contain letters, numbers, and underscores
- No spaces
- Case-sensitive
- Follow the same naming conventions as most programming languages

Example:

```bash
user_name="John"
```

---

# Parameter Expansion

## Default Value (Without Assignment)

```bash
${var:-value}
```

If `var` is empty or unset, it returns `value` without changing `var`.

Example:

```bash
echo ${name:-Guest}
```

---

## Default Value (With Assignment)

```bash
${var:=value}
```

If `var` is empty or unset, it assigns `value` to `var`.

Example:

```bash
echo ${name:=Guest}
```

---

## String Length

```bash
${#var}
```

Example:

```bash
name="Rakesh"

echo ${#name}
```

Output:

```
6
```

---

## String Slicing

Syntax:

```bash
${var:offset:length}
```

Example:

```bash
name="DevOps"

echo ${name:3:2}
```

Output:

```
Op
```

---

## Negative Offset

When using a negative offset, **leave a space before the minus sign**.

Correct:

```bash
${var: -5}
```

Example:

```bash
name="HelloWorld"

echo ${name: -5}
```

Output:

```
World
```

---

# Environment Variables

Environment variables are available to all child processes.

Create one:

```bash
export MY_NAME="Rakesh"
```

Access it:

```bash
echo $MY_NAME
```

---

# PATH Environment Variable

`PATH` stores directories where executable programs are searched.

View PATH:

```bash
echo $PATH
```

Example:

```text
/usr/local/bin:/usr/bin:/bin:/snap/bin
```

### Important Points

- Directories are separated by `:`
- Bash searches **from left to right**
- The first matching executable is used

---

# Common Environment Variables

| Variable | Description |
|----------|-------------|
| `HOME` | User's home directory |
| `PATH` | Executable search paths |
| `SHELL` | Current shell |
| `USER` | Current logged-in user |
| `PWD` | Current working directory |
| `HOSTNAME` | System hostname |

---

# Key Takeaways

- Learned what Bash is and why it is important.
- Understood the purpose of the Shebang line.
- Learned how to write comments in shell scripts.
- Created and executed the first shell script (`intro.sh`).
- Practiced essential Linux terminal commands.
- Learned file navigation and management.
- Understood Bash variables and naming conventions.
- Explored parameter expansion for default values and string manipulation.
- Learned about environment variables using `export`.
- Understood how the `PATH` variable works.
- Familiarized myself with common Linux environment variables.

---

## 📚 Next Goal

- Conditional statements (`if`, `elif`, `else`)
- Loops (`for`, `while`)
- Functions in Bash
- User input with `read`
- Command-line arguments (`$1`, `$2`, `$@`)
- Exit codes and error handling
