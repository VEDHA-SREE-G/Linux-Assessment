#!/bin/bash

input_file="$1"
output_file="output.txt"

> "$output_file"

while read line
do 
    case "$line" in
        "\"frame.time\""*)
         echo "$line" >> "$output_file"
         ;;
        "\"wlan.fc.type\""*)
         echo "$line" >> "$output_file"
         ;;
        "\"wlan.fc.subtype\""*)
         echo "$line" >> "$output_file"
         ;;
    esac
done < "$input_file"

echo "Fetched and Stored to output.txt successfully"