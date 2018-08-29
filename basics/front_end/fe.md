# FrontEnd

## TODO
1. `require()`: 
    - http://www.ruanyifeng.com/blog/2015/05/require.html

## 浏览器
### HTML渲染流程
浏览器进程按顺序, 单线程解析HTML, 所以JS执行/下载越耗时间, GUI渲染等待越久. 解决办法：
- `<script defer>` : defer属性：解析到此标签时立即下载, 延迟执行
- 打包下载：每次下载都有HTTP请求开销. （可使用打包工具或者网上打包处理器如yahoo的）
- 动态加载脚本技术：提示：script标签有一个load事件/readystart属性, 可用来检测是否下载完成
    - 动态创建`<script>`标签加载JS
    - AJAX动态加载JS
    - 开源库：Lazyload,  LABjs等等

## HTTP协议
基础: 
1. 一般情况下, query 是指 `url?query`拼接的内容. data/form 是 请求体(body) 里的内容
2. 一般由浏览器发送请求, 浏览器解释 HTML/JS/CSS, 服务端只负责响应请求.(部分爬虫可能需要)

### Request/Response
#### Content-Type
Content-Type: Content-Type 属性指定请求和响应的HTTP内容类型, 服务端根据不同的类型使用不同的方式在不同的位置(data/query)取数据,常见类型如下
- text/html
- text/plain
- text/css
- text/javascript
- application/x-www-form-urlencoded
- multipart/form-data
- application/json
- application/xml
- ...

application/x-www-form-urlencoded
- 表单提交类型, 后台可以从 from 中提取内容. 
- 后台获取的 raw body 是 `name=homeway&key=nokey`

multipart/form-data
- 当文件太长, HTTP 无法在一个包之内发送完毕, 就需要分割数据, 分割成一个一个 chunk 发送给服务端, 这时就是 multipart/form-data 的类型

## 框架/组件
### npm
> [npm简明教程](https://www.jianshu.com/p/e958a74a0fd7)

1. JS 的包管理器
2. `npm install <module>`: 默认安装到 `#{npm_home}/node_modules`
    - `-g`: 将安装包放置在如下位置 `/usr/local`
3. `npm ls [-g]`: 以目录树的形式查看安装包
4. `npm search <module>`: 搜索模块