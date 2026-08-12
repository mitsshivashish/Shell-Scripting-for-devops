#!/usr/bin/env bash
# Split stdout and stderr to different files, then combine both

# TODO: Produce one line to stdout and one to stderr, writing to out.txt and err.txt
# Then create both.txt containing both outputs.
#
#
{ echo ok; } 1> out.txt
{ ls /null/missing; } 2> err.txt
{ cat out.txt; cat err.txt; } >> both.txt 2>&1
cat both.txt

