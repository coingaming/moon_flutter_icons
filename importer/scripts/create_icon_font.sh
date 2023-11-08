#!/bin/bash

# When using local environment get the PAT variable from .env file. The GitHub Action 
# will use the one from the workflow environment by default.
export $(egrep -v '^#' .env | xargs)

# If anything in script fails exit immediately.
set -o errexit
set -o nounset
set -o pipefail

# Fetch icons from moon-icons-base repository
git clone --depth 1 https://$PAT@github.com/coingaming/moon-icons-base.git temp_repo
mkdir -p svgs
cp -r temp_repo/icons/* ./svgs/
rm -rf temp_repo

# Rename icons to the format appropriate for Flutter.
for file in svgs/*.svg; do
    base=$(basename "$file" .svg)

    # Lowercase the entire string
    base=$(echo "$base" | awk '{print tolower($0)}')

    # Trim whitespace
    base=$(echo "$base" | xargs)

    # Replace '=' in the first segment with '_', remove all but numbers in the second,
    # and map "1.5px" to "regular", "1px" to "thin" in the third.
    IFS=',' read -ra SEGMENTS <<< "$base"
    SEGMENTS[0]=$(echo "${SEGMENTS[0]}" | tr '=' '_')
    SEGMENTS[1]=$(echo "${SEGMENTS[1]}" | grep -o '[0-9]*')
    SEGMENTS[2]=$(echo "${SEGMENTS[2]}" | sed -e 's/.*1\.5px/regular/' -e 's/.*1px/thin/')

    # Reassemble the segments, replace remaining commas with underscores,
    # and replace any remaining hyphens with underscores
    new_name=$(IFS=_; echo "${SEGMENTS[*]}" | tr '-' '_').svg

    # Rename the file
    echo "Renaming $file to $new_name"
    mv "$file" "svgs/$new_name"
done

# Optimise the SVGs.
#npx svgo -f svgs -r -o svgs

# Modify SVG width and height to 1000px.
for file in svgs/*.svg; do
    sed -i.bak -e 's/width="[^"]*"/width="1000px"/g' -e 's/height="[^"]*"/height="1000px"/g' "$file" && rm "$file.bak"
done

# Convert strokes to fills.
npx oslllo-svg-fixer -s svgs -d svgs --tr 600

# Remove viewBox attribute from SVGs before converting to font.
for file in svgs/*.svg; do
    sed -i.bak 's/viewBox="[^"]*"//g' "$file" && rm "$file.bak"
done

# Create icon font.
npx svgtofont -s svgs/ -o fonts/

# Move the created font to correct directory.
cp "./fonts/MoonIcons.ttf" "../lib/fonts/MoonIcons.ttf"

# Remove the SVGs folder
rm -rf svgs