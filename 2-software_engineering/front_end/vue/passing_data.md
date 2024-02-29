## 子父组件通信
### 父组件向子组件传值
父组件向子组件传值: 使用 props 即可
```JavaScript
// 子组件: Child
<template>
    <div>{{msg}}</div>
</template>
<script>
export default {
    props: ['msg'],
    data:function(){
        return{}
    }
}
</script>
// 父组件
<template>
    <Child :msg="msg"></Child>
</template>
<script>
import Child from "./Child";
export default {
    data:function(){
        return {
            msg: "hello"
        }
    }
}
</script>
```

### 子组件向父组件传递消息
子组件向父组件传递消息: 使用 emit 事件监听
- 子组件不建议通过修改 props 来修改父组件中的值: 防止子组件更改父组件的状态, 避免应用中数据流向难以理解
- 可以理解为一种规范: 父组件的修改必须由父组件控制, 必须放到父组件去做, 这也是为什么通过子组件使用 emit 通知父组件, 在父组件中修改状态的原因.

流程如下:
- 在子组件中执行 emit(): emit() 第一个参数是父组件绑定到子组件的自定义事件, 第二个参数是事件的值
    - `this.$emit("ParReceiveMsg","msg from child")`: ParReceiveMsg就是父组件绑定到子组件的自定义事件
- 父组件中定义事件处理函数
    - `<Child v-on:ParReceiveMsg="childMsgChanges"></Child>`: 如何绑定事件到子组件

```JavaScript
// 子组件
<template>
    <div v-on:click="sentMsgToPar">向父组件传值</div>
</template>
<script>
export default {
    data:function(){
        return{}
    },
    methods: {
        sentMsgToPar: function(){
            this.$emit("ParReceiveMsg","msg from child")
        }
    }
}
</script>
// 父组件
<template>
    <Child v-on:ParReceiveMsg="childMsgChanges"></Child>
</template>
<script>
import Child from "./Child";
export default {
    data:function(){
        return {}
    },
    methods:{
        childMsgChanges: function(data){
            console.log(data)
        }
    }
}
```
