#!/bin/bash

myArray=(0 1 Rohit "Rohit Sahu")

echo "Value is 1st Index ${myArray[1]}"

echo "Value is 2nd Index ${myArray[2]}"

echo "All values of array are ${myArray[*]}"

echo "Length of an array is ${#myArray[*]}"

#Find values in a array in a particular range
echo "${myArray[*]:1:2}"
echo "${myArray[*]:1}"

#Inser new values in an array
myArray+=(30 40 50)

echo "${myArray[*]}"
