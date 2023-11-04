// Generate Dart source from CSS

const fs = require("fs");

const kRegexCSS = /\.MoonIcons\-(.*):before.*"\\(.*)\";/g;

const args = process.argv.slice(2);
if (args.length < 2) {
  console.log(
    "Usage: ./node css_to_dart.js <input-icons-tsv> <output-icon-data-dart>"
  );
  process.exit(1);
}

const mappingFile = args[0];
const outputDarFile = args[1];

const stream = fs.createWriteStream(outputDarFile);

// Data
stream.write("import 'package:flutter/widgets.dart';\n\n");

stream.write("/// A convenience class.\n");
stream.write("class MoonIconsData extends IconData {\n");
stream.write("  const MoonIconsData(int code)\n");
stream.write("      : super(\n");
stream.write("          code,\n");
stream.write("          fontFamily: 'MoonIcons',\n");
stream.write("          fontPackage: 'moon_icons',\n");
stream.write("        );\n");
stream.write("}\n\n");

stream.write("/// Use with the Icon class to show specific icons.\n");
stream.write("class MoonIcons {\n");

/// Parse
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

  stream.write(`  /// ${name}\n`); // origin name
  mapping[name] = `0x${code}`;

  name = name.toLowerCase().replaceAll("-", "_");

  stream.write(`  static const ${name} = MoonIconsData(0x${code});\n\n`);

  counter++;
}

stream.write("}\n");

// Mapping
stream.write("\n");
stream.write("const moonIconsMap = ");
stream.write(JSON.stringify(mapping, null, 2));
stream.write(";\n");

stream.end();

console.log("Write source to:", outputDarFile);
console.log("Total:", counter);
