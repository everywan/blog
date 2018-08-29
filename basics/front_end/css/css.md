## CSS
常识:
1. margin调节外部间距, padding调节内部间距.
2. 一般不设置元素高度, 而是自动计算.
3. font-size 只设置字体大小, 系统会附加默认行高, 所以浏览器计算出的 height 不只是 font-size 的大小, 而是 `line-height
 + padding`. 

### 盒子模型
- [参考: 盒子模型](https://developer.mozilla.org/zh-CN/docs/Web/CSS/CSS_Box_Model/Introduction_to_the_CSS_box_model)
- [参考: 知乎补充](https://zhuanlan.zhihu.com/p/24778275)
> every element in web design is a rectangular box

盒子模型: 当对一个文档进行布局(laying out)的时候, 浏览器渲染引擎会根据CSS-Box模型(CSS Basic Box model)将所有元素表示为一个矩形盒子(box).

在CSS中, 使用 margin,border,padding,content 描述一个盒子

### 文档流/normal flow
- [参考: normal flow](https://tink.gitbooks.io/fe-collections/content/ch03-css/normal-flow.html)

normal flow: 文档流是相对于盒子模型而言的, 是指元素按照其在 HTML 中的先后位置至上而下布局, 在这个过程中, 行内元素水平排列, 直到当行被占满然后换行; 块级元素则会被渲染为完整的一个新行.
- 除非另外指定, 否则所有元素默认都是普通流定位, 也可以说, 普通流中元素的位置由该元素在 HTML 文档中的位置决定.

元素浮动之后, 会让它跳出文档流, 也就是说当它后面还有元素时, 其他元素会无视它所占据了的区域, 直接在它身下布局. 但是文字却会认同浮动元素所占据的区域, 围绕它布局, 也就是没有拖出文本流.

#### 脱离文档流
在css2.1中, 一个盒子的布局取决于三种定位模式
1. normal flow 文档流.
2. 浮动机制
3. 绝对定位

除了根元素, 后两种布局模式的元素就被称为是脱离常规流的.

一旦一个元素脱离常规流:
- 其它元素当它不存在
- 但不会从dom树中脱离
- 既: 有户口, 没有地, 依然是本国公民.

##### 浮动
浮动机制中, 一个框盒首先根据常规流来布局, 然后脱离常规流, 向左/右移动. 这导致沿着它边上的文本content都将"浮动". 即, 其它盒子看不到被float的盒子, 但其它盒子中的文本却能看到它.

**高度坍塌** 就是浮动导致的脱离文档流的情况
- [参考: 高度坍塌](https://www.jianshu.com/p/f09f40591d97)

高度坍塌: 在文档流中, 若父元素未设置高度, 那么父元素的高度默认是被子元素撑开的, 即子元素多高, 父元素就有多高. 但是当子元素设置浮动之后, 子元素就会完全脱离文档流, 父元素还在文档流中, 此时父元素的高度就没有子元素撑起（子元素无法撑起父元素的高度）, 从而导致父元素的高度塌陷. 简单来说, 就是包含含有浮动的元素的上一级的高度变为0了, 下面的元素会上去, 这样会导致页面布局混乱.

##### 绝对定位
绝对定位机制中, 一个框盒被完全地从常规流中删除, 所以对它的后续邻接毫无影响.

### 优先级
1. CSS属性越靠后设置, 优先级越高
    - !important 可以强行改变CSS优先级, 调至最高
    - 多个 !important 则越靠后优先级越高

### display
1. `display: flex;` 弹性布局
    - https://www.cnblogs.com/xuyuntao/articles/6391728.html
    - 子元素的float、clear和vertical-align属性将失效
2. 使用 postion 时, 默认相对于 body 进行定位. 如果 父div 设置了 `postion=relative;`, 那么子元素定位是相对于父元素而不是body.