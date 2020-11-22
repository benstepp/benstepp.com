const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const CssMinimizerPlugin = require("css-minimizer-webpack-plugin");
const CopyPlugin = require("copy-webpack-plugin");

module.exports = {
  mode: "production",
  entry: {
    script: "./src/script.js",
    style: "./src/style.css",
  },
  output: "./dist",
  plugins: [
    new HtmlWebpackPlugin({
      template: "src/index.html",
      cache: false,
      templateParameters: (compilation, assets, assetTags, options) => {
        try {
          return {
            js: compilation.assets["script.js"].source(),
            css: compilation.assets["style.css"].source(),
          };
        } catch (e) {
          return { js: "", css: "" };
        }
      },
      alwaysWriteToDisk: true,
      inject: false,
    }),
    new MiniCssExtractPlugin({
      filename: "[name].css",
    }),
new CopyPlugin({
patterns: [
{ from: "src/favicon.ico", to: "favicon.ico" }
]
})
  ],
  module: {
    rules: [
      {
        test: /\.css$/i,
        use: [MiniCssExtractPlugin.loader, "css-loader"],
      },
      {
        test: /\.js$/i,
        use: ["source-map-loader"],
      },
    ],
  },
  optimization: {
    minimize: process.argv[process.argv.length - 1] !== 'serve',
    minimizer: [`...`, new CssMinimizerPlugin()],
  },
  devServer: {
    host: "0.0.0.0",
port: 8080,
contentBase: path.join(__dirname, 'src')
  },
  performance: {
    hints: false,
  },
};
