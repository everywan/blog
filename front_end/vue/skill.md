# Vue开发的一些知识

因为对Vue.js底层了解不够多, 所以某些地方暂时自己解释不了, 只能记录解决方案以供后续参考或者深入学习.

## Vue.nextTick()
- 参考: https://juejin.im/post/5a6fdb846fb9a01cc0268618

在 Vue.js 中, Vue.js 与 DOM 是异步刷新的. 所以, 在某些情况下存在更新组件数据后, DOM没有立即更新. 

`nextTick([callback, context])` 用于延迟执行回调函数, 即在下一次DOM更新结束后执行回调函数.

## slot
slot 使用:
```Vue
# 子组件
<template >
    <slot name="t-button"/>
</template>
# 父组件
<temple>
    <div>
      <template slot="t-button">
        <Button>Test2</Button>
      </template>
    </div>
</temple>
```
$parent : 来从一个子组件访问父组件的实例。它提供了一种机会，可以在后期随时触达父级组件，以替代将数据以 prop 的方式传入子组件的方式。

在绝大多数情况下，触达父级组件会使得你的应用更难调试和理解，尤其是当你变更了父级组件的数据的时候。当我们稍后回看那个组件的时候，很难找出那个变更是从哪里发起的。
https://cn.vuejs.org/v2/guide/components-edge-cases.html


scope-slot:
```Vue
# 子组建
<template>
    <slot name="test" :data=data />
</template>
<script>
...
# 子组建中定义 data值
</script>

# 父组建
<template>
    # 当不写slot时:  如果子组建中只有一个具名插槽, 那么具明插槽退化为到匿名插槽
    <template slot="test" slot-scope="sc">
        # 父组件中使用的sc, 就是子组建的值
        {{sc}}
    </template>
</template>
```
