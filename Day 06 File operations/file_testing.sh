#!/bin/bash

create_local() {
test_dir="tmp/bash_file"
mkdir -p $test_dir
touch "$test_dir/test_file.txt"
sample_file="$test_dir/test_file.txt"

[[ -e $sample_file && -r $sample_file ]] && {
       	echo "File exists and is readable" 
} || {
       	echo "Error reading file or file doesnt exist"
       	return 1
}

[[ -s $sample_file ]] &&  echo "File is not empty" || echo "File is empty"
}

create_local
