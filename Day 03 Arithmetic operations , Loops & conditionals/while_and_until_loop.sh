#!/bin/bash

num=0

while true ; do 
	num=$(( $num+1 ))
	if [ $num -gt 10 ]; then 
		echo "Breaking after num greater than 10"
		break
	fi
	echo "$num"
done

echo "===================================="

echo -e "line1\nline2\nline3" | while IFS= read -r line ; do
echo "Line : $line"
done

echo "Now Entering until loop"

i=0
until [ $i -gt 5 ]; do
	i=$(( i + 1 ))
	if [ $i -eq 2 ]; then
		echo "Continue at 2"
		continue
	fi
	echo "$i"
done

echo "====================================="

for i in {a..d}; do
	for j in {a..b}; do

		echo "$i and $j"
		if [[ $i == $j ]]; then
			echo "if condition met breaking here"
			break
		fi
		
	done
done
