#!/bin/bash

:'
Task: Create a function that validates configuration files!

Requirements:

- Check file exists and is readable
- Verify file is not empty
- Check for required keys (e.g., "host", "port")
- Return appropriate exit codes and messages
'

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


config_file="config.txt"
missing_keys=0


for key in "host" "port"; do
    
    if ! grep -q "^${key}=" "$config_file" 2>/dev/null; then
        echo "❌ Error: Required key '$key' is missing!"
        missing_keys=$((missing_keys + 1))
    fi
done

if [[ $missing_keys -eq 0 ]]; then
    echo "All required keys exist!"
fi



}

create_local
