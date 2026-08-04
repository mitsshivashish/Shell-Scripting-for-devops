#!/bin/bash

# this shell script creates a variable with a default username
# also a port set to default at 8080
# this script also counts the characters in a word
# then it extracts last 3 and first 3 words
# then using ${required:?} to ensure this variable is set

name="Aditya"
PORT=8080

echo "name :- ${name} & port = ${PORT}"

unset name
unset PORT

name="${name:=Shivashish}"
PORT="${PORT:=8080}"


test_text="Linux basic commands"


echo "name :- ${name} & port :- {$PORT}"

echo "Length of test_text : ${#test_text}"

echo "First 3 characters are ${test_text:0:3} & last 3 characters are ${test_text: -3}"

required="${required:?required variable must be set}"
echo "Required : $required"
