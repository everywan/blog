## 从零开始构建前端项目

<!-- TOC -->

- [从零开始构建前端项目](#从零开始构建前端项目)
    - [创建前端项目](#创建前端项目)
    - [使用NPM管理项目依赖](#使用npm管理项目依赖)
    - [引入webpack](#引入webpack)
    - [添加webpack-dev-server(可选)](#添加webpack-dev-server可选)
    - [安装vue.js](#安装vuejs)
    - [添加vue-loader](#添加vue-loader)
    - [配置热重载](#配置热重载)
    - [多环境配置](#多环境配置)
    - [分离代码](#分离代码)
    - [webpack优化](#webpack优化)

<!-- /TOC -->

参考文章
- [Vue.js/Webpack 的基本配置](https://moxo.io/blog/2016/09/10/npm-vue-webpack/)
- [webpack 4 ：从0配置到项目搭建](https://juejin.im/post/5b3daf2ee51d451962727fbe)

要深入的学习前端, 就有必要摆脱手写 html/js/css, 尝试使用框架/前端工程解决问题.

虽然网上有好多文章已经写的很好了, 但是我觉得还是有必要自己写一边: 每个人理解的方式都是不同的, 只有自己实践一遍才能更好的掌握.

接下来, 首先创建一个简单的前端项目, 然后一步步使用现有的, 常用的前端工具去完善这个项目. 虽然前端技术/工具日新月异, 但是这一套思路应该变化不大.

对于整套代码, [源码在这里](https://github.com/everywan/example-front-end)

### 创建前端项目
最简单的前端项目只需要 一个工作目录+index.html 文件即可.
- [创建项目并且使用npm初始化: commitURL](https://github.com/everywan/example-front-end/commit/8acbe938d544e867fd6085ba719960088c6cb76d)

1. `mkdir demo && cd demo && touch index.html`

对于单页应用, 目录结构如下
````
- demo
    - index.html
    - src
        - assets        // 引用的资源
            - js
            - css
        - main.js       // 自己的业务代码
````

知识点
1. SPA单页应用: 单页应用与传统的多页面应用是相对的. 
    - 单页应用跳转仅需刷新局部资源, 多页应用跳转需要刷新整个页面.
    - 单应用开发一般比较复杂(处理路由等), 且单应用SEO不够友好.
    - 参考: [你要懂的单页面应用和多页面应用](https://juejin.im/post/5a0ea4ec6fb9a0450407725c)

### 使用NPM管理项目依赖
当项目复杂时, 引入/管理 第三方模块 从而避免重复造轮子是很常见且必要的需求.

1. 使用npm初始化项目: `npm init`, 配置意义如其字面.

npm 使用 package.json 管理项目信息. `npm init` 用于在当前目录创建 `package.json`, 并提示项目需要输入的相关信息, 如作者,协议等, 并且管理后续 `npm install` 的依赖信息. 后续也可以根据 package.json 回复所有依赖. 部分节点意义如下.

scripts: npm脚本, 执行 `npm run script-name` 会自动新建一个shell并且执行指定的脚本.
- 参考: [npm script使用指南](http://www.ruanyifeng.com/blog/2016/10/npm_scripts.html)
- 建议将下文中常用的命令都放到scripts节点下.
```js
// script 常用命令
script: {
    // 使用 webpack 打包, 制定环境, 配置文件路径
    "build:prod": "export NODE_ENV=production && npx webpack --config build/webpack.base.config.js",
    // 使用 webpack-dev-server 运行
    "dev": "npx webpack-dev-server --hot-only --config build/webpack.base.config.js"
}
```

1. npm: npm是node.js默认的软件包管理工具.
    - 有兴趣深入了解的可以查阅
        - [Node.js](https://zh.wikipedia.org/zh-hans/Node.js)
        - [npm中文文档](https://www.npmjs.com.cn/)
2. `npm install`命令简介
    - `npm install -g `: 安装到全局, 不加 -g 表示安装到本地
    - `npm install --save-dev`: 将依赖写入 package.json 中, `-dev` 表示这不是一个项目依赖, 而是一个在开发中需要的依赖.
3. npx: npx 是Node9.2/npm5.2以上提供的命令, 用于运行 本项目作用域内的 webpack 二进制文件(`./node_modules/.bin/webpack`)

### 引入webpack
开发时, 项目测试/上线时, 可能存在以下问题
- 有很多空格, 有很多命名很长的字符串, 以致项目体积增大
- 使用了 ES5/ES6 等语法, 部分浏览器不能直接识别
- 需要代码混淆等功能

这一切, webpack 都可以帮你实现. webpack 是前端项目的构建工具, 负责将源代码生成目标代码. webpack含有一系列组件, 帮我们更自由更方便的处理源代码, 构建目标代码.
- [引入webpack: commitID](https://github.com/everywan/example-front-end/commit/f275d8ead7c37271214ae0c9ff411dfde78de34a)

为项目引入webpack
1. 安装webpack: `npm install webpack webpack-cli --save-dev`
2. 添加webpack配置文件
    - 添加 `build/` 目录, 用于存放webpack配置文件
    - 创建 `build/webpack.base.config.js`, 作为基础配置文件(后续可能有 `build/webpack.dev.config.js` 测试环境的配置文件)
    - 配置webpack: 如下
    ```JS
    // build/webpack.base.config.js
    // mode 模式 用于多环境配置, 后续介绍
    // path.resolve() 用于连接两个目录
    let path = require('path');

    module.exports = {
        mode: 'development',                                // 模式, 可以区分不同环境
        entry: path.resolve(__dirname, '../src/main.js'),   // 入口文件
        output: {                                           // 构建暑促配置
            path: path.resolve(__dirname, '../dist'),       // 最终文件生成目录
            filename: './static/js/app.js'                  // 最终构建的js代码名称
        }
    };
    ```
3. index.html 删除其他引用, 只添加 最终构建的 js代码 的引用
4. webpack 执行命令: `npx webpack --config build/webpack.base.config.js --watch`
    - npx: 见上文
    - `--watch`: 表示webpack会监视源代码文件的变化, 有变化则重新打包(注意变化不包括webpack配置文件)
10. 注意事项
    - webpack配置中, `__dirname` 是配置文件所在目录, 不是执行命令时所在的目录
    - 注意在 index.html 中依赖的引入顺序, 如果js中使用了html中的dom节点, 那么保证引入顺序在该节点之后.

### 添加webpack-dev-server(可选)
webpack-dev-server 是一个简易的Web服务器. 基于 node.js 开发, 是webpack推荐的测试工具.
- [添加webpack-dev-server: commitID](https://github.com/everywan/example-front-end/commit/e861a52b9929c418821cb31d05456a420b975597)

建议使用 webpack-dev-server
1. 可以配合 vue-laoder 实现[热重载](https://vue-loader-v14.vuejs.org/zh-cn/features/hot-reload.html).
    - 热重载: 热重载不是指简单的刷新页面, 而是当你修改 .vue/js 文件时, 在不刷新页面的前提下, 替换所有该组件的实例, 并且保持组件被替换前的状态(如赋值后的变量)
2. 提供定制功能, 可以使用中间件.
3. 其他更多功能参考: [devServer](https://webpack.docschina.org/configuration/dev-server/)

为项目添加 webpack-dev-server 功能
1. 安装: `npm install webpack-dev-server --save-dev`
2. 修改 `webpack.base.config.js`, 添加 webpack-dev-server 支持
    ```js
    module.exports = {
        mode: 'development',
        ...
        devServer: {
            publicPath: '/dist/',
            contentBase: './',
            compress: true,
            port: 8080
        }
        ...
    };
    ```
3. dev-server运行命令: `npx webpack-dev-server --config build/webpack.base.config.js`

### 安装vue.js
vue.js 是目前常用的前端框架之一, 合适的框架可以极大的减轻我们开发的工作量.
- [Vue简单介绍](/front_end/vue/vue.md)
- [添加基础vue: commitID](https://github.com/everywan/example-front-end/commit/40dd09d603a53dcc74c9b7c53a738e8e9b4e562c)

1. 安装 Vue.j: `npm install vue --save`
2. 默认情况下项目使用的是 运行版本的 vue.js, 在不使用 vue-loader 时, 我们需要调整webpack, 告知webpack使用完整版本的vue.js
    ```js
    module.exports = {
        // ...
        resolve: {
            alias: {
            'vue$': 'vue/dist/vue.esm.js' // 用 webpack 1 时需用 'vue/dist/vue.common.js'
            }
        }
    }
    ```
3. 在 `./src/main.js` 中引入vue, 就可以创建Vue实例了.
    - vue需要有一个挂载点, 所以需要在 index.html 或 main.js 中先创建一个dom节点
    ```js
    import Vue from 'vue'
    new Vue({
        template:"<h1>Hello Vue</h1>"
    }).$mount('#app')
    ```
4. 执行 `npx webpack-dev-server --config build/webpack.base.config.js` 查看运行效果

vue.js 分为完整版和运行时版本, `完整版=编译器+运行时版本`. 编译器负责将模板(template)解析为js代码, 运行时负责创建Vue实例, 渲染并处理虚拟DOM. 运行时版本比完整版体积大约小30%, 所以一般推荐项目使用vue-loader.
- [官方链接: 对不同构建版本的解释](https://cn.vuejs.org/v2/guide/installation.html#对不同构建版本的解释)

当使用vue-loader时, 会在构建时将 `*.vue` 文件中的template预编译为js代码, 所以最终生成的包里不需要编译器, 只需要运行时版本.

### 添加vue-loader
vue-loader 如其字面意思, 是 webpack 的一个加载器(loader). vue-loader 提供了一系列功能可以帮我们方便的使用vue框架
- [添加vue-loader: commitID](https://github.com/everywan/example-front-end/commit/c5f6a0169c12053065eaf543a8f70c7f0b18f8ed)

[vue-loader 好处](https://vue-loader.vuejs.org/zh/)
1. 允许以单文件组件(SFCs)的形式开发vue组件. 简称 .vue 文件
2. 允许为Vue单文件组建的每个部分使用其他的webpack loader. 如 `style` 使用 Sass.
3. 允许在一个 .vue 文件中使用自定义块, 并对其运用自定义的loader链.
4. 为每个组件模拟 scoped css
5. 支持热重载
6. 参考官网[vue-loader](https://vue-loader.vuejs.org/zh/)

1. 安装 vue-loader 组件: `npm install vue-loader css-loader vue-template-compiler --save-dev`
    - vue-loader 本身依赖于 css-loader 和 vue-template-compiler
2. 修改webpack.config.js, 添加vue-loader. 
    - [手动配置vue-loader_官网教程](https://vue-loader.vuejs.org/zh/guide/#手动配置)
    ```js
    const VueLoaderPlugin = require('vue-loader/lib/plugin')
    module.exports = {
        ...
        // 因为使用vue-loader预编译, 所以无需使用完整版vue
        // resolve: {
        //    alias:{
        //         'vue$': 'vue/dist/vue.esm.js'
        //     }
        // }
        module: {
            rules: [
                {
                    test: /\.vue$/,
                    loader: 'vue-loader'
                }
            ]
        },
        plugins: [
            new VueLoaderPlugin()
        ]
    }
    ```
3. 添加App.vue, 使用单文件组件的方式重新组织 main.js. (App.vue 中内容见代码)
    ```js
    // main.js
    import App from './App.vue'
    new Vue({
        render: h => h(App)
    }).$mount('#app')
    ```

### 配置热重载
如前文介绍, 热重载可以在你修改 js 文件时, 在不刷新页面的前提下, 替换所有该组件的实例, 并且保持组件被替换前的状态(如赋值后的变量). 是开发时很有用的一个工具.
- [配置热重载: commitID](https://github.com/everywan/example-front-end/commit/f5deac8dc8015509529d988dd8504266a0d5d45b)

基于vue-loader, 配置基于 vue/js 文件的热重载
1. 添加 `HotModuleReplacementPlugin` 插件.
2. 在 output 中添加 publicPath, 且后缀与 devServer 中的 publicPath 相同. 示例: `publicPath: 'http://localhost:8080/dist/'`
3. devServer 启用热重载: 建议在 package.json/script 下的命令中添加 --hot-only 参数, 以便与不同环境下的不同配置(如prod环境不需要热重载时)
    - `npx webpack-dev-server --hot-only --config build/webpack.base.config.js`

```js
const webpack = require('webpack')
module.exports = {
    output: {
        ...
        publicPath: 'http://localhost:8080/dist/'
    },
    devServer: {                // devServer启用热重载
        ...
        publicPath: '/dist/',
        // hot: true,           // 推荐在 命令参数中添加
        // hotOnly: true
    },
    plugins: [
        new VueLoaderPlugin(),
        new webpack.NamedModulesPlugin(),           // 用于显示变化的名称, 可选
        new webpack.HotModuleReplacementPlugin()
    ]
}
```

- hot: Enables Hot Module Replacement
- hot-only: Do not refresh page if HMR fails

### 多环境配置
多环境配置主要实现以下功能
1. 通知webpack等组件: 通过使用webpack的mode切换模式, 通知webpack启用相应优化
2. 自定义逻辑: 可以根据不同的环境实现不同的逻辑. 常用逻辑如下
    - 使用 DefinePlugin 在构建时替换源码中的字符串. (见后文)

mode补充: 用于通知webpack使用相应模式的优化. 参考: [mode-webpack](https://www.webpackjs.com/concepts/mode/)
- development: 启用 NamedChunksPlugin 和 NamedModulesPlugin
- production: 启用 FlagDependencyUsagePlugin, FlagIncludedChunksPlugin, ModuleConcatenationPlugin, NoEmitOnErrorsPlugin, OccurrenceOrderPlugin, SideEffectsFlagPlugin 和 UglifyJsPlugin

1. 运行命令前导入 `NODE_ENV` 变量: package.json/script 如下修改: `export NODE_ENV=production && ...`
2. 修改 webpack.config.js 添加环境判断
    ```js
    module.exports = {
        mode: process.env.NODE_ENV === 'production' ? 'production' : 'development',
        ...
    }

    // 如果你想根据环境导入一些自定义组件
    if(process.env.NODE_ENV==='development'){
        module.exports.plugins.push(
            ...
        )
    }
    ```

DefinePlugin: 使用 DefinePlugin 插件可以在构建时使用配置项替换源码中的字符串. 假设我们需要在 dev 环境下调整 Host 为 `dev.bus.com`, prod 环境下 Host 为 `bus.com`, 那么可以如下配置
1. 创建 config 目录, 存放不同环境下的配置信息. (关于默认的conf, 命名为 base 还是 index 我不敢确定)
    ````
    - config
        - base.conf.js
        - dev.conf.js
        - prod.conf.js
    ````
2. `config/base.conf.js` 中根据环境加载不同的配置
    ```js
    var _env = "dev"
    if(process.env.NODE_ENV==='production'){
        _env = "prod"
    }
    
    const envConfigFile = "./" + _env + ".conf.js";
    process.stdout.write('INFO: the env config file is '+ envConfigFile +'\n');
    // 将require的配置文件原封不动export回出去
    module.exports = require(envConfigFile);
    ```
3. `webpack.base.config.js` 中引入 DefinePlugin 插件, 并且设置
    ```js
    ...
    const envConfig = require('../config/base.conf')
    module.exports = {
        ...
        plugins: [
            ...
            new webpack.DefinePlugin({
                // 源码中所有 process.env.XX 都会被替换为 '../config/dev.env' 这个 module export 出来的配置
                'process.env': envConfig
            })
        ]
    }
    ```

测试
1. 在 dev.conf.js/prod.conf.js 分别配置 HOST_URL
    ```js
    // dev.conf.js示例, prod 类似
    module.exports = {
        // 关于键值定义方法见 https://webpack.docschina.org/plugins/define-plugin/
        // 如果value是字符串, 那么该 value 会被当成代码段使用. '""' 即可将value作为字符串使用
        HOST_URL: '"dev.bus.com"'
    }
    ```
2. 在 Hello.vue 中添加 `console.log(process.env.HOST_URL)`
    ```js
    <script>
        export default {
            ...
            mounted: function(){
                console.log(process.env.HOST_URL)
            }
        }
    </script>
    ```
3. 修改 package.json, script节点下添加: `"prod": "export NODE_ENV=production && npx webpack-dev-server --hot-only --config build/webpack.base.config.js",`, 即设置环境为production, 并运行 devServer
4. 执行 `npm run prod`, 观察console打印出的值, 会发现随着环境变化.

### 分离代码

### webpack优化
参考官网
1. webpack同时构建HTML文件
    - [HtmlWebpackPlugin](https://webpack.docschina.org/plugins/html-webpack-plugin/)
2. 每次构建时清除原有代码
    - [clean-webpack-plugin](https://github.com/johnagan/clean-webpack-plugin)
3. css loader: 解析css
4. 单独打包css: extract-text-webpack-plugin
5. file loader: 压缩文件

