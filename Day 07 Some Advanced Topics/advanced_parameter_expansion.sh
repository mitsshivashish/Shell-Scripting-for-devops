#!/usr/bin/env bash
# Given path=/var/log/nginx/access.log, print directory and basename without extension

path=/var/log/nginx/access.log

# TODO: Use parameter expansion to print the directory path and the filename without extension
base=${path##*/}
echo "Directory path is : ${path%/*}"
echo "file name without extension is : ${base%.*}"

