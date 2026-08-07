#!/bin/bash

filepath="$0"

# Get the folder directory of the current script
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# Get the full path including the filename
SCRIPT_PATH="$SCRIPT_DIR/$(basename -- "${BASH_SOURCE[0]}")"


[[ -n $SCRIPT_PATH ]] && echo "File path provided : $SCRIPT_PATH" || echo "File path not provided"

[[ -e $filepath ]] && echo "File exists" || echo "File doesnt exist"

[[ -f $filepath ]] && echo "Regular file" || echo "Not regular path"

[[ -r $filepath ]] && echo "file is readable" || echo "Not readable file"
