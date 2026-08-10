#!/usr/bin/env bash
# TODO: Implement sum_args() that prints the sum of all integer arguments.
# - Handle any number of args (including 0).
# - If any argument is not an integer, return non-zero (fail) and print nothing.

sum_args() {
  # your code here
  sum=0
  for n in "$@"; do
	  [[ $n =~ ^-?[0-9]+$ ]] && sum=$(( sum + n)) || return 1
  done
  echo "The sum is : $sum"
}

sum_args
sum_args 1 2 3

# Examples:
# sum_args            -> 0
# sum_args 1 2 3     -> 6
# sum_args 10 -5 7   -> 12
# sum_args 1 two 3   -> exit non-zero

