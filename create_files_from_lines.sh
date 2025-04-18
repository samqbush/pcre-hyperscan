#!/bin/bash

# Create a test.txt and make sure that there is an empty line at the end
# Usage ./create_files_from_lines.sh ./testbed/your-new-folder/file_name.extension
# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 output_file_with_extension"
    exit 1
fi

input_file="tests.txt"
output_base="$1"
counter=1

# Extract the extension and validate it
extension="${output_base##*.}"
if [[ "$extension" != "java" && "$extension" != "txt" ]]; then
    echo "Error: Extension must be either .java or .txt"
    echo ".java should be used for generic passwords due to design limitations"
    exit 1
fi

# Remove the extension from the base name
output_base="${output_base%.*}"

# Read the input file line by line
while IFS= read -r line; do
    # Create a new file for each line
    output_file="${output_base}${counter}.${extension}"
    echo "$line" > "$output_file"
    echo "Created $output_file"
    ((counter++))
done < "$input_file"
