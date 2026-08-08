#!/bin/bash


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


