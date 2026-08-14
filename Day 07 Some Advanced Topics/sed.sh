#!/usr/bin/env bash
# Remove blank lines and comment lines (starting with #) from stdin

# TODO: Implement using sed. Print cleaned output.
cat > input.txt << 'EOF'
#This line is comment

EOF

sed -E '/^\s*($|#)/d' input.txt


