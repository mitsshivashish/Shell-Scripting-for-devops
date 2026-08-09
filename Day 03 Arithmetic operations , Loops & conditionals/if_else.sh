#!/bin/bash

: '
- Create a variable for age
- Use if-elif-else to categorize: child (0-12), teenager (13-17), adult (18-64), senior (65+)
'

read -p 'Enter age : ' age

if [ $age -gt 0 -a $age -le 12 ] ; then
	echo "It is child"
elif [ $age -gt 12 -a $age -le 17 ]; then
	echo "It is teenager"
elif [ $age -gt 17 -a $age -le 64 ]; then
	echo "It is a adult"
else 
	echo "It is senior"
fi
