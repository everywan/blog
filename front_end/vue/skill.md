# Vue开发的一些知识

因为对Vue.js底层了解不够多, 所以某些地方暂时自己解释不了, 只能记录解决方案以供后续参考或者深入学习.

## Vue.nextTick()
- 参考: https://juejin.im/post/5a6fdb846fb9a01cc0268618

在 Vue.js 中, Vue.js 与 DOM 是异步刷新的. 所以, 在某些情况下存在更新组件数据后, DOM没有立即更新. 

`nextTick([callback, context])` 用于延迟执行回调函数, 即在下一次DOM更新结束后执行回调函数.
