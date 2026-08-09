#!/bin/bash

: '
- Use a for-in loop to iterate over a list of items
- Use a C-style for loop to count from 1 to 10
- Iterate over an array and process each element
- Use brace expansion to generate a range
- Create a nested loop (optional: multiplication table)
'

nums=( 1 2 3 4 5 )

for num in ${nums[@]};
do
	echo "$num"
done

echo "============================================="

for (( i=1 ; i<=10 ; i++)); do
	echo "$i"
done

echo "=============================================="

for num in {1..5}; do
	echo "$num"
done

echo "=============================================="

for i in {1..5}; do
	for j in {1..5};do
		echo " $(( $i*$j ))"
	done
done
