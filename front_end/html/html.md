- [HTML](#html)
  - [节点类别](#%E8%8A%82%E7%82%B9%E7%B1%BB%E5%88%AB)
    - [template](#template)
    - [svg-可缩放矢量图形](#svg-%E5%8F%AF%E7%BC%A9%E6%94%BE%E7%9F%A2%E9%87%8F%E5%9B%BE%E5%BD%A2)
    - [canvas-画布](#canvas-%E7%94%BB%E5%B8%83)
  - [奇怪的现象](#%E5%A5%87%E6%80%AA%E7%9A%84%E7%8E%B0%E8%B1%A1)
    - [闭合标签](#%E9%97%AD%E5%90%88%E6%A0%87%E7%AD%BE)

# HTML
## 节点类别
### template
HTML `<template>` 元素是一种用于保存客户端内容的机制，该内容在页面加载时不被渲染，但可以在运行时使用 JavaScript 进行实例化。
可以将一个模板视为正在被存储以供随后在文档中使用的一个内容片段。

虽然, 在加载页面的同时,解析器确实处理 <template>元素的内容，这样做只是确保这些内容是有效的; 然而,元素的内容不会被渲染

### svg-可缩放矢量图形
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
    
### canvas-画布
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
4. 用法-文本 渐变 图像
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

canvas绘图时, 如果绘制 `ctx.moveTo(5,5)` 其实是绘制 4.5~5.5 的1px宽的线, 因为canvas是bitmap, 所以会虚化到 4~6 两个像素点.
- 如果想要绘制1px的线, 可以使用 `ctx.translate(0.5, 0.5);` 缩放线宽, 或者 绘制 `ctx.moveTo(5.5,5.5)`

## 奇怪的现象
### 闭合标签
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
