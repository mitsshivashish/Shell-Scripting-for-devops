#!/bin/bash


#This script creates atleast 5 elements in error
# one imp thing to note among this is dont put "," while adding separate elements
# Display arrat length and first and last element 
# also when accessing all elements of array with @ , dont put $@ inside [] this.
# adding two elememts and then iterate through them
# 

names=("Aditya" "Ashish" "Krishnakant" "Uday" "Sunil")

echo "Length of names array : ${#names[@]}"

echo "First element is ${names[0]} & last element is ${names[4]}"

echo "name before modification : ${names[2]}"

names[2]="Udit"

echo "name after modification : ${names[2]}"

names+=("hiren" "Sakshi")

for num in "${names[@]}";
do
	echo "	- $num"
done


echo ""
echo ""

declare -A names_array

names_array[name]="Geeta"
names_array[age]="30"
names_array[city]="Indore"

for age in "${!names_array[@]}";
do
	echo "	- $age"
done
