#!/bin/bash

read -p "Enter the file name " fileName

result=$(find -name "$fileName")

[[ ${#result} -gt 0 ]]  && echo "Files does exists" || echo "File does not exist" 
