#!/bin/bash
# Directory Statistics Tool

dir_stats() {
    local dir="${1:-.}"

    echo "=== Directory Statistics: $dir ==="
    echo ""

    # Count files and directories
    local files=$(find "$dir" -type f | wc -l)
    local dirs=$(find "$dir" -type d | wc -l)
    echo "Files: $files"
    echo "Directories: $dirs"
    echo ""

    # Total size
    local size=$(du -sh "$dir" 2>/dev/null | cut -f1)
    echo "Total size: $size"
    echo ""

    # Largest files
    echo "Top 5 largest files:"
    find "$dir" -type f -exec ls -lh {} \; 2>/dev/null | \
        sort -k5 -hr | head -5 | \
        awk '{print "  " $5 " " $9}'
    echo ""

    # Files by extension
    echo "Files by extension:"
    find "$dir" -type f -name "*.*" | \
        sed 's/.*\.//' | sort | uniq -c | \
        sort -rn | head -10 | \
        awk '{print "  " $1 " ." $2}'
    echo ""

    # Recently modified
    echo "Recently modified (last 24h):"
    find "$dir" -type f -mtime -1 -exec ls -lh {} \; 2>/dev/null | \
        head -5 | awk '{print "  " $6 " " $7 " " $8 " " $9}'
}

# Run on current directory or specified path
dir_stats "${1:-.}"
