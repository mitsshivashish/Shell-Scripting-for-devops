#!/bin/bash

#This script performs all the arithmetic operations like +,- etc.
#then it performs the the increment and decrement operation
#after that it performs addition operation on floating point number using bc

echo "$((a=10 , b=15 , c=a+b , d=a-b , e=a%b , f=a/b ))"

echo "$((a++))"

echo "$((a+=50))"

first_number=5.2
second_number=6.8

result=$(echo "scale=2; $first_number+$second_number" | bc)
echo "The addition of float is : $result"

