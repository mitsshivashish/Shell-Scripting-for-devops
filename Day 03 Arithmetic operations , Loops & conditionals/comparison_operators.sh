#!/bin/bash

read -p "enter the number " num

[[ $num -lt 100 && $num -gt 1 ]] && echo "Number is in range between 1-100" || echo "Number is not in range"

name="Henry"

[ -n $name ] && echo "String is not empty" || echo "String is empty"

filename="new_file.sh"

[[ $filename == *.sh ]] && echo "filename contains .sh extension" || echo "Filename doesnt contain .sh extension"

read -p "Enter email : " email

[[ $email =~ ^[a-zA-Z0-9._%+-]+\@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]] && echo "Valid email" || echo "Invalid email"

