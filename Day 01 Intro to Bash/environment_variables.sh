#!/bin/bash

# This Script displays some common env variables like HOME,PATH,USER
#

echo "HOME : $HOME"
echo "USER : $USER"
echo "PATH : $PATH"


# Regular variable (not exported)
MY_VAR="hello"
bash -c 'echo $MY_VAR'  # Output: (empty - child process can't see it)

# Export the variable
export MY_VAR="hello"
bash -c 'echo $MY_VAR'  # Output: hello (child process can see it)

env_count=$(env | wc -l)
echo "Total environment variables : $env_count"

echo "$PATH" | tr ':' '\n' | head -n 3
