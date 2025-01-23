// Generate Dart source from CSS

import fs from "fs";

// Regular expression to parse CSS classes
const kRegexCSS = /\.MoonIcons\-(.*):before.*"\\(.*)\";/g;

// Extract command-line arguments
const [mappingFile, outputIconsFile, outputMapFile] = process.argv.slice(2);

if (!mappingFile || !outputIconsFile || !outputMapFile) {
  console.log(
    "Usage: node css_to_dart.js <input-icons-tsv> <output-icon-data-dart> <output-map-data-dart>"
  );
  process.exit(1);
}

// Create write streams for the output files
const iconsStream = fs.createWriteStream(outputIconsFile);
const mapStream = fs.createWriteStream(outputMapFile);

// Icons file header
iconsStream.write(`import 'package:flutter/widgets.dart';\n\n`);
iconsStream.write(`// Generated code: do not hand-edit.\n`);
iconsStream.write(`@staticIconProvider\n`);
iconsStream.write(`abstract final class MoonIcons {\n`);
iconsStream.write(`  static const _kFontFam = 'MoonIcons';\n`);
iconsStream.write(`  static const _kFontPkg = 'moon_icons';\n\n`);

// Map file header
mapStream.write(`import 'package:flutter/widgets.dart';\n`);
mapStream.write(`import './icons.dart';\n\n`);
mapStream.write(`// Generated code: do not hand-edit.\n\n`);
mapStream.write(
  `/// Convenience Map to facilitate the demonstration of icons.\n`
);
mapStream.write(`final iconsMap = <String, IconData>{\n`);

// Parse input file
console.log(`Parsing: ${mappingFile}`);
const data = fs.readFileSync(mappingFile, { encoding: "utf8" });
const mapping = {};
let counter = 0;

// Match all CSS entries
const matches = data.matchAll(kRegexCSS);

for (const match of matches) {
  if (match.length !== 3) {
    throw new Error("Invalid match");
  }

  const [_, rawName, code] = match; // Destructure match array
  const originalName = rawName; // Keep the original name for comments
  const lowerCaseName = rawName.toLowerCase().replace(/-/g, "_");

  // Write to icons file
  iconsStream.write(`  /// ${originalName}\n`);
  iconsStream.write(
    `  static const IconData ${lowerCaseName} = IconData(0x${code}, fontFamily: _kFontFam, fontPackage: _kFontPkg);\n\n`
  );

  // Add entry to mapping and map file
  mapping[originalName] = `0x${code}`;
  mapStream.write(`  "${lowerCaseName}": MoonIcons.${lowerCaseName},\n`);

  counter++;
}

// Icons file footer
iconsStream.write("}\n\n");
iconsStream.end();

// Map file footer
mapStream.write("};\n\n");
mapStream.end();

console.log(`Write source to: ${outputIconsFile}`);
console.log(`Total: ${counter}`);
