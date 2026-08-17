#!/bin/bash

set -euo pipefail

readonly EXIT_SUCCESS=0
readonly EXIT_ERROR=1
readonly EXIT_USAGE=2

temp_file=""

cleanup(){
	echo "Performing cleanup"
[[ -n "$temp_file" && -f "$temp_file" ]] && rm -r $temp_file
}

trap cleanup EXIT

die(){
 echo "Error : $*" >&2
 exit $EXIT_ERROR
}

trap 'on_error $LINENO ' ERR

usage(){
echo "Usage : $0"
exit $EXIT_USAGE
}

file_validation(){
 local file=$1

 [[ -n $file ]] || die "Input file required"
 [[ -f $file ]] || die "Must be a file"
 [[ -r $file ]] || die "File must be readable"
}

processing_file(){
local input=$1

temp_file=$(mktemp) || die "File creation failed"

echo "Processing: $input"

    # Simulate processing
    wc -l "$input" > "$temp_file"
    cat "$temp_file"

    echo "Processing complete"
}

main(){

[[ $# -eq 1 ]] || usage

processing_file=$1
file_validation=$1

exit $EXIT_SUCCESS
}

main "$@"




