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
