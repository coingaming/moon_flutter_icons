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

    new_name=$(echo "$base" | awk -F, '{
        # Lowercase the entire string
        $0 = tolower($0);

        # Segment 1: Replace "=" with "_", and "-" with "_"
        gsub(/=/, "_", $1);
        gsub(/-/, "_", $1);

        # Segment 2: Keep numbers only
        gsub(/[^0-9]/, "", $2);

        # Segment 3: Discard everything before and including "="
        sub(/^[^=]*=/, "", $3);

        # Reassemble the segments
        print $1 "_" $2 "_" $3 ".svg";
    }')

    # Rename the file
    echo "Renaming $file to $new_name"
    mv "$file" "svgs/$new_name"
done

# Optimise the SVGs.
npx svgo -f svgs -r -o svgs

# Convert strokes to fills.
npx oslllo-svg-fixer -s svgs -d svgs --tr 1000

# Create icon font.
npx svgtofont -s svgs/ -o fonts/

# Move the created font to correct directory.
cp "./fonts/MoonIcons.ttf" "../lib/fonts/MoonIcons.ttf"

# Remove the SVGs folder
rm -rf svgs