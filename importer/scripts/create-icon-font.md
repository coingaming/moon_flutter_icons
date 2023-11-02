# Fetch Icons

> **Note**: The codeblock in this document is executed by `npm run fetch-icons`.

## Fetch icons from Figma

We use the [figma-export cli](https://github.com/marcomontalbano/figma-export) to download
SVG files directly from Figma. The configuration for this process is located in
`.figmaexportrc.js`.

For this process to work a PAT env variable value must be fetched from GitHub secrets or 
for local development set in the .env file.

Fetch icons from moon-icons-base repository

```sh
# Set PAT for local environment
export $(egrep -v '^#' .env | xargs)

# Clone the moon-icons-base repository to get the unmodified icon SVGs
git clone --depth 1 https://$PAT@github.com/coingaming/moon-icons-base.git temp_repo
mkdir -p svgs
cp -r temp_repo/icons/* ./svgs/
rm -rf temp_repo

ls -la ./svgs/

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

# Modify properties of SVGs
for file in svgs/*.svg; do
    sed -i 's|/>| stroke-width="1.5px" vector-effect="non-scaling-stroke"/>|' "$file"
              
    size=$(echo "$file" | grep -o '_[0-9]*\.svg' | sed 's/[^0-9]*//g')
    
    sed -i "s/width=\"[0-9]*\"/width=\"${size}\"/g" "$file"
    sed -i "s/height=\"[0-9]*\"/height=\"${size}\"/g" "$file"
done

# Convert strokes to fills
npx oslllo-svg-fixer -s svgs -d svgs

# Optimise SVGs
npx svgo -f svgs -r -o svgs

# Create icon font
npx fantasticon

# Cleanup by removing svgs folder
rm -rf svgs
```
