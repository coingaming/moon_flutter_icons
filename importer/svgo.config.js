module.exports = {
  multipass: true,
  floatPrecision: 5,
  plugins: [
    {
      name: "preset-default",
      params: {
        overrides: {
          removeViewBox: false,
          mergePaths: false,
        },
      },
    },
  ],
};
