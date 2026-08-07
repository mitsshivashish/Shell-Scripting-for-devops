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

