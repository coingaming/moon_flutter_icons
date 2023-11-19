// Generate Dart source from CSS

const fs = require("fs");

const kRegexCSS = /\.MoonIcons\-(.*):before.*"\\(.*)\";/g;

const args = process.argv.slice(2);
if (args.length < 3) {
  console.log(
    "Usage: ./node css_to_dart.js <input-icons-tsv> <output-icon-data-dart> <output-map-data-dart>"
  );
  process.exit(1);
}

const mappingFile = args[0];
const outputIconsFile = args[1];
const outputMapFile = args[2];

const iconsStream = fs.createWriteStream(outputIconsFile);
const mapStream = fs.createWriteStream(outputMapFile);

// Icons file header
iconsStream.write("import 'package:flutter/widgets.dart';\n\n");

iconsStream.write("// Generated code: do not hand-edit.\n");
iconsStream.write("@staticIconProvider\n");
iconsStream.write("abstract final class MoonIcons {\n");

iconsStream.write("  static const _kFontFam = 'MoonIcons';\n");
iconsStream.write("  static const _kFontPkg = 'moon_icons';\n\n");

// Map file header
mapStream.write("import 'package:flutter/widgets.dart';\n");
mapStream.write("import './icons.dart';\n\n");

mapStream.write("// Generated code: do not hand-edit.\n\n");

mapStream.write(
  "/// Convenience Map to facilitate the demonstration of icons.\n"
);
mapStream.write("final iconsMap = <String, IconData>{\n");

// Parse
console.log("Parsing:", mappingFile);
const data = fs.readFileSync(mappingFile, { encoding: "utf8" });
const mapping = {};
let counter = 0;
const matches = data.matchAll(kRegexCSS);

for (const match of matches) {
  if (match.length !== 3) {
    throw new Error("Invalid match");
  }
  let name = match[1];
  const code = match[2];

  iconsStream.write(`  /// ${name}\n`); // origin name
  mapping[name] = `0x${code}`;

  name = name.toLowerCase().replaceAll("-", "_");

  iconsStream.write(
    `  static const IconData ${name} = IconData(0x${code}, fontFamily: _kFontFam, fontPackage: _kFontPkg);\n\n`
  );

  mapStream.write(`  "${name}": MoonIcons.${name},\n`);

  counter++;
}

// Icons file footer
iconsStream.write("}\n\n");
iconsStream.end();

// Map file footer
mapStream.write("};\n\n");
mapStream.end();

console.log("Write source to:", outputIconsFile);
console.log("Total:", counter);
