#!/usr/bin/env bash
# Replace the username part of emails with *** while keeping domains.

# TODO: Read from stdin and mask emails like user@example.com -> ***@example.com

cat > data.txt << 'EOF'
alice alice@gmail.com
harsh harsh@gmail.com
aditya aditya@google.com
EOF

sed -E 's/[a-zA-Z0-9._%+-]+@([a-zA-Z0-9._+-]+)\.([a-zA-Z]{2,})/***@\1.\2/g' data.txt
:

