#!/usr/bin/env bash
# Start two sleeps in background and wait for both

# TODO: Launch two sleeps with &, capture PIDs, wait for them, and print done

echo "A" ; sleep 2 ; echo "A done" &
PID1=$!
echo "B" ; sleep 2 ; echo "B done" &
PID2=$!

wait $PID1 $PID2
echo "All task done"

