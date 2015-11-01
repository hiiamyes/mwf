module.exports = {
    entry: './app/view/entry-frontend.cjsx',
    output: {
        filename: './app/view/bundle-frontend.js'
    },
    module: {
        loaders: [
            {
                test: /\.cjsx$/,
                loader: 'coffee-jsx-loader'
            },
            {
                test: /\.sass$/,
                loader: 'style!css!sass?indentedSyntax'
            }
        ]
    },
    externals: {
        'react': 'React'
    },
    resolve: {
        extensions: ['', '.js', '.cjsx', '.sass']
    }
}