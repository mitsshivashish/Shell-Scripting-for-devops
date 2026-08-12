#!/usr/bin/env bash
# Read a line from stdin and output the top 3 most frequent words with counts
# TODO: Build a pipeline to normalize case, split words, count, and show top 3
#
#
echo "This line is a line" | tr '[:upper:]' '[:lower:]' | tr -c '[:alpha:]' '\n' | sort | uniq -c | head -n 3

