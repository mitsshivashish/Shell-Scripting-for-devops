#!/bin/bash

output="/tmp/output.txt"

{
printf "%-12s %20s\n" "app name" "Generated date"
printf "%-12s %20s\n" "------------" "-------------------"
printf "%-12s %20s\n" "Netfix" "$(date '+%Y-%m-%d %H:%M:%S')"
printf "%-12s %20s\n" "Youtube" "$(date '+%Y-%m-%d %H:%M:%S')"
printf "%-12s %20s\n" "Uber" "$(date '+%Y-%m-%d %H:%M:%S')"
printf "%-12s %20s\n" "Ola" "$(date '+%Y-%m-%d %H:%M:%S')"
printf "%-12s %20s\n" "Google" "$(date '+%Y-%m-%d %H:%M:%S')"
} | tee $output

total_apps=$(( $(wc -l < "$output") - 2))

{
printf  "\n====================================\n"
printf "%25s\n" "SUMMARY"
printf "The total number of lines are : %d\n" "$total_apps"
} | tee -a "$output"


rm -r $output
