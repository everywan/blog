## JavaScript
<!-- TOC -->

- [JavaScript](#javascript)
    - [基础](#基础)
        - [JS变量类型/默认值/值判断](#js变量类型默认值值判断)
    - [jquery](#jquery)
    - [HTTP库-Ajax](#http库-ajax)
        - [AJAX使用](#ajax使用)
        - [AJAX 读取本地文件](#ajax-读取本地文件)
    - [H5无刷新修改url:pushstate](#h5无刷新修改urlpushstate)
    - [定时器](#定时器)

<!-- /TOC -->
### 基础
1. 当变量没有被开辟空间/赋值时, `if(aa)` 的值是false. 没必要再使用 `typeof` 或者判空.
2. 三目运算符 `var a =bool?true:false;`
3. 深复制：`var vega_temp = JSON.parse( JSON.stringify(testVega) )`
4. `test()`: 检测一个字符串是否匹配某个模式. 格式: `RegExpObject.test(string)`
    - 举例: A: `alert(/www/.test("WWW"))` , B: `new RegExp("W3School").test("www")`
5. 变量内字符串使用 `\n` 换行
2. windows对象: 可以将局部函数的对象挂载到windows上以实现全局共享(当然也可以定义在一个js里然后引用)

#### JS变量类型/默认值/值判断
1. JS数据类型: string, 数字(int/float), bool, array, 对象, Null, undefined.
2. undefined/null区别
    - undefined: 表示变量没有声明.
    - null: 表示变量没有定义.
    - [参考: 声明/定义](/language/basic.md)
    - [参考: 探索JavaScript中Null和Undefined的深渊](http://yanhaijing.com/javascript/2014/01/05/exploring-the-abyss-of-null-and-undefined-in-javascript/)
3. 默认值
    - `new String;`: ""
    - `new Number;`: 0
    - `new Boolean;`: false
    - `new Array;`: []
    - `new Object;`: {}
4. if语句: 在if语句中, `undefined / null` 以及各类型默认值 都会转换为false.
5. `isNaN(x)` 用于检查x是否是数字. 如果是合法的数字则返回 false, 否则返回 true(如 `isNaN("aa")==true`).
5. `== / ===`: `==`会进行类型转换, `===`同时比较值和类型

### jquery
- [w3cshool](http://www.w3school.com.cn/jquery/jquery_syntax.asp)
- 建议使用框架, 如vue

1. $(selector).ready(function(){})：$定义JQuery, (selector)CSS选择器, action操作
2. 若命名冲突, 可用jQuery.noConfict()初始化新变量代替 "$"
3. CSS选择器：使用css对HTML页面中的元素实现一对一, 一对多或者多对一的控制
4. 一些默认方法：$(selector).hide/slider(滑动)/animate(动画)/fade(淡入淡出)/MouseOver/Attr(属性)

### HTTP库-Ajax
- [w3cshool](http://www.w3school.com.cn/ajax/index.asp)
- 建议使用 axios 等进一步封装的HTTP库

1. 异常状态:
    - ajax请求返回 `状态码0 / error` 表示浏览器没有发出ajax请求, 或者说ajax请求被浏览器取消了.

#### AJAX使用
1. 创建 XMLHttpRequest 对象
    - XMLHttpRequest 对象用于和服务器交换数据
    ````
    var xmlhttp;
    if (window.XMLHttpRequest)
    {// code for IE7+, Firefox, Chrome, Opera, Safari
    xmlhttp=new XMLHttpRequest();
    }
    else
    {// code for IE6, IE5
    xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
    }
    ````
2. `XMLHttpRequest.open(method,url,[async])`
    - method：请求的类型；GET 或 POST
    - url：文件在服务器上的位置
    - async：true（异步）或 false（同步）
3. `XMLHttpRequest.onreadystatuschange=function(){}`
    - 每当 readyState 属性改变时, 就会调用 onreadystatuschange 函数
    - 在 `open()` 中必须指定 `async=true`
    - readyState：XMLHttpRequest 的状态. 从 0 到 4 发生变化
    - Readystatus==4&&status==200：请求已完成, 且响应已就绪
4. `XMLHttpRequest.send(string)` : 将请求发送到服务器(同步请求)
5. `XMLHttpRequest.responseText` : 获得字符串形式的响应数据
6. `XMLHttpRequest.responseXML` : 获得XML形式的响应数据

#### AJAX 读取本地文件
1. 使用 AJAX 读取本地文件示例
    - 参考: [jQuery ajax读取本地json文件](https://www.cnblogs.com/ooo0/p/6385698.html)
    ````
    $(function () {
        $.ajax({
            url: "README.md",
            type: "GET",
            async: true,
            success: function (data) {
                console.log(data)
                new PreVireMarkdown(data, document.getElementById("content"))
            }
        })
    })
    ````
2. 如果直接执行html文件,会遇到 跨域 的问题. 部署到tomcat上就没事了.
    - 参考: [本地主机作服务器解决AJAX跨域请求访问数据的方法](https://www.cnblogs.com/QiScript/p/5580355.html)

### H5无刷新修改url:pushstate
HTML5-history 之 `pushstate 和 popstate`

window.history表示window对象的历史记录, 是由用户主动产生, 并且接受javascript脚本控制的全局对象.

语法格式: `window.history.pushState(data:any,title:string,url:string)`, 表示将 data数据和url入栈, 然后通过监听 popState 事件, 在浏览器点击后退按钮时, 取出url和data. (title暂时没有用)

监听事件
```JavaScript
$(function(){
    window.onpopstate=function()
    {
        // 获得存储在该历史记录点的json对象
        var json=window.history.state;
    }
})
````

如, 在 pageA 页面调用 `history.pushState(data,null,"pageB")` 修改url为pageB, 然后从pageB后退到pageA, 然后从 pageA 再前进到 pageB 时, 才会将data取出. 因为 data 是和 url指定的 pageB 绑定的, 而不是单独入栈, popState 发生时取出.

### 定时器
> https://jeffjade.com/2016/01/10/2016-01-10-javacript-setTimeout/
1. js是单线程执行的
2. setTimeout和setInterval的运行机制是，将指定的代码移出本次执行，等到下一轮Event Loop时，再检查是否到了指定时间。如果到了，就执行对应的代码；如果不到，就等到再下一轮Event Loop时重新判断。这意味着，setTimeout指定的代码，必须等到本次执行的所有代码都执行完，才会执行
    - setTimeout 的第二个参数 timeout 的最大值是 21474836472，我们的设定值超过它，回调函数就会立即执行。
3. `setTimeout()` 执行的代码段必须是字符串, 否则会立即执行
    - 如果推迟执行的是函数，就直接传函数名, `function(){}` 其实也是函数名
    - 为什么 `setTimeout(loop(),1000)` 可以立即执行呢, 是因为 `function(){}` 后面加 `()` 就是 调用该函数立即执行 的意思. 其他语言可能报错,但是js语法宽松,就这么奇怪的过了...
```JavaScript
var loop = function(){
    alert(1)
}
// 延迟 1s 执行
setTimeout(loop,1000)
// 立即执行
setTimeout(loop(),1000)
// 设置参数
setTimeout(function(msg){alert(msg);},1000,"消息内容")
```
