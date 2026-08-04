#!/bin/bash

# This shell file is to automate the directory creation
# I wanna make  3 subdirectories with 1 main directory
# so i used the command mkdir to make directory
# -p to create parent directory if not existed
# -v to verbose the output


function make_directory () {
	name=$(mkdir -pv myproject/src myproject/docs myproject/scripts)
	echo "Created directory : $name"
}

make_directory
