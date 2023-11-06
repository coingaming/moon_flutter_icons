#!/bin/bash

# When using local environment get the PAT variable from .env file. The GitHub Action 
# will use the one from the workflow environment by default.
export $(egrep -v '^#' .env | xargs)

# Fetch icons from moon-icons-base repository
git clone --depth 1 https://$PAT@github.com/coingaming/moon-icons-base.git temp_repo
mkdir -p svgs
cp -r temp_repo/icons/* ./svgs/
rm -rf temp_repo

# Rename icons to the format appropriate for Flutter.
for file in svgs/*.svg; do
    base=$(basename "$file" .svg)

    new_name=$(echo "$base" | 
        awk -F, '{print $1}' | 
        awk '{$1=$1;print}' |       # This removes leading and trailing spaces
        tr -d ' ' |                 # This removes spaces within the name
        tr '[:upper:]' '[:lower:]' |
        tr '=-' '__')_32.svg
    
    mv "$file" "svgs/$new_name"
done

# Create _16 and _24 suffix copies for each icon.
for file in svgs/*_32.svg; do
    base=$(basename "$file" .svg)
    for suffix in 16 24; do
        cp "$file" "svgs/${base/_32/_${suffix}}.svg"
    done
done

# Optimise the SVGs.
npx svgo -f svgs -r -o svgs

# Modify SVG width and height to 1000px.
for file in svgs/*.svg; do
    sed -i.bak -e 's/width="[^"]*"/width="1000px"/g' -e 's/height="[^"]*"/height="1000px"/g' "$file" && rm "$file.bak"
done

# Add relevant stroke-width to every path.
modify_svg_properties() {
    local file=$1
    local stroke_width=$2

    awk -v sw="$stroke_width" '{ gsub(/<path/, "<path stroke-width=\"" sw "\""); print }' "$file" > "$file.tmp" && mv "$file.tmp" "$file"   
}

for file in svgs/*_32.svg; do
    modify_svg_properties "$file" "1.5px"
done

for file in svgs/*_24.svg; do
    modify_svg_properties "$file" "2.25px"
done

for file in svgs/*_16.svg; do
    modify_svg_properties "$file" "3px"
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