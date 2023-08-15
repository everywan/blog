# 常见的目录结构

## webpack+vue
````
-project
    - build                 // webpack 构建项目配置文件路径
    - config                // 存储自定义配置文件, 共webpack构建时使用
        - base.config.js
        - dev.config.js
        - prod.config.js
    - dist                  // webpack 构建之后, 目标路径
    - node_modules          // npm依赖项目, 自动生成
    - static                // 存储不变的css/js
    - src                   // 项目源代码
        - assets            // 存储其他 js/css/img 等
        - components        // 组件库
        - main.js           // 项目入口
        - App.vue           // vue.js 入口
        - store.js
        - route.js           // 其他组件目录/文件(如 vue-router)
        - ...
    - index.html
    - package.json
````

## webpack+reacet
与vue不同的是, reacet需要将css独立出来(vue为单文件组件, 组件中有单独的css节点, 不需要独立出来)
- 参考: https://www.zhihu.com/question/50750032
````
-project
    - build                 // webpack 构建项目配置文件路径
    - config                // 存储自定义配置文件, 共webpack构建时使用
        - base.config.js
        - dev.config.js
        - prod.config.js
    - dist                  // webpack 构建之后, 目标路径
    - node_modules          // npm依赖项目, 自动生成
    - static                // 存储不变的css/js
    - src                   // 项目源代码
        - assets            // 存储其他 js/css/img 等
        - main.js           // 项目入口
        - components
            - componentsA
                - A.jsx
                - A.css
        - pages             // 多路由页面(非SPA应用)
        - App.vue           // vue.js 入口
        - reducers          // 系统其他组件目录, 如redux
    - index.html
    - package.json
````
