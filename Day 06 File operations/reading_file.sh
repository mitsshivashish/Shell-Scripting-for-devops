#!/bin/bash

:'
Count total number of lines
Count lines containing "error" (case-insensitive)
Display the first and last 3 lines
Parse and display unique IP addresses (first field)
'

sample_file="/tmp/sample.txt"
cat > "$sample_file" << 'EOF'
Line 1: Hello World
Line 2: Bash is powerful
Line 3: File operations are essential
Line 4: Learning is fun
Line 5: The end
EOF

log_file="/tmp/access.log"
cat > "$log_file" << 'EOF'
192.168.1.1 - - [01/Jan/2024] "GET /index.html" 200
192.168.1.2 - - [01/Jan/2024] "GET /error.html" 404
192.168.1.1 - - [01/Jan/2024] "POST /api" 500 Error
10.0.0.1 - - [01/Jan/2024] "GET /about.html" 200
192.168.1.3 - - [01/Jan/2024] "GET /contact" 200
10.0.0.1 - - [01/Jan/2024] "GET /error" 500 Error
EOF

errors=$(grep -ic "error" "$log_file")
echo "Lines with 'error': $errors"
echo ""


line_num=0
while IFS= read -r line; do
	((line_num++))
done < $sample_file

echo "The total number of lines are : $line_num"

first_3=$(head -n 3 "$log_file")
echo "first 3 lines are : $first_3"

last_3=$(tail -n 3 "$log_file")
echo "last 3 lines are : $last_3"

awk '{print $1 " are IP addresses"}' "$log_file" | sort | uniq -c
