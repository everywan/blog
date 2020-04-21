# Markdown

设计哲学

Markdown 的目标是实现 **易读易写**, 成为一种适用于网络的
书写语言/标记语言.

**可读性** 在 Markdown 中是最重要: 一份使用 Markdown 格式撰写
的文件应该可以直接以纯文本发布, 并且看起来不会像是由许多标签
或是格式指令所构成.

参考 Markdown 作者Gruber缩写, 
[Markdown PHILOSOPHY](https://daringfireball.net/projects/markdown/syntax)

> Markdown is intended to be as easy-to-read and easy-to-write as is feasible.
>
> Readability, however, is emphasized above all else. A Markdown-formatted 
> document should be publishable as-is, as plain text, without looking like 
> it’s been marked up with tags or formatting instructions. While Markdown’s 
> syntax has been influenced by several existing text-to-HTML 
> filters — including Setext, atx, Textile, reStructuredText, Grutatext, and 
> EtText — the single biggest source of inspiration for Markdown’s syntax is 
> the format of plain text email.
>
> To this end, Markdown’s syntax is comprised entirely of punctuation 
> characters, which punctuation characters have been carefully chosen so as 
> to look like what they mean. E.g., asterisks around a word actually look like
> *emphasis*. Markdown lists look like, well, lists. Even blockquotes look like 
> quoted passages of text, assuming you’ve ever used email.

----
现状

Markdown作者对于Markdown语法的规范描述并不明确, 导致不同的
实现下对相同源码呈现结果不同. 如在 Github Wiki 上呈现与
pandoc呈现不同的结果.

GFM(github favorite markdown), 是Markdown的一种方言, 用于在
Github上呈现Markdown内容.

GFM 基于CommonMark Spec, 是CommonMark的严格超集.

具体参考 [gfm](https://github.github.com/gfm/), 如下是一些
个人总结的用法.

## Markdown语法
1. 缩进:
    * 半方大的空白'\&ensp;' 或 '\&#8194;'
    * 全方大的空白'\&emsp;' 或 '\&#8195;'
    * 不断行的空白格'\&nbsp;' 或 '\&#160;'  
2. 换行:  
    * 在插入处先按入两个以上的空格然后回车
3. 连接: (链接前加`!`表示图片链接)
    - 行内式: `![exam](exam.png)`
    - 参考式连接
        ```Markdown
        This is [an example][id] reference-style link.
        # 必须放在末尾. title表示悬浮显示的提示词
        [id]: http://example.com/  "title"
        ```
4. 跳转到业内锚点: A: 使用`##`等markdown标题语法实现
  B: 使用html语法中的 `#` 实现
    ```Markdown
    // A:
    [简洁的swap函数](#简洁的swap函数)
    ### 简洁的swap函数
    // B:
    [简洁的swap函数](#Question1)
    <p id="Question1"></p>
    ```
5. GFM-高亮代码: 
  ````
  # 以Go举例
  # ```Go
  # ```
  ````

## 在Markdown中使用数学公式
### 实现方式
1. [MathJax引擎](https://github.com/mathjax/MathJax)
    - 使用两个美元符 `$$` 包裹 TeX 或 LaTeX 格式的数学公式, 然后页面加载 Mathjax 对数学公式进行渲染
    ````
    <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
    # 示例
    $$x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}$$
    ````
2. [在线LaTex编辑](http://www.codecogs.com/latex/eqneditor.php)
3. [Google Chart服务器](http://chart.googleapis.com/chart?cht=tx&chl=\Large x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}): 境内不能用

### LaTeX/TeX 数学公式语法
> [官方文档](http://www.ctex.org/documents/shredder/tex_frame.html)
> [各公式示例](https://en.wikipedia.org/wiki/Help:Displaying_a_formula)

1. 在Markdown内使用tex公式时, 使用 `\\`作为转义字符
    - 示例1, 行内公式 : `\\( ... \\)`  Tex: `\( ...\)`
    - 示例2, 花括号 : `\\{\\}`    Tex: `\{\}`
1. 行间公式: `$$ ... $$`

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
