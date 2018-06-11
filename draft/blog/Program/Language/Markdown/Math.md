# 在Markdown中使用数学公式

<!-- TOC -->

- [在Markdown中使用数学公式](#在markdown中使用数学公式)
    - [实现方式](#实现方式)
    - [LaTeX/TeX 数学公式语法](#latextex-数学公式语法)

<!-- /TOC -->

## 实现方式
1. [MathJax引擎](https://github.com/mathjax/MathJax)
    - 使用两个美元符 `$$` 包裹 TeX 或 LaTeX 格式的数学公式, 然后页面加载 Mathjax 对数学公式进行渲染
    ````
    <script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
    # 示例
    $$x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}$$
    ````
2. [在线LaTex编辑](http://www.codecogs.com/latex/eqneditor.php)
3. [Google Chart服务器](http://chart.googleapis.com/chart?cht=tx&chl=\Large x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}): 境内不能用

## LaTeX/TeX 数学公式语法
> [官方文档](http://www.ctex.org/documents/shredder/tex_frame.html)
> [各公式示例](https://en.wikipedia.org/wiki/Help:Displaying_a_formula)

1. 在Markdown内使用tex公式时, 使用 `\\`作为转义字符
    - 示例1, 行内公式 : `\\( ... \\)`  Tex: `\( ...\)`
    - 示例2, 花括号 : `\\{\\}`    Tex: `\{\}`
1. 行间公式: `$$ ... $$`