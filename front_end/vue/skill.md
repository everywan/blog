# Vue开发的一些知识

因为对Vue.js底层了解不够多, 所以某些地方暂时自己解释不了, 只能记录解决方案以供后续参考或者深入学习.

## v-if/show
v-if有更高的切换消耗, v-show有更高的初始渲染消耗
- v-show 始终会被渲染并保留在 DOM 中. v-show 只是简单地切换元素的 CSS 属性 display.
- v-if 是"真正"的条件渲染, 因为它会确保在切换过程中条件块内的事件监听器和子组件适当地被销毁和重建.
v-if 也是惰性的: 如果在初始渲染时条件为假, 则什么也不做——直到条件第一次变为真时, 才会开始渲染条件块.
相比之下, v-show 就简单得多——不管初始条件是什么, 元素总是会被渲染, 并且只是简单地基于 CSS 进行切换

参考 [条件渲染](https://cn.vuejs.org/v2/guide/conditional.html)

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
