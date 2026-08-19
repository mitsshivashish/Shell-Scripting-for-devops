# Testing Bash Scripts
 
Untested code is broken code waiting to happen. While Bash scripts are often treated as "throwaway," production scripts deserve proper testing. This guide covers techniques from simple assertions to full test frameworks.
 
## Table of Contents
 
- [Basic Testing Techniques](#basic-testing-techniques)
- [Unit Testing Functions](#unit-testing-functions)
- [Integration Testing](#integration-testing)
- [Test Frameworks: BATS](#test-frameworks-bats-bash-automated-testing-system)
- [CI/CD Integration](#cicd-integration)
- [ShellCheck Integration](#shellcheck-integration)
- [Common Mistakes](#common-mistakes)
- [Summary](#summary)
---
 
## Basic Testing Techniques
 
Start with simple, built-in testing approaches before reaching for frameworks.
 
> **Test-Driven Workflow:** Write a failing test, implement the feature, verify the test passes. This ensures your code actually does what you think it does.
 
### Assert Functions
 
```bash
# Simple assertion library
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should be equal}"
 
    if [[ "$expected" != "$actual" ]]; then
        echo "FAIL: $message"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        return 1
    fi
    echo "PASS: $message"
    return 0
}
 
assert_true() {
    local condition="$1"
    local message="${2:-Condition should be true}"
 
    if ! eval "$condition"; then
        echo "FAIL: $message"
        echo "  Condition: $condition"
        return 1
    fi
    echo "PASS: $message"
    return 0
}
 
assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist: $file}"
 
    if [[ ! -f "$file" ]]; then
        echo "FAIL: $message"
        return 1
    fi
    echo "PASS: $message"
    return 0
}
 
assert_exit_code() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Exit code should be $expected}"
 
    if [[ "$expected" -ne "$actual" ]]; then
        echo "FAIL: $message (got $actual)"
        return 1
    fi
    echo "PASS: $message"
    return 0
}
 
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Should contain substring}"
 
    if [[ "$haystack" != *"$needle"* ]]; then
        echo "FAIL: $message"
        echo "  Looking for: '$needle'"
        echo "  In: '$haystack'"
        return 1
    fi
    echo "PASS: $message"
    return 0
}
```
 
---
 
## Unit Testing Functions
 
Test individual functions in isolation for targeted verification.
 
```bash
# Function to test
calculate_sum() {
    local a="$1"
    local b="$2"
    echo $((a + b))
}
 
validate_email() {
    local email="$1"
    [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}
 
# Unit tests
test_calculate_sum() {
    echo "Testing calculate_sum..."
 
    local result
 
    result=$(calculate_sum 2 3)
    assert_equals "5" "$result" "2 + 3 = 5"
 
    result=$(calculate_sum 0 0)
    assert_equals "0" "$result" "0 + 0 = 0"
 
    result=$(calculate_sum -5 10)
    assert_equals "5" "$result" "-5 + 10 = 5"
}
 
test_validate_email() {
    echo "Testing validate_email..."
 
    validate_email "user@example.com"
    assert_exit_code 0 $? "Valid email accepted"
 
    validate_email "invalid-email"
    assert_exit_code 1 $? "Invalid email rejected"
 
    validate_email "user@domain"
    assert_exit_code 1 $? "Email without TLD rejected"
}
 
# Test runner
run_tests() {
    local failed=0
 
    test_calculate_sum || ((failed++))
    test_validate_email || ((failed++))
 
    echo ""
    if [[ $failed -eq 0 ]]; then
        echo "All tests passed!"
        return 0
    else
        echo "Tests failed: $failed"
        return 1
    fi
}
 
run_tests
```
 
---
 
## Integration Testing
 
Test scripts as a whole, verifying they work correctly end-to-end.
 
```bash
#!/usr/bin/env bash
# Integration test suite for backup.sh
 
readonly SCRIPT_UNDER_TEST="./backup.sh"
readonly TEST_DIR="/tmp/backup_test_$$"
 
# Setup test environment
setup() {
    mkdir -p "$TEST_DIR"/{source,dest}
    echo "test file 1" > "$TEST_DIR/source/file1.txt"
    echo "test file 2" > "$TEST_DIR/source/file2.txt"
}
 
# Cleanup after tests
teardown() {
    rm -rf "$TEST_DIR"
}
 
# Test: Script runs without error
test_script_runs() {
    echo "Test: Script runs successfully"
 
    $SCRIPT_UNDER_TEST "$TEST_DIR/source" "$TEST_DIR/dest" >/dev/null 2>&1
    local exit_code=$?
 
    assert_exit_code 0 $exit_code "Script should exit with 0"
}
 
# Test: Files are copied correctly
test_files_copied() {
    echo "Test: Files are copied to destination"
 
    $SCRIPT_UNDER_TEST "$TEST_DIR/source" "$TEST_DIR/dest" >/dev/null 2>&1
 
    assert_file_exists "$TEST_DIR/dest/file1.txt"
    assert_file_exists "$TEST_DIR/dest/file2.txt"
 
    local original=$(cat "$TEST_DIR/source/file1.txt")
    local copied=$(cat "$TEST_DIR/dest/file1.txt")
    assert_equals "$original" "$copied" "File content preserved"
}
 
# Test: Error on missing source
test_missing_source_fails() {
    echo "Test: Missing source returns error"
 
    $SCRIPT_UNDER_TEST "/nonexistent" "$TEST_DIR/dest" >/dev/null 2>&1
    local exit_code=$?
 
    assert_true "[[ $exit_code -ne 0 ]]" "Should fail with non-zero exit"
}
 
# Test: Help flag works
test_help_flag() {
    echo "Test: Help flag shows usage"
 
    local output=$($SCRIPT_UNDER_TEST --help 2>&1)
 
    assert_true "[[ \"$output\" == *\"Usage\"* ]]" "Help contains Usage"
    assert_true "[[ \"$output\" == *\"--help\"* ]]" "Help mentions --help"
}
 
# Main test runner
main() {
    echo "=== Integration Tests for backup.sh ==="
    echo ""
 
    setup
    trap teardown EXIT
 
    local tests_failed=0
 
    test_script_runs || ((tests_failed++))
    test_files_copied || ((tests_failed++))
    test_missing_source_fails || ((tests_failed++))
    test_help_flag || ((tests_failed++))
 
    echo ""
    echo "=== Results ==="
    if [[ $tests_failed -eq 0 ]]; then
        echo "All integration tests passed!"
        exit 0
    else
        echo "Failed tests: $tests_failed"
        exit 1
    fi
}
 
main
```
 
---
 
## Test Frameworks: BATS (Bash Automated Testing System)
 
For larger projects, use dedicated testing frameworks.
 
```bash
# test_backup.bats
 
# Setup runs before each test
setup() {
    TEST_DIR="$(mktemp -d)"
    mkdir -p "$TEST_DIR"/{source,dest}
    echo "content" > "$TEST_DIR/source/file.txt"
}
 
# Teardown runs after each test
teardown() {
    rm -rf "$TEST_DIR"
}
 
@test "backup creates destination directory" {
    run ./backup.sh "$TEST_DIR/source" "$TEST_DIR/newdest"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/newdest" ]
}
 
@test "backup copies files correctly" {
    run ./backup.sh "$TEST_DIR/source" "$TEST_DIR/dest"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/dest/file.txt" ]
}
 
@test "backup preserves file content" {
    ./backup.sh "$TEST_DIR/source" "$TEST_DIR/dest"
 
    original=$(cat "$TEST_DIR/source/file.txt")
    copied=$(cat "$TEST_DIR/dest/file.txt")
    [ "$original" = "$copied" ]
}
 
@test "backup fails on missing source" {
    run ./backup.sh "/nonexistent" "$TEST_DIR/dest"
    [ "$status" -ne 0 ]
}
 
@test "help flag shows usage information" {
    run ./backup.sh --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage"* ]]
}
```
 
### Installing BATS
 
```bash
# macOS
brew install bats-core
 
# Linux (apt)
sudo apt install bats
 
# Run tests
bats test_backup.bats
```
 
---
 
## CI/CD Integration
 
Run tests automatically on every commit.
 
```yaml
# .github/workflows/test.yml
name: Test Bash Scripts
 
on: [push, pull_request]
 
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
 
      - name: Install BATS
        run: |
          sudo apt-get update
          sudo apt-get install -y bats
 
      - name: Run ShellCheck
        run: |
          shellcheck scripts/*.sh
 
      - name: Run unit tests
        run: |
          bats tests/
 
      - name: Run integration tests
        run: |
          ./tests/integration/run_all.sh
```
 
---
 
## ShellCheck Integration
 
```bash
# Run ShellCheck on all scripts
shellcheck scripts/*.sh
 
# Ignore specific warnings
# shellcheck disable=SC2086
echo $unquoted_var
 
# Check with severity level
shellcheck --severity=warning scripts/*.sh
```
 
---
 
## Common Mistakes
 
### 1. Not isolating tests
 
```bash
# Wrong - tests affect each other
test1() {
    create_file "/tmp/test.txt"  # Left behind!
}
 
# Correct - use setup/teardown
setup() { TEST_DIR=$(mktemp -d); }
teardown() { rm -rf "$TEST_DIR"; }
trap teardown EXIT
```
 
### 2. Testing implementation, not behavior
 
```bash
# Wrong - tests internal details
assert_equals "grep" "$SEARCH_COMMAND"
 
# Correct - test the outcome
result=$(search_for "pattern" "file.txt")
assert_equals "found" "$result"
```
 
---
 
## Summary
 
- **Assertions** — build simple assert functions for quick checks
- **Unit Tests** — test functions in isolation
- **Integration** — test scripts end-to-end with setup/teardown
- **BATS** — use for larger projects with many tests
- **ShellCheck** — static analysis catches bugs early
- **CI/CD** — automate testing on every commit












# Testing Bash Scripts — Line-by-Line Guide
 
Untested code is broken code waiting to happen. While Bash scripts are often treated as "throwaway," production scripts deserve proper testing. This guide walks through **every line** of code, from simple assertions to full test frameworks and CI/CD.
 
## Table of Contents
 
- [Basic Testing Techniques](#basic-testing-techniques)
- [Unit Testing Functions](#unit-testing-functions)
- [Integration Testing](#integration-testing)
- [Test Frameworks: BATS](#test-frameworks-bats-bash-automated-testing-system)
- [CI/CD Integration](#cicd-integration)
- [ShellCheck Integration](#shellcheck-integration)
- [Common Mistakes](#common-mistakes)
- [Summary](#summary)
---
 
## Basic Testing Techniques
 
Start with simple, built-in testing approaches before reaching for frameworks.
 
> **Test-Driven Workflow:** Write a failing test, implement the feature, verify the test passes. This ensures your code actually does what you think it does.
 
### `assert_equals`
 
```bash
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should be equal}"
 
    if [[ "$expected" != "$actual" ]]; then
        echo "FAIL: $message"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        return 1
    fi
    echo "PASS: $message"
    return 0
}
```
 
| Line | Explanation |
|---|---|
| `assert_equals() {` | Defines a function named `assert_equals`. Everything until the matching `}` is its body. |
| `local expected="$1"` | Captures the function's 1st argument into a **local** variable `expected` (local = only exists inside this function, doesn't leak out). |
| `local actual="$2"` | Captures the 2nd argument into `actual`. |
| `local message="${3:-Values should be equal}"` | Captures the 3rd argument into `message`. The `${3:-...}` syntax means "use `$3` if it was passed, otherwise default to the text after `:-`." This makes the message argument optional. |
| `if [[ "$expected" != "$actual" ]]; then` | Starts a conditional. `[[ ]]` is Bash's extended test syntax. `!=` checks string inequality. Both variables are quoted to prevent word-splitting/globbing issues if they contain spaces or special characters. |
| `echo "FAIL: $message"` | If the values differ, print `FAIL:` followed by the custom or default message. |
| `echo "  Expected: '$expected'"` | Print what value was expected, indented for readability. |
| `echo "  Actual:   '$actual'"` | Print what value was actually received, so you can compare them at a glance. |
| `return 1` | Exit the function with status `1` (failure by convention — `0` = success, anything else = failure). |
| `fi` | Ends the `if` block. |
| `echo "PASS: $message"` | If execution reaches here (values matched), print a PASS line. |
| `return 0` | Exit the function with status `0` (success). |
| `}` | Closes the function definition. |
 
### `assert_true`
 
```bash
assert_true() {
    local condition="$1"
    local message="${2:-Condition should be true}"
 
    if ! eval "$condition"; then
        echo "FAIL: $message"
        echo "  Condition: $condition"
        return 1
    fi
    echo "PASS: $message"
    return 0
}
```
 
| Line | Explanation |
|---|---|
| `assert_true() {` | Defines the `assert_true` function. |
| `local condition="$1"` | Stores the 1st argument — expected to be a **string containing a shell condition**, e.g. `"[[ 5 -gt 0 ]]"`. |
| `local message="${2:-Condition should be true}"` | Optional 2nd argument for a custom failure/success message, with a default. |
| `if ! eval "$condition"; then` | `eval` takes the string in `$condition` and executes it as if it were typed directly in the shell. The `!` negates the result, so this block runs **if the condition is false** (or fails). |
| `echo "FAIL: $message"` | Print failure message. |
| `echo "  Condition: $condition"` | Print the actual condition string that failed, for debugging. |
| `return 1` | Return failure status. |
| `fi` | Ends the `if`. |
| `echo "PASS: $message"` | Reached only if the condition was true — print success. |
| `return 0` | Return success status. |
| `}` | Closes the function. |
 
### `assert_file_exists`
 
```bash
assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist: $file}"
 
    if [[ ! -f "$file" ]]; then
        echo "FAIL: $message"
        return 1
    fi
    echo "PASS: $message"
    return 0
}
```
 
| Line | Explanation |
|---|---|
| `assert_file_exists() {` | Defines the function. |
| `local file="$1"` | 1st argument is the path to check. |
| `local message="${2:-File should exist: $file}"` | Optional message; the default dynamically includes the file path. |
| `if [[ ! -f "$file" ]]; then` | `-f "$file"` is true if the path exists **and** is a regular file. The `!` negates it — so this block runs if the file does **not** exist. |
| `echo "FAIL: $message"` | Print failure. |
| `return 1` | Return failure status. |
| `fi` | Ends `if`. |
| `echo "PASS: $message"` | File exists — print success. |
| `return 0` | Return success status. |
| `}` | Closes the function. |
 
### `assert_exit_code`
 
```bash
assert_exit_code() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Exit code should be $expected}"
 
    if [[ "$expected" -ne "$actual" ]]; then
        echo "FAIL: $message (got $actual)"
        return 1
    fi
    echo "PASS: $message"
    return 0
}
```
 
| Line | Explanation |
|---|---|
| `assert_exit_code() {` | Defines the function. |
| `local expected="$1"` | The exit code you expect (e.g. `0`). |
| `local actual="$2"` | The exit code you actually got — usually passed in as `$?` from the caller. |
| `local message="${3:-Exit code should be $expected}"` | Optional message, defaulting to a message that embeds the expected value. |
| `if [[ "$expected" -ne "$actual" ]]; then` | `-ne` is the **numeric** "not equal" operator (as opposed to `!=`, which is string comparison). Used here because exit codes are numbers. |
| `echo "FAIL: $message (got $actual)"` | Print failure along with what was actually received. |
| `return 1` | Return failure. |
| `fi` | Ends `if`. |
| `echo "PASS: $message"` | Codes matched — print success. |
| `return 0` | Return success. |
| `}` | Closes the function. |
 
### `assert_contains`
 
```bash
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Should contain substring}"
 
    if [[ "$haystack" != *"$needle"* ]]; then
        echo "FAIL: $message"
        echo "  Looking for: '$needle'"
        echo "  In: '$haystack'"
        return 1
    fi
    echo "PASS: $message"
    return 0
}
```
 
| Line | Explanation |
|---|---|
| `assert_contains() {` | Defines the function. |
| `local haystack="$1"` | The full string to search within ("haystack" is the classic name for "the big string you're searching in"). |
| `local needle="$2"` | The substring you're looking for. |
| `local message="${3:-Should contain substring}"` | Optional message with a default. |
| `if [[ "$haystack" != *"$needle"* ]]; then` | `*"$needle"*` is a Bash **glob pattern**: "any characters, then the needle, then any characters." Combined with `!=` inside `[[ ]]`, this checks "does haystack NOT match this pattern" — i.e., does it not contain the needle. |
| `echo "FAIL: $message"` | Print failure. |
| `echo "  Looking for: '$needle'"` | Show what was being searched for. |
| `echo "  In: '$haystack'"` | Show what string it was searched in — helps debugging. |
| `return 1` | Return failure. |
| `fi` | Ends `if`. |
| `echo "PASS: $message"` | Substring was found — print success. |
| `return 0` | Return success. |
| `}` | Closes the function. |
 
---
 
## Unit Testing Functions
 
Test individual functions in isolation for targeted verification.
 
### Functions under test
 
```bash
calculate_sum() {
    local a="$1"
    local b="$2"
    echo $((a + b))
}
```
 
| Line | Explanation |
|---|---|
| `calculate_sum() {` | Defines the function to be tested. |
| `local a="$1"` | Stores the 1st argument as `a`. |
| `local b="$2"` | Stores the 2nd argument as `b`. |
| `echo $((a + b))` | `$(( ))` is Bash **arithmetic expansion** — it evaluates `a + b` as a math expression (not string concatenation) and `echo` prints the numeric result. This is how the function "returns" a value — via printed output, which a caller captures with `$(...)`. |
| `}` | Closes the function. |
 
```bash
validate_email() {
    local email="$1"
    [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}
```
 
| Line | Explanation |
|---|---|
| `validate_email() {` | Defines the function. |
| `local email="$1"` | Stores the argument to check. |
| `[[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]` | `=~` is Bash's **regex match** operator. The pattern means: start (`^`) → one or more letters/digits/`.`/`_`/`%`/`+`/`-` → literal `@` → one or more letters/digits/`.`/`-` → literal `.` → two or more letters → end (`$`). This is a simplified "looks like an email" check. Note there's no `echo`/`return` — the exit status of this `[[ ]]` test **is** the function's return value automatically (0 if matched, 1 if not). |
| `}` | Closes the function. |
 
### `test_calculate_sum`
 
```bash
test_calculate_sum() {
    echo "Testing calculate_sum..."
 
    local result
 
    result=$(calculate_sum 2 3)
    assert_equals "5" "$result" "2 + 3 = 5"
 
    result=$(calculate_sum 0 0)
    assert_equals "0" "$result" "0 + 0 = 0"
 
    result=$(calculate_sum -5 10)
    assert_equals "5" "$result" "-5 + 10 = 5"
}
```
 
| Line | Explanation |
|---|---|
| `test_calculate_sum() {` | Defines the test function for `calculate_sum`. |
| `echo "Testing calculate_sum..."` | Prints a header so test output is readable when scanning logs. |
| `local result` | Declares `result` as local, without assigning yet — it'll be reused across three checks. |
| `result=$(calculate_sum 2 3)` | `$( )` is **command substitution** — it runs `calculate_sum 2 3`, captures whatever it `echo`ed, and stores it in `result`. |
| `assert_equals "5" "$result" "2 + 3 = 5"` | Checks that the result equals `"5"`, with a descriptive message for the test log. |
| `result=$(calculate_sum 0 0)` | Runs the function again with a boundary case (zero). |
| `assert_equals "0" "$result" "0 + 0 = 0"` | Verifies the zero case. |
| `result=$(calculate_sum -5 10)` | Runs the function with a negative number, another edge case. |
| `assert_equals "5" "$result" "-5 + 10 = 5"` | Verifies negative-number arithmetic works correctly. |
| `}` | Closes the function. |
 
### `test_validate_email`
 
```bash
test_validate_email() {
    echo "Testing validate_email..."
 
    validate_email "user@example.com"
    assert_exit_code 0 $? "Valid email accepted"
 
    validate_email "invalid-email"
    assert_exit_code 1 $? "Invalid email rejected"
 
    validate_email "user@domain"
    assert_exit_code 1 $? "Email without TLD rejected"
}
```
 
| Line | Explanation |
|---|---|
| `test_validate_email() {` | Defines the test function. |
| `echo "Testing validate_email..."` | Header for readable output. |
| `validate_email "user@example.com"` | Calls the function with a valid email. Its exit status (0 or 1) is stored automatically in the special variable `$?`. |
| `assert_exit_code 0 $? "Valid email accepted"` | Checks that `$?` (the exit code just set by the line above) equals `0`, meaning the email was accepted. **Important:** `$?` must be read immediately after the command — any command in between would overwrite it. |
| `validate_email "invalid-email"` | Calls the function with a string that has no `@`, expected to fail. |
| `assert_exit_code 1 $? "Invalid email rejected"` | Confirms the function correctly returned failure (`1`). |
| `validate_email "user@domain"` | Calls the function with a tricky edge case: has an `@` but no valid top-level domain (like `.com`). |
| `assert_exit_code 1 $? "Email without TLD rejected"` | Confirms this edge case is correctly rejected too. |
| `}` | Closes the function. |
 
### `run_tests` (test runner)
 
```bash
run_tests() {
    local failed=0
 
    test_calculate_sum || ((failed++))
    test_validate_email || ((failed++))
 
    echo ""
    if [[ $failed -eq 0 ]]; then
        echo "All tests passed!"
        return 0
    else
        echo "Tests failed: $failed"
        return 1
    fi
}
 
run_tests
```
 
| Line | Explanation |
|---|---|
| `run_tests() {` | Defines the top-level function that runs everything. |
| `local failed=0` | Initializes a counter for failed test functions. |
| `test_calculate_sum \|\| ((failed++))` | Runs `test_calculate_sum`. `\|\|` means "run the next part only if the left side failed (non-zero exit)." `((failed++))` is arithmetic increment — bumps the counter by 1 if the test function failed. |
| `test_validate_email \|\| ((failed++))` | Same pattern for the email test. |
| `echo ""` | Prints a blank line for spacing before the summary. |
| `if [[ $failed -eq 0 ]]; then` | Checks if the failure counter is still zero (numeric `-eq`, "equal"). |
| `echo "All tests passed!"` | If nothing failed, print a success summary. |
| `return 0` | Return overall success. |
| `else` | Otherwise... |
| `echo "Tests failed: $failed"` | ...report how many test *functions* failed (not individual assertions). |
| `return 1` | Return overall failure. |
| `fi` | Ends the `if`. |
| `}` | Closes `run_tests`. |
| `run_tests` | Actually calls the function — without this line, nothing above would ever execute. |
 
---
 
## Integration Testing
 
Test scripts as a whole, verifying they work correctly end-to-end.
 
```bash
#!/usr/bin/env bash
# Integration test suite for backup.sh
 
readonly SCRIPT_UNDER_TEST="./backup.sh"
readonly TEST_DIR="/tmp/backup_test_$$"
```
 
| Line | Explanation |
|---|---|
| `#!/usr/bin/env bash` | The **shebang** — tells the OS to run this file using `bash`, found via the `env` command (portable across systems where bash might be in different locations). |
| `# Integration test suite for backup.sh` | A comment describing the file's purpose — ignored by Bash. |
| `readonly SCRIPT_UNDER_TEST="./backup.sh"` | Declares a constant (`readonly` prevents it from being reassigned later) pointing to the script being tested. |
| `readonly TEST_DIR="/tmp/backup_test_$$"` | Declares a constant temp directory path. `$$` is the **current process ID** — a unique number for this running script — so re-running the tests won't collide with a previous run's leftover directory. |
 
```bash
# Setup test environment
setup() {
    mkdir -p "$TEST_DIR"/{source,dest}
    echo "test file 1" > "$TEST_DIR/source/file1.txt"
    echo "test file 2" > "$TEST_DIR/source/file2.txt"
}
```
 
| Line | Explanation |
|---|---|
| `setup() {` | Defines the function that prepares a clean test environment. |
| `mkdir -p "$TEST_DIR"/{source,dest}` | `-p` creates parent directories as needed without erroring if they already exist. `{source,dest}` is **brace expansion** — Bash expands this into two paths, `$TEST_DIR/source` and `$TEST_DIR/dest`, both created in one command. |
| `echo "test file 1" > "$TEST_DIR/source/file1.txt"` | `>` redirects output into a file, creating (or overwriting) it. This creates a sample file with known content, to later verify it gets copied correctly. |
| `echo "test file 2" > "$TEST_DIR/source/file2.txt"` | Same, creating a second sample file. |
| `}` | Closes the function. |
 
```bash
# Cleanup after tests
teardown() {
    rm -rf "$TEST_DIR"
}
```
 
| Line | Explanation |
|---|---|
| `teardown() {` | Defines the cleanup function. |
| `rm -rf "$TEST_DIR"` | Deletes the entire test directory. `-r` = recursive (needed for directories), `-f` = force (don't prompt or error if files are missing). |
| `}` | Closes the function. |
 
```bash
# Test: Script runs without error
test_script_runs() {
    echo "Test: Script runs successfully"
 
    $SCRIPT_UNDER_TEST "$TEST_DIR/source" "$TEST_DIR/dest" >/dev/null 2>&1
    local exit_code=$?
 
    assert_exit_code 0 $exit_code "Script should exit with 0"
}
```
 
| Line | Explanation |
|---|---|
| `test_script_runs() {` | Defines this test case. |
| `echo "Test: Script runs successfully"` | Prints a label for readability. |
| `$SCRIPT_UNDER_TEST "$TEST_DIR/source" "$TEST_DIR/dest" >/dev/null 2>&1` | Runs the actual `backup.sh` script with real arguments. `>/dev/null` discards standard output (throws it away). `2>&1` redirects file descriptor 2 (stderr) to wherever file descriptor 1 (stdout) is currently pointing — which is `/dev/null` — so both normal output and error messages are silenced. |
| `local exit_code=$?` | Immediately captures the exit code of the script that just ran, before anything else can overwrite `$?`. |
| `assert_exit_code 0 $exit_code "Script should exit with 0"` | Verifies the script exited cleanly (code `0`). |
| `}` | Closes the function. |
 
```bash
# Test: Files are copied correctly
test_files_copied() {
    echo "Test: Files are copied to destination"
 
    $SCRIPT_UNDER_TEST "$TEST_DIR/source" "$TEST_DIR/dest" >/dev/null 2>&1
 
    assert_file_exists "$TEST_DIR/dest/file1.txt"
    assert_file_exists "$TEST_DIR/dest/file2.txt"
 
    local original=$(cat "$TEST_DIR/source/file1.txt")
    local copied=$(cat "$TEST_DIR/dest/file1.txt")
    assert_equals "$original" "$copied" "File content preserved"
}
```
 
