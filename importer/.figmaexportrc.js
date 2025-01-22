// @ts-check

import asSvg from "@figma-export/output-components-as-svg";

/** @type { import('@figma-export/types').ComponentsCommandOptions } */
const componentOptions = {
  fileId: "RDNl9dNTMw2y0LO7K3veak",
  onlyFromPages: ["Icons outlined"],
  outputters: [
    asSvg({
      output: "./svgs",
      getDirname: () => "",
    }),
  ],
};

/** @type { import('@figma-export/types').FigmaExportRC } */
export default {
  commands: [["components", componentOptions]],
};
