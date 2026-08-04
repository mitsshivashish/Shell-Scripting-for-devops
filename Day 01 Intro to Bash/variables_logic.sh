#!/bin/bash

# This shell file creates 4 variables
# It prints user's name , age & city
# Then we unset the variable so that i cant be used in future
# then we print the unset variable

read -p "Enter FirstName : " first_name
read -p "Enter lastname : " last_name
read -p "Enter Age : " age
read -p "Enter city : " city

echo "Hello my name is $first_name $last_name"
echo "I am currently $age years old and reciding in $city"

echo "Variable before unset : $age"

unset age

echo "Variable after unset : $age"
