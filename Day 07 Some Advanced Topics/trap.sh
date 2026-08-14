#!/usr/bin/env bash
# Trap SIGINT and exit with 130 after printing a message

trap 'echo -e "\nCanceled"; exit 130' INT

echo "Process running. Press Ctrl+C to cancel..."

# Simulate an infinite wait loop
# Using 'sleep' inside a loop allows the trap to trigger immediately in Bash
while true; do
    sleep 1
done
