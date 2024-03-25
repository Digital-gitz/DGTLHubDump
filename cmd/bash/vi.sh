#!/bin/bash

counter=0
limit=50  # Change this value according to how many repetitions you want

while [ $counter -lt $limit ]
do
    echo -n "iv"
    counter=$((counter+1))
done
echo
