#!/bin/bash

# This script is for comparison operators and it checks if number is between range of 1-100
# also it validates if string is not empty
# check if a filename has specific extension (.sh)
# using regex to validate email

read -p "enter the number " num

[[ $num -lt 100 && $num -gt 1 ]] && echo "Number is in range between 1-100" || echo "Number is not in range"

name="Henry"

[ -n $name ] && echo "String is not empty" || echo "String is empty"

filename="new_file.sh"

[[ $filename == *.sh ]] && echo "filename contains .sh extension" || echo "Filename doesnt contain .sh extension"

read -p "Enter email : " email

[[ $email =~ ^[a-zA-Z0-9._%+-]+\@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]] && echo "Valid email" || echo "Invalid email"

