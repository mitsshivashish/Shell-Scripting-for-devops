#!/usr/bin/env bash
# TODO: Implement max() that echoes the larger of two integers.
# - Accept exactly two integer args.
# - Return non-zero on invalid input.

max() {
  # your code here
  larger=0
  first=$1
  second=$2
  [[ $first =~ ^-?[0-9]+$ && $second =~ ^-?[0-9]+$ ]] && larger=$(( $first > $second ? $first : $second )) || return 1
  echo "The larger number is : $larger"
}

# Expected:
# 9
# (non-zero exit for invalid)
max 5 9
max x 2 || echo "invalid input" 1>&2

