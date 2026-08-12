#!/usr/bin/env bash
# Compare two lists in variables using process substitution

# TODO: Put two newline-separated lists into variables a and b, then diff their sorted forms using <()
#
a=$'Item 1\nItem 2\nItem 3\n'
b=$'Product 1\nProduct 2\nProduct 3\n'

diff <(printf "%s" "$a" | sort) <(printf "%s" "$b" | sort) | sed 's/^/| /'

