# Bash Arithmetic Cheatsheet

A comprehensive guide to performing math in Bash, covering historical syntax, modern methods, advanced operators, and decimal calculations.

---

## 1. Evolution and Core Definitions

* **`let` (Built-in Command)**: Created in the 1980s (KornShell) to replace the slow, external `expr` utility. It modifies variables directly but treats inputs as command arguments.
* **`$((...))` (Arithmetic Expansion)**: Introduced in 1992 by the POSIX committee. It evaluates the internal math and **returns/outputs** the value as text.
* **`((...))` (Modern Arithmetic Evaluation)**: A modern Bash shorthand that acts like `let` (modifies variables directly) but uses the clean, space-friendly environment of `$((...))`.

---

## 2. Syntax & Feature Comparison

| Feature | `let a=b*c` | `a=$((b*c))` | `((a=b*c))` |
| :--- | :--- | :--- | :--- |
| **Primary Role** | Direct variable assignment | Text/value output | Direct variable assignment |
| **Spaces Allowed?** | ❌ **No** (unquoted spaces break it) |  **Yes** (creates a safe math zone) |  **Yes** (creates a safe math zone) |
| **Output Text?** | ❌ **No** (only updates background variables) |  **Yes** (can be used inside `echo`) | ❌ **No** (only updates background variables) |
| **POSIX Standard?** | ❌ **No** (Only Bash/Ksh; crashes on minimal `sh`) |  **Yes** (Works universally on all modern Unix) | ❌ **No** (Bash/Zsh specific extension) |
| **Shorthand Operators** |  **Yes** (e.g., `let count++`) | ❌ **No** (Requires explicit assignment) |  **Yes** (e.g., `((count++))`) |

---

## 3. Advanced Assignments & Multi-Variables

### Multi-Variable Assignments with `let` vs `((...))`
`let` and `((...))` allow you to chain multiple separate variable operations in one go. `$((...))` cannot do this natively without wrapping it in an assignment variable.
```bash
let x=5 y=10 z=x*y        # Valid
(( a = 5, b = 10, c = a + b )) # Valid (using commas in the math zone)
```

### Inline Variable Shorthands
Inside `let` or `((...))`, you can mutate variables using shorthand operators like `++`, `--`, `+=`, `*=`, and `-=`.
```bash
(( x++ ))   # Adds 1 to x
(( x *= 2 )) # Multiplies x by 2
```

---

## 4. Advanced Operators (Exponents & Bitwise)

Bash handles advanced integer calculations natively inside both `$(())` and `(())`.
* **Exponents (`**`)**: Evaluates power-of calculations (e.g., `(( result = 2 ** 3 ))` results in `8`).
* **Bitwise AND (`&`) & OR (`|`)**: Manipulates binary bits directly (e.g., `$(( 6 & 3 ))` outputs `2`).
* **Bitwise XOR (`^`) & NOT (`~`)**: Standard binary logical operations.
* **Bitwise Shifts (`<<` and `>>`)**: Shifts binary bits left or right (e.g., `$(( 2 << 3 ))` outputs `16`).

---

## 5. Non-Integer Math (Decimals/Floating-Point)

* **The Bash Limitation**: Bash **cannot** read or process decimals. Typing `echo $((1.5 + 2.5))` triggers a syntax error.
* **The `bc` Solution**: You must pipe equations as strings into the external utility `bc` (Arbitrary Precision Calculator).
* **Decimal Precision**: By default, `bc` rounds division to the nearest whole integer. You must pass `scale=N;` to define how many decimal places to preserve.
* **Capturing Output**: Combine `bc` with standard command substitution `$( ... )` to save the decimal back to a variable.

```bash
# Example: Adding decimals and capturing the result with 2 decimal places
result=\$(echo "scale=2; 2.5 * 4.2" | bc) # result = 10.50
```


# Bash Comparison Operators

Comparison operators are used to compare **numbers, strings, and patterns** in Bash.

## 1. Integer Comparisons

### `(( ))` — C-style

```bash
a=10
b=5

(( a == b ))
(( a != b ))
(( a < b ))
(( a > b ))
(( a <= b ))
(( a >= b ))
```

| Operator | Meaning               |
| -------- | --------------------- |
| `==`     | Equal                 |
| `!=`     | Not equal             |
| `<`      | Less than             |
| `>`      | Greater than          |
| `<=`     | Less than or equal    |
| `>=`     | Greater than or equal |

### `[[ ]]` / `[ ]` — Flag-based

```bash
[[ $a -eq $b ]]
[[ $a -ne $b ]]
[[ $a -lt $b ]]
[[ $a -gt $b ]]
[[ $a -le $b ]]
[[ $a -ge $b ]]
```

| Operator | Meaning               |
| -------- | --------------------- |
| `-eq`    | Equal                 |
| `-ne`    | Not equal             |
| `-lt`    | Less than             |
| `-gt`    | Greater than          |
| `-le`    | Less than or equal    |
| `-ge`    | Greater than or equal |

**Use `(( ))` for arithmetic comparisons.**

---

## 2. String Comparisons

```bash
[[ "$a" == "$b" ]]   # Equal
[[ "$a" != "$b" ]]   # Not equal
[[ "$a" < "$b" ]]    # Lexicographically less
[[ "$a" > "$b" ]]    # Lexicographically greater
[[ -z "$a" ]]        # Empty
[[ -n "$a" ]]        # Not empty
```

Always quote variables:

```bash
[[ "$var" == "text" ]]
```

---

## 3. Pattern Matching

Use `==` with glob patterns inside `[[ ]]`.

```bash
filename="script.sh"

[[ "$filename" == *.sh ]]       # Ends with .sh
[[ "$filename" == script* ]]    # Starts with script
[[ "$filename" == ?ello ]]      # One character + ello
[[ "$filename" == [abc]* ]]     # Starts with a, b, or c
```

### Glob Patterns

```text
*       Any number of characters
?       Exactly one character
[...]   Character class
```

---

## 4. Regex Matching

Use `=~` for regular expressions:

```bash
[[ "$value" =~ ^[0-9]+$ ]]
```

### Do NOT quote the regex

```bash
# Wrong
[[ "test123" =~ "^[a-z]+[0-9]+$" ]]

# Correct
[[ "test123" =~ ^[a-z]+[0-9]+$ ]]
```

### `BASH_REMATCH`

```bash
[[ "hello123" =~ ^([a-z]+)([0-9]+)$ ]]

echo "${BASH_REMATCH[0]}"  # Full match
echo "${BASH_REMATCH[1]}"  # Capture group 1
echo "${BASH_REMATCH[2]}"  # Capture group 2
```

---

## 5. `test` and `[ ]`

`test` and `[ ]` are POSIX-compliant and equivalent.

```bash
test 5 -eq 5
[ 5 -eq 5 ]

test -n "hello"
[ -z "" ]

[ "$USER" = "root" ] && echo "You are root" || echo "Not root"
```

### Spaces are required

```bash
# Wrong
[$a -eq $b]
[ $a -eq$b ]
[ "$a"="$b" ]

# Correct
[ $a -eq $b ]
[ "$a" = "$b" ]
```

---

## 6. `[[ ]]` vs `[ ]`

### Prefer `[[ ]]` in Bash

```bash
[[ "$name" == "John" ]]
```

Advantages:

* Safer
* No word splitting
* Supports glob patterns
* Supports regex with `=~`
* `<` and `>` do not need escaping

### Use `[ ]` for POSIX portability

```bash
[ "$name" = "John" ]
```

---

## 7. Common Mistakes

### `=` vs `==`

```bash
[ "$str" = "hello" ]       # [ ] → use =
[[ "$str" == "hello" ]]    # [[ ]] → prefer ==
```

### Don't use `-eq` for strings

```bash
# Wrong
[[ "$str" -eq "hello" ]]

# Correct
[[ "$str" == "hello" ]]
```

### Don't compare numbers as strings

```bash
# String comparison → problematic
[[ "10" > "9" ]]

# Numeric comparison → correct
[[ 10 -gt 9 ]]
(( 10 > 9 ))
```

---

## 8. Input Validation Exercise

Create a script that:

1. Checks if a number is between `1-100`
2. Checks if a string is not empty
3. Checks if a filename ends with `.sh`
4. Validates a simple email using regex

### Example Solutions

```bash
# Number 1-100
(( number >= 1 && number <= 100 ))

# Non-empty string
[[ -n "$name" ]]

# .sh extension
[[ "$filename" == *.sh ]]

# Simple email
[[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
```

---

## Quick Cheat Sheet

```bash
# Numbers with (( ))
(( a == b ))
(( a != b ))
(( a < b ))
(( a > b ))
(( a <= b ))
(( a >= b ))

# Numbers with [[ ]]
[[ $a -eq $b ]]
[[ $a -ne $b ]]
[[ $a -lt $b ]]
[[ $a -gt $b ]]
[[ $a -le $b ]]
[[ $a -ge $b ]]

# Strings
[[ "$a" == "$b" ]]
[[ "$a" != "$b" ]]
[[ "$a" < "$b" ]]
[[ "$a" > "$b" ]]
[[ -z "$a" ]]
[[ -n "$a" ]]

# Glob patterns
[[ "$file" == *.sh ]]
[[ "$file" == script* ]]
[[ "$file" == ?ello ]]
[[ "$file" == [abc]* ]]

# Regex
[[ "$value" =~ ^[0-9]+$ ]]

# POSIX [ ]
[ "$a" = "$b" ]
[ "$a" != "$b" ]
[ -z "$a" ]
[ -n "$a" ]
```

---

## Golden Rules

```text
(( ))  → Arithmetic comparisons
[[ ]]  → Preferred Bash test
[ ]    → POSIX/portable test

-eq -ne -lt -gt -le -ge → Numeric comparisons
== != < >               → String comparisons
-z                      → Empty string
-n                      → Non-empty string
== + glob               → Pattern matching
=~ + regex              → Regex matching

Quote variables in comparisons.
Do NOT quote regex patterns.
Spaces are required inside [ ].
Do NOT use -eq for strings.
Do NOT compare numbers as strings.
```

## Next Topic

**Logical Operators:** `&&` AND, `||` OR, `!` NOT.

