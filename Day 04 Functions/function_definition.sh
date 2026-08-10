#!/bin/bash
# TODO: Implement greet() to print "Hello, NAME".
# - If no argument is given, default NAME to "World".
# - Do not modify any global variables.

greet() {
  # your code here
  echo "Hello, ${1:-"World"}"
}

# Expected:
# Hello, World
# Hello, Alice
greet
greet "Alice"

