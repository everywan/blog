<!-- TOC -->

- [HTML](#html)
    - [节点类别](#节点类别)
        - [svg-可缩放矢量图形](#svg-可缩放矢量图形)
        - [canvas-画布](#canvas-画布)
    - [奇怪的现象](#奇怪的现象)
        - [闭合标签](#闭合标签)
- [Javascript](#javascript)
    - [JS基础知识](#js基础知识)
        - [MarkDown-JS渲染插件](#markdown-js渲染插件)
    - [npm](#npm)
    - [jquery 基本用法](#jquery-基本用法)
    - [Ajax 基本用法](#ajax-基本用法)
        - [AJAX 读取本地文件](#ajax-读取本地文件)
        - [定时器](#定时器)
- [CSS](#css)
- [开源工具](#开源工具)
    - [图标](#图标)
        - [Ionicons:高级图标字体](#ionicons高级图标字体)
        - [不错的样式](#不错的样式)
    - [JS组件](#js组件)
        - [jslint-代码规范工具](#jslint-代码规范工具)
        - [Bootstrap-响应式布局-移动设备优先](#bootstrap-响应式布局-移动设备优先)
        - [Magnific Popup: 弹出窗口](#magnific-popup-弹出窗口)
        - [photoswipe: 触屏图片弹出窗口](#photoswipe-触屏图片弹出窗口)
        - [owl carousel: 图片滚动模块](#owl-carousel-图片滚动模块)

<!-- /TOC -->

## HTML
### 节点类别
#### svg-可缩放矢量图形
    - 填充颜色: `fill="red"` 或者 `fill="#00A1F1"`
    - 示例: 搜索图标的svg图形, 源于: [ionicons](http://ionicons.com/)
    ````
    <svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
	 width="18px" height="18px" viewBox="0 0 512 512" style="enable-background:new 0 0 512 512;" xml:space="preserve">
    <path d="M445,386.7l-84.8-85.9c13.8-24.1,21-50.9,21-77.9c0-87.6-71.2-158.9-158.6-158.9C135.2,64,64,135.3,64,222.9
        c0,87.6,71.2,158.9,158.6,158.9c27.9,0,55.5-7.7,80.1-22.4l84.4,85.6c1.9,1.9,4.6,3.1,7.3,3.1c2.7,0,5.4-1.1,7.3-3.1l43.3-43.8
        C449,397.1,449,390.7,445,386.7z M222.6,125.9c53.4,0,96.8,43.5,96.8,97c0,53.5-43.4,97-96.8,97c-53.4,0-96.8-43.5-96.8-97
        C125.8,169.4,169.2,125.9,222.6,125.9z" fill="#00A1F1"/>
    </svg>
    ````
    
#### canvas-画布
> 如果需要在html绘图, 但是不知如何实现, 可以查阅下 canvas 有没有好的实现
1. 作用: 通常用于通过脚本绘制图形. canvas 元素本身是没有绘图能力, 所有的绘制工作必须在 JavaScript 内部完成.
2. canvas坐标: canvas是二维网格, 左上角坐标`(0,0)`, 没有负值, 没有小数值. 
    - 如果绘制点类似与 `(1,1)`, 那么 会从 `(0.5~1.5,0.5~1.5)` 绘制, 所以x/y轴都会多占用一个像素.
3. 用法- 绘制 线
    ```JavaScript
    var node=document.getElementById("canvas")
    // 获取内建的 HTML5 对象，拥有多种绘制路径、矩形、圆形、字符以及添加图像的方法
    var canvas = node.getContext("2d");
    // 定义线条开始坐标
    canvas.moveTo(x,y);
    // 定义线条结束坐标
    canvas.lineTo(x,y);

    // 定义圆形: start 起始角度，以弧度表示，圆心平行的右端为0度; stop 结束角度，以弧度表示
    // 画圆的方向是顺时针, Math.PI表示180°
    canvas.arc(x,y,r,start,stop)

    // 将 线 绘制出来
    canvas.stroke();
    // 填充 线 包围的内容
    canvas.fill()
    ```
3. 用法-文本 渐变 图像
    ```JavaScript
    // 设置字体
    canvas.font="30px Arial";
    // 绘制实心字体
    canvas.fillText("Hello World",10,50);
    // 绘制空心字体
    canvas.strokeText("Hello World",10,50);

    // 创建线条渐变: createLinearGradient(x,y,x1,y1)
    var grd=canvas.createLinearGradient(0,0,200,0);
    
    // 创建径向/圆渐变: createRadialGradient(x,y,r,x1,y1,r1)
    // var grd=canvas.createRadialGradient(75,50,5,90,60,100);
    
    // 指定左边点的颜色, addColorStop(x坐标轴, 颜色)
    grd.addColorStop(0,"red");
    grd.addColorStop(1,"white");
    // 填充渐变
    canvas.fillStyle=grd;
    canvas.fillRect(10,10,150,80);

    // 将图片放到画布: drawImage(image,x,y)
    var img=document.getElementById("scream");
    canvas.drawImage(img,10,10);
    ```

### 奇怪的现象
#### 闭合标签
1. 如果`<a>` 标签不闭合, 则浏览器解释后会同时出现在 A处 和 B处
````
<div class="container">
    <div class="pull-left">
        <div class="sign-wrap">
        <!-- A处 -->
        <a href="index.html">
            <img class="logo-light" src="assets/images/logo_light_blue_47.png" alt="">
        </a><!-- 删掉这个闭合试下 -->
        </div>
    </div>
    <!-- B处 -->
    <!-- 标题栏右侧 -->
    <div class="pull-right">
        <div class="sign-wrap">
        <a class="sign-btn" href="#">
            <i class="ion-person"></i>
        </a>
        </div>
    </div>
</div>
````

## Javascript
### JS基础知识
> [w3cshool](http://www.w3school.com.cn/js/index.asp)
1. 浏览器进程按顺序, 单线程解析HTML, 所以JS执行/下载越耗时间, GUI渲染等待越久. 解决办法：
    - `<script defer>` : defer属性：解析到此标签时立即下载, 延迟执行
    - 打包下载：每次下载都有HTTP请求开销. （可使用打包工具或者网上打包处理器如yahoo的）
    - 动态加载脚本技术：提示：script标签有一个load事件/readystart属性, 可用来检测是否下载完成
        - 动态创建`<script>`标签加载JS
        - AJAX动态加载JS
        - 开源库：Lazyload,  LABjs等等
2. 当变量没有被开辟空间/赋值时, `if(aa)` 的值是false. 没必要再使用 `typeof` 或者判空.
3. 设置默认值 `var a =bool?true:false;`
    - 类似于C++的三目运算符
4. 深复制：`var vega_temp = JSON.parse( JSON.stringify(testVega) )`
5. `test()`: 检测一个字符串是否匹配某个模式. 格式: `RegExpObject.test(string)`
    - 举例: A: `alert(/www/.test("WWW"))` , B: `new RegExp("W3School").test("www")`
6. 变量内字符串换行: 使用 `\n` 单独一行,可以换行
7. `require()`: 
    - http://www.ruanyifeng.com/blog/2015/05/require.html

#### MarkDown-JS渲染插件
1. github-api: github 使用GFM(Github-Favorite-Markdown)格式的markdown.
    - 调用github api 直接渲染: `curl https://api.github.com/markdown/raw -X "POST" -H "Content-Type: text/plain" -d "# 1"`
    - github-api返回的文档并没有样式,需要添加css文件.(可以复用其他markdown渲染组件的css文件,如 `markdown-js` 的)

### npm
> [npm简明教程](https://www.jianshu.com/p/e958a74a0fd7)

1. JS 的包管理器
2. `npm install <module>`: 默认安装到 `#{npm_home}/node_modules`
    - `-g`: 将安装包放置在如下位置 `/usr/local`
3. `npm ls [-g]`: 以目录树的形式查看安装包
4. `npm search <module>`: 搜索模块

### jquery 基本用法
> [w3cshool](http://www.w3school.com.cn/jquery/jquery_syntax.asp)

1. $(selector).ready(function(){})：$定义JQuery, (selector)CSS选择器, action操作
2. 若命名冲突, 可用jQuery.noConfict()初始化新变量代替 "$"
3. CSS选择器：使用css对HTML页面中的元素实现一对一, 一对多或者多对一的控制
4. 一些默认方法：$(selector).hide/slider(滑动)/animate(动画)/fade(淡入淡出)/MouseOver/Attr(属性)

### Ajax 基本用法
> [w3cshool](http://www.w3school.com.cn/ajax/index.asp)

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

#### 定时器
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

## CSS
1. padding 是计算在 height 内的
    - 即: 如`height=50 padding=15`, 这个块的 height 还是50, 而不是`50+15*2`
2. `width=100%`: 对于div而言, 是 父节点的width - 同级其他块的width
    - `<div><div style="width=100%"></div><button/></div>`
3. `display: flex;` 弹性布局
    - https://www.cnblogs.com/xuyuntao/articles/6391728.html
    - 子元素的float、clear和vertical-align属性将失效
4. https://www.w3cplus.com/css/css-overlay-techniques.html
5. 使用 postion 时, 默认相对于 body 进行定位. 如果 父div 设置了 `postion=relative;`, 那么子元素定位是相对于父元素而不是body.
6. canvas绘图时, 如果绘制 `ctx.moveTo(5,5)` 其实是绘制 4.5~5.5 的1px宽的线, 因为canvas是bitmap, 所以会虚化到 4~6 两个像素点.
    - 如果想要绘制1px的线, 可以使用 `ctx.translate(0.5, 0.5);` 缩放线宽, 或者 绘制 `ctx.moveTo(5.5,5.5)`

## 开源工具
### 图标
#### Ionicons:高级图标字体
> http://ionicons.com/
使用MIT协议,可以在商业中使用. 

#### 不错的样式
1. 蓝色: `#00A1F1`. (win10图标中的蓝色)

### JS组件
#### jslint-代码规范工具
#### Bootstrap-响应式布局-移动设备优先
> https://v3.bootcss.com/    
> [菜鸟教程](http://www.runoob.com/bootstrap/bootstrap-intro.html)

1. 受欢迎的 HTML、CSS 和 JS 框架, 用于开发响应式布局、移动设备优先的 WEB 项目.
    - 响应式设计: Bootstrap 的响应式 CSS 能够自适应于台式机、平板电脑和手机
    - Bootstrap 为开发人员创建接口提供了一个简洁统一的解决方案。
    - Bootstrap 包含了功能强大的内置组件，易于定制。
    - Bootstrap 提供了基于 Web 的定制。
    - Bootstrap 是开源的

#### Magnific Popup: 弹出窗口
> 文档: http://dimsemenov.com/plugins/magnific-popup/documentation.html

1. 弹出窗口的插件
    - 模块化,轻量级
    - 支持高DPI
    - 响应式
    
#### photoswipe: 触屏图片弹出窗口
> http://photoswipe.com/

1. 弹出图片并且需要支持触屏使用photoswipe, 其他情况下优先使用 Magnific Popup 

#### owl carousel: 图片滚动模块
> http://www.landmarkmlp.com/js-plugin/owl.carousel/

1. 使图片支持滚动(A->B->C->A)