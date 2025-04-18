#!/bin/bash

# Variables
ORG=your-org-name
REPO=your-repo-name

echo "Fetching secret scanning alerts from $ORG/$REPO..."

# Fetch the alerts and validate JSON
alerts=$(gh api --paginate "/repos/$ORG/$REPO/secret-scanning/alerts" 2>/dev/null)
if ! echo "$alerts" | jq empty 2>/dev/null; then
    echo "Error: Failed to fetch alerts or invalid JSON response."
    exit 1
fi

# Extract alert numbers and locations URLs
locations_urls=$(echo "$alerts" | jq -r '.[] | "\(.secret_type_display_name)|\(.locations_url)"')

# Fetch all locations in bulk and process them
summary=$(echo "$locations_urls" | while IFS='|' read -r secret_type locations_url; do
    # Fetch locations for the alert
    locations=$(gh api "$locations_url" 2>/dev/null)
    if ! echo "$locations" | jq empty 2>/dev/null; then
        echo "Warning: No locations found for $locations_url"
        continue
    fi

    # Count the number of paths
    path_count=$(echo "$locations" | jq -r '.[] | .details.path' | wc -l)

    # Output secret type and path count
    echo "$secret_type|$path_count"
done)

# Aggregate the summary
final_summary=$(echo "$summary" | awk -F'|' '
    NF == 2 { counts[$1] += $2 }
    END {
        for (type in counts) {
            printf "%-32s | %d\n", type, counts[type]
        }
    }
')

# Print summary table
echo -e "\nSummary Table:"
echo "Secret Type Display Name       | Total Paths"
echo "--------------------------------|------------"
echo "$final_summary"
