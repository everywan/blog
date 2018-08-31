## webpack
- [官方文档](https://www.webpackjs.com/concepts/)
- [入门Webpack，看这篇就够了](https://www.jianshu.com/p/42e11515c10f#)

webpack介绍-官方文档: 
> 本质上, webpack 是一个现代 JavaScript 应用程序的静态模块打包器(module bundler). 当 webpack 处理应用程序时, 它会递归地构建一个依赖关系图(dependency graph), 其中包含应用程序需要的每个模块, 然后将所有这些模块打包成一个或多个 bundle.

webpack是前端项目的构建框架之一, webpack可以 分析项目结构, 找到JavaScript模块以及其它的一些浏览器不能直接运行的拓展语言(Scss，TypeScript等), 并将其转换和打包为合适的格式供浏览器使用.
- 构建规则包括: 如何处理包依赖, 如何打包模块, 如何输出.
- 如果在项目构建方面有要求或者有问题的话, 可以在webpack里寻找方案.

使用
- 任何在 static/ 中的内容会被直接复制到 dist/static 下, 而不经过webpack处理(如图示)

### 目录结构
目录结构参考 vue 项目的结构
- [vue-webpack项目结构](/basics/front_end/vue/vue.md#目录结构)
- [参考: vue-cli-项目结构](https://loulanyijian.github.io/vue-cli-doc-Chinese/structure.html)

### 生成文件详解
- [参考: mainfest](https://webpack.docschina.org/concepts/manifest/#src/components/Sidebar/Sidebar.jsx)

在使用 webpack 构建的典型应用程序或站点中, 有三种主要的代码类型:
1. 业务代码: 你和你的团队写的代码
2. 第三方代码: 你的源码依赖的任何第三方的 lib 或 vendor 代码.
3. webpack 的 runtime 和 mainfest, 管理所有模块的交互.
	- runtime: 在浏览器运行时, webpack 用来连接模块化的应用程序的所有代码.
	    - runtime包括: 在模块交互时, 连接模块所需的加载和解析逻辑; 包括浏览器中的已加载模块的连接, 以及懒加载模块的执行逻辑.
    - mainfest: 管理所有模块之间的交互.
        - 当编译器(compiler)开始执行,解析和映射应用程序时, 它会保留所有模块的详细要点. 这个数据集合称为 "Manifest", 当完成打包并发送到浏览器时, 会在运行时通过 Manifest 来解析和加载模块
        - 无论你选择哪种模块语法, 那些 import 或 require 语句现在都已经转换为 `__webpack_require__` 方法, 此方法指向模块标识符(module identifier). 通过使用 manifest 中的数据, runtime 将能够查询模块标识符, 检索出背后对应的模块

根据这三种代码, webpack最终构建的js文件有以下三类
1. `app.**hash**.js`: 业务代码
2. `vendor.**hash**.js`: 第三方库的代码
3. `mainfest.**hash**.js`: runtime/mainfest相关代码
