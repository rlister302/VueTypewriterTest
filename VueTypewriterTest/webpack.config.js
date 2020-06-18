const path = require('path');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');

// Need to have an alias for vue or else we get a runtime error since
// the module that is bundled does not have the compiler
module.exports = {
    mode: "development",
    entry: {
        main: './Views/Home/main.ts'
    },
    resolve: {
        extensions: ['.js', '.ts'],
        alias: {
            vue$: "vue/dist/vue.esm" 
        }
    },
    output: {
        filename: '[name].bundle.js',
        path: path.resolve(__dirname, 'wwwroot/dist'),
        library: '[name]',
        libraryTarget: 'var',
    },
    //externals: {
    //},
    module: {
        rules: [
            { test: /\.ts$/, use: 'awesome-typescript-loader?silent=false' },
        ]
    },
    plugins: [
        new CleanWebpackPlugin()
        // new BundleAnalyzerPlugin()
    ]
}