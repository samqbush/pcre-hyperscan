#!/usr/bin/env bash

### ! MUST USE GNU GREP, BSD GREP WILL GIVE ERRONEOUS RESULTS ! ###
### ! SEDATED USES GNU GREP, BSD GREP DOES NOT HAVE A -P FLAG ! ###

filename="$1"
regexes=../../config/regexes.json

# Extract regex names and patterns from regexes.json
regex_list=$(jq -r '.regexes[] | to_entries[] | "\(.key):\(.value)"' "${regexes}")

# Allows a filename other than test_cases.txt to be passed as an argument
if [[ -z "$filename" ]]; then
  filename="fail.txt"
fi

echo "##################################################################"

declare -A match_count
missed_count=0

while read -r line; do
  match_found=false
  for regex_entry in ${regex_list}; do
    regex_name=$(echo "$regex_entry" | cut -d':' -f1)
    regex_pattern=$(echo "$regex_entry" | cut -d':' -f2-)
    regex_check=$(echo "$line" | grep -P "${regex_pattern}") # gnu grep for lines that match the current regex
    if [[ "$regex_check" ]]; then
      match_found=true
      echo "MATCHED: $line by REGEX NAME: $regex_name"
      ((match_count["$regex_name"]++))
      break
    fi
  done

  if [[ "$match_found" == false ]]; then
    echo "MISSED BY REGEX: $line"
    ((missed_count++))
  fi
done < "$filename"

echo "##################################################################"
echo "SUMMARY:"
echo "MISSED BY REGEX: $missed_count"
echo "MATCHED BY REGEX:"
for regex_name in "${!match_count[@]}"; do
  echo "  $regex_name: ${match_count[$regex_name]}"
done
echo "##################################################################"
