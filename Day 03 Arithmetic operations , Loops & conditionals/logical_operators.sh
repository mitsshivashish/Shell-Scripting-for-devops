#!/bin/bash

:'
- Check if user is "admin" OR user is "root"
- Check if age is 18+ AND has permission flag
- Use NOT to check if user is NOT banned
- Use command chaining to create a log file only on success
'

read -p "Enter user (Please enter only admin or root) : " user

if [[ $user == "admin" ]]; then
	echo "user is $user"
elif [[ $user == "root" ]]; then
	echo "user is $user"
else
	echo "Invalid user"
fi

read -p "Enter age : " age

permission_flag=true
[[ $age -gt 18 && $permission_flag ]] && echo "valid user" || echo "invalid user"

banned_user=false
[[ -n $banned_user ]] && echo "not banned user" || echo "banned user"

[[ $? == 0 ]] && touch test.log || echo "command failed"
