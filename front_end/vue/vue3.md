# vue3
vue cli3 多环境配置中, 根据测试, 在build时, vue 是根据配置文件中的 NODE_ENV 判断环境的, 如果 NODE_ENV!=production, 打包生成的文件结构是不同的(具体策略未知). 所以, 当你在测试环境测试时, 可以将 `.env.development` 中的 NODE_ENV 设置为 production, 这样子打包后的文件结构与线上是相同的.
    - 该问题的 issue 链接: https://github.com/vuejs/vue-cli/issues/2289

vue 环境变量 官方文档链接: https://cli.vuejs.org/zh/guide/mode-and-env.html#%E6%A8%A1%E5%BC%8F. 以下需要注意下
1. 环境配置前面有个点, 规则是 `.env.xxx`, 不要忘记点
2. 预定义的两个变量为 NODE_ENV, 表示打包时采用的环境(注意, 这个环境与命令行中 `--mode` 指定的环境不同, 已知的是打包生成的文件会根据这个环境生成不同的目录, 具体未知). 另一个是BASE_URL, 需要与 `vue.config.js` 中的 baseURl 保持一致.
3. 所有自定义的变量, 都需要加上 VUE_APP_XXX 前缀, 否则不被识别
4. vuex 中, action提交的 commit 是同步执行的, 也就是说, 只有commit执行完成后, action后续代码才会继续执行
