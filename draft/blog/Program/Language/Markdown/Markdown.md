<!-- TOC -->

- [Markdown](#markdown)
    - [与传统书写语言的对比](#与传统书写语言的对比)
    - [Markdown基本语法](#markdown基本语法)
    - [GFM](#gfm)
    - [ETC](#etc)

<!-- /TOC -->

# Markdown

## 与传统书写语言的对比
- [Markdown](https://github.com/guodongxiaren/README)
    - Markdown 的目标是实现 **易读易写**, 成为一种适用于网络的书写语言
    - **可读性** 在 Markdown 中是最重要 : 一份使用 Markdown 格式撰写的文件应该可以直接以纯文本发布, 并且看起来不会像是由许多标签或是格式指令所构成
- [Tex/LaTex](http://www.ctex.org/documents/shredder/tex_frame.html) : 印刷排版
    - 数学公式、文字排版最强
- [HTML](http://www.w3school.com.cn/html/) : 网页排版

## Markdown基本语法
1. 缩进:
    * 半方大的空白'\&ensp;' 或 '\&#8194;'
    * 全方大的空白'\&emsp;' 或 '\&#8195;'
    * 不断行的空白格'\&nbsp;' 或 '\&#160;'  
2. 换行:  
    * 在插入处先按入两个以上的空格然后回车
3. 连接语法: (链接前加`!`表示图片链接)
    - 行内式: `![exam](exam.png)`
    - 参考式连接
        ````
        This is [an example][id] reference-style link.
        # 必须放在末尾. title表示悬浮显示的提示词
        [id]: http://example.com/  "title"
        ````
4. 跳转到业内锚点: A: 使用`##`等markdown标题语法实现 B: 使用html语法中的 `#` 实现
    ````
    // A:
    [简洁的swap函数](#简洁的swap函数)
    ### 简洁的swap函数
    // B:
    [简洁的swap函数](#Question1)
    <p id="Question1"></p>
    ````
5. [在Markdown中使用数学公式](/Program/Language/Markdown/Math.md)
    
## GFM
github使用的markdown格式,目前比较流行的一种格式

## ETC
1. 刚发现一个特别有意思的现象, 关于markdown的. 将以下代码复制到新的md文档中, 只要在 `begin` 后添加换行, 那么后续同级序列都会增加换行;如果添加多个只有一个有效(不知原因)
````
* begin
* test
    * test
    * test
    * test
* test
    * test
    * test
    * test
````
