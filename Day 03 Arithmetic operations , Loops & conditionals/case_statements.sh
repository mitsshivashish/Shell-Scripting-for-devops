#!/bin/bash


# This script checks for file extension using case statements
# Then it handles atleast 4 file types
# it includes the default case for invalid types
# also it checks for multiple file extensions of same type

read -p "Enter file name with extension : " filename

case $filename in
	*.txt|*.TXT)
		echo "File extension is document"
		;;
	*.png|*.PNG)
		echo "File extension is .png image"
		;;
	*.jpg|*.jpeg)
		echo "File extension is image"
		;;
	*.sh|*.SH)
		echo "File is a shell file"
		;;
	*.md)
		echo "File is a readme file"
		;;
	*)
		echo "Invalid file type"
		;;
esac


