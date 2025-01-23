#!/bin/bash

# When using local environment, get the PAT variable from .env file.
export $(egrep -v '^#' .env | xargs)

# Exit on error, uninitialized variable, or failed pipeline.
set -o errexit
set -o nounset
set -o pipefail

# Remove existing svgs folder if any.
if [ -d "svgs" ]; then
  echo "Removing existing svgs folder."
  rm -rf "svgs"
fi

# This command requires a FIGMA_TOKEN to be set in env.
npx figma-export use-config

# Build a list of sumnames (the part before the first comma).
# Sort them and count how many times each occurs.
# The output of "uniq -c" looks like:
#     <count> <sumname>
# For example:
#     6 Text=numbers-list
#     12 AnotherCategory
all_counts=$(ls svgs/*.svg | while read file; do
  base=$(basename "$file" .svg)
  # sumname is "Text=numbers-list" in "Text=numbers-list, Size=32, Weight=Light.svg"
  sumname=$(echo "$base" | awk -F, '{print $1}')
  echo "$sumname"
done | sort | uniq -c)

any_failure=false

# Process each line from all_counts
# The pattern is: "count sumname"
while read -r count sname; do
  # Remove leading/trailing whitespace just in case
  count=$(echo "$count" | xargs)
  sname=$(echo "$sname" | xargs)

  # Check if count is a multiple of 6
  if [ $((count % 6)) -ne 0 ]; then
    echo "Offending icon set '$sname' has $count icons (not a multiple of 6)"
    any_failure=true
  fi
done <<< "$all_counts"

if [ "$any_failure" = true ]; then
  echo "Sextet check failed. Exiting..."
  exit 1
fi

# Rename icons to the format appropriate for Flutter.
for file in svgs/*.svg; do
  base=$(basename "$file" .svg)

  new_name=$(echo "$base" | awk -F, '{
      # Lowercase the entire string
      $0 = tolower($0);

      # Segment 1: Replace "=" and "-" with "_"
      gsub(/=/, "_", $1);
      gsub(/-/, "_", $1);

      # Segment 2: Keep numbers only
      gsub(/[^0-9]/, "", $2);

      # Segment 3: Discard everything before and including "="
      sub(/^[^=]*=/, "", $3);

      # Reassemble segments
      print $1 "_" $2 "_" $3 ".svg";
  }')

  echo "Renaming $file to $new_name"
  mv "$file" "svgs/$new_name"
done

# Convert strokes to fills.
npx oslllo-svg-fixer -s svgs -d svgs --tr 1024

# Create the icon font.
npx svgtofont -s svgs/ -o fonts/

# Move the created font to the correct directory.
cp "./fonts/MoonIcons.ttf" "../lib/fonts/MoonIcons.ttf"

# Remove the SVGs folder.
rm -rf svgs
