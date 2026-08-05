#!/bin/bash

#This script displays the script name
#its total arguments
#checks for required arguments and print them
#then it checks whether program successed or not

echo "Currently running script is : $0"

for arg in $@ ;
do
	echo "  $arg"
done

first_argument="${1:?First argument is required}"
second_argument="${2:?second argument is required}"

echo "The first argument is $1"
echo "The second argument is $2"

echo "Total arguments are : $#"

echo "Does command succedd : $?"
