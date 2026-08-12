#!/bin/bash

<< 'EOF'
Task: Create a script that organizes files by extension!

Requirements:

Create directories for different file types (txt, log, sh)
Move files to appropriate directories based on extension
Set correct permissions (755 for scripts, 644 for others)
Count files moved to each directory
EOF

test_dir="/tmp/bash_test"
mkdir -p $test_dir/{txt,log,sh}
touch "$test_dir/file1.txt"
touch "$test_dir/undercover.log"
touch "$test_dir/mcu.sh"

for file in "$test_dir"/*; do
    # Skip if it is a directory
    if [[ -d "$file" ]]; then
        continue
    fi

    # Check if the file ends with .sh
    if [[ "$file" =~ \.sh$ ]]; then
        chmod 755 "$file"
        echo "Set 755 (Executable) -> $(basename "$file")"
    else
        chmod 600 "$file"
        echo "Set 600 (Private)    -> $(basename "$file")"
    fi
done


ls -l "$test_dir"

# cleanup
rm -rf "$test_dir"
