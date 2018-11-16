# html从获取到展现

浏览器获取 html/js/css 文件后, 主要执行流程如下

解析过程
1. 构建 DOM 树: 浏览器加载 HTML文件 后, 开始构建 DOM树
2. 构建 CSSOM 树: 浏览器加载 CSS文件 后, 开始解析和构建 CSS RULE 树
3. 浏览器加载 JS文件 后, 通过 DOM API 和 CSSOM API 操作 DOM树 和 CSS RULE 树.

渲染过程
1. 构建 Rendering Tree: 浏览器引擎通过 DOM Tree 和 CSS Rule Tree 构建 Rendering Tree
    - Rendering Tree 并不与 DOM Tree 对应: 比如像 `<head>` 标签内容或带有 `display: none;` 的元素节点并不包括在 Rendering Tree 中
2. Layout/Flow 根据 Render Tree 计算每个节点的信息: 通过 Rendering Tree 定位坐标, 渲染 换行,position,overflow,z-index 等属性
3. Painting 根据计算好的信息绘制整个页面: 通过调用Native GUI 的 API 绘制网页画面

其他流程
1. 当元素发生变化时
    - Repaint: 如果元素在页面中的位置没有变化, 那么浏览器仅会应用新的样式重绘此元素
    - Reflow: 如果元素的变化影响了 文档内容/结构或元素位置, 那么浏览器重新布局节点. 可能影响到父节点, 同级节点以及子节点.
        - 增删改dom节点
        - 增删改class属性
        - 尺寸改变
        - 文本内容改变
        - 浏览器窗口改变大小或拖动
        - 动画效果进行计算和改变 CSS 属性值
        - 伪类激活（:hover）
    - 浏览器可能不会立即响应 Repaint/Reflow

## js是单线程的
JavaScript在浏览器是单线程执行的. 原因猜测如下
1. js 多线程收益不大
    - 首先, 如果js支持多线程, 首先要解决锁的问题: 即假设 t1 t2 两个线程, 需求是 t1 首先更改DOM节点 node1, 然后 t2 再更改 node1. 多线程时, 如何保证t1/t2对node1更改的顺序.
    - 其次, 浏览器本身并不执行大计算量任务, 多数为单线程绘制dom, 请求等(js本身性能也不高)
    - 目前采用 js进程+多个辅助线程 的模式已经满足使用需求了
        - js进程+辅助线程: JS引擎线程 + 事件触发线程 + 定时触发器线程 + WebWorker 等
2. 对于浏览器而言, 每个tab页已经是一个进程, 而且解析/渲染过程很短(不像后端程序需要长时间提供服务).
3. 历史原因

其实呢, 感觉并不是说 js 不适合多线程, 而是因为 1:目前这么做能满足需求, 2:js使用太普遍了,新标准涉及到的历史包袱太多. 所以目前js还是单线程的.

## 参考文章
- [浏览器渲染页面过程与页面优化](https://segmentfault.com/a/1190000010298038)
- [从浏览器多进程到JS单线程，JS运行机制最全面的一次梳理](https://segmentfault.com/a/1190000012925872)
- [浏览器的工作原理：新式网络浏览器幕后揭秘](https://www.html5rocks.com/zh/tutorials/internals/howbrowserswork/)

计算机网络: HTTP请求的过程
1. [一次完整的HTTP事务是怎样一个过程？](https://www.linux178.com/web/httprequest.html)
2. [TCP/IP三次握手和HTTP过程](https://www.cnblogs.com/tiwlin/archive/2011/12/25/2301305.html)
3. [websocket-http协议的补充](https://www.zhihu.com/question/20215561)

前端基础: 浏览器的渲染过程
1. [浏览器的渲染：过程与原理](https://juejin.im/entry/59e1d31f51882578c3411c77)
2. [JS运行机制](http://www.ruanyifeng.com/blog/2014/10/event-loop.html)