#!/bin/bash

read -p "Enter the first number " num1
read -p "Enter the second number " num2

addition=$((num1 + num2))
subtraction=$((num1 - num2))
multiplication=$((num1 * $num2))
division=$((num1 / num2))

echo "Addition : $addition"
echo "Subtraction : $subtraction"
echo "Multiplication : $multiplication"
echo "Division : $divison"

