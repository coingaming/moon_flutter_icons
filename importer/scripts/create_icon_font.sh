#!/bin/bash

# When using local environment get the PAT variable from .env file. With GitHub Actions 
# will use the one from the workflow environment by default.
export $(egrep -v '^#' .env | xargs)

# Fetch icons from moon-icons-base repository
git clone --depth 1 https://$PAT@github.com/coingaming/moon-icons-base.git temp_repo
mkdir -p svgs
cp -r temp_repo/icons/* ./svgs/
rm -rf temp_repo

# Rename icons to Flutter format
for file in svgs/*.svg; do
    base=$(basename "$file" .svg)

    new_name=$(echo "$base" | 
        awk -F, '{print $1}' | 
        tr '[:upper:]' '[:lower:]' |
        tr '=-' '__')_32.svg
    
    mv "$file" "svgs/$new_name"
done

# Create _16 and _24 suffix copies for each icon
for file in svgs/*_32.svg; do
    base=$(basename "$file" .svg)

    cp "$file" "svgs/${base/_32/_16}.svg"
    cp "$file" "svgs/${base/_32/_24}.svg"
done

# Optimise the SVGs
npx svgo -f svgs -r -o svgs

# Modify properties of SVGs
for file in svgs/*_32.svg; do
    sed -i.bak 's|/>| stroke-width="1.5px"/>|' "$file"
    
    size=$(echo "$file" | grep -o '_[0-9]*\.svg' | sed 's/[^0-9]*//g')
    
    sed -i.bak "s/width=\"[0-9]*\"/width=\"${size}\"/g" "$file"
    sed -i.bak "s/height=\"[0-9]*\"/height=\"${size}\"/g" "$file"

    rm "$file.bak"
done

for file in svgs/*_24.svg; do
    sed -i.bak 's|/>| stroke-width="2.25px"/>|' "$file"
    
    size=$(echo "$file" | grep -o '_[0-9]*\.svg' | sed 's/[^0-9]*//g')
    
    sed -i.bak "s/width=\"[0-9]*\"/width=\"${size}\"/g" "$file"
    sed -i.bak "s/height=\"[0-9]*\"/height=\"${size}\"/g" "$file"

    rm "$file.bak"
done

for file in svgs/*_16.svg; do
    sed -i.bak 's|/>| stroke-width="3px"/>|' "$file"
    
    size=$(echo "$file" | grep -o '_[0-9]*\.svg' | sed 's/[^0-9]*//g')
    
    sed -i.bak "s/width=\"[0-9]*\"/width=\"${size}\"/g" "$file"
    sed -i.bak "s/height=\"[0-9]*\"/height=\"${size}\"/g" "$file"

    rm "$file.bak"
done

# Convert strokes to fills
npx oslllo-svg-fixer -s svgs -d svgs --tr 600

# Remove viewBox attribute from SVGs before converting to font
for file in svgs/*.svg; do
    sed -i.bak 's/viewBox="[^"]*"//g' "$file"
    rm "$file.bak"
done

# Remove previous icon font and config
TARGET_DIR="$(dirname "$0")/../../lib/fonts"
rm -f "$TARGET_DIR/MoonIcons.json"
rm -f "$TARGET_DIR/MoonIcons.ttf"

# Create icon font
npx fantasticon

# Cleanup by removing svgs folder
#rm -rf svgs