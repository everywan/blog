## css单位
- [参考: Font-size:一个意外复杂的CSS属性](https://juejin.im/post/5b1292355188251377116617)
### em/rem
- 1em: 元素的 font-size 的 1 倍
- 1rem: 根元素的 font-size 的 1 倍

所以, 当更改font-size时, 本元素计算的高度就会有问题. 示例如下
```html
html>
<style>
    .par {
        width: 20%;
        height: 1.5em;
        background-color: antiquewhite;
    }
    .child {
        height: 1.5em;
        font-size: 0.8em;
    }
</style>
<div class="par">
    <div class="child">asas</div>
</div>
</html>
```
