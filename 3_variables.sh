#!/bin/bash

name="Rohit"
age=21

echo "My name is $name and my age is $age"

name="Sahu"
echo "My name is $name"

#variable to store command outputs
HOSTNAME=$(hostname)

echo "The name of the machine is $HOSTNAME"

#define constant variables 

readonly surname="Sahu"

echo "My surnname is $surname"

command=$(ls)
echo "$command"

