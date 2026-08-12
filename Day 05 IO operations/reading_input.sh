#!/usr/bin/env bash
# Read CSV line: name,age,city and print each on its own line

# TODO: Implement reading from stdin and splitting into name/age/city.


IFS=, read -r name age city
[[ $name =~ ^[a-zA-Z[:space:]]+$ ]] && echo "Name : $name" || echo "Invalid name"
[[ $age =~ ^[0-9]+$ ]] &&  echo "age : $age" || echo "Invalid age"
[[ $city =~ ^[a-zA-Z[:space:]]+$ ]] &&  echo "city : $city" || echo "Invalid city"


