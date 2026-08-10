#!/usr/bin/env bash
# TODO: Implement fib() that prints the nth Fibonacci number.
# - fib(0)=0, fib(1)=1
# - Use recursion for practice (OK for small n)
# - Return non-zero for invalid input

fib() {
  # your code here
  local n=$1
  if [ $n -eq 0 ] ;then
	echo "0"
	return
  fi

  if [ $n -eq 1 ]; then
	  echo "1"
	  return
  else
	local prev=$( fib $(( $n-2 )))
	local current=$( fib $(( $n-1)))
	echo $(( $current + $prev))
  fi

 }

fib 0  # -> 0
fib 1  # -> 1
fib 6  # -> 8
