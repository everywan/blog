<!-- TOC -->

- [网络编程](#网络编程)
    - [HTML](#html)
        - [HTMLParse](#htmlparse)

<!-- /TOC -->

# 网络编程

## HTML
### HTMLParse
> [接口文档](https://docs.python.org/2/library/htmlparser.html)
1. 解析 HTML 和 XHTML 的基础类
    - Python2: HTMLParse, Python3: html.parse
2. 基本使用: 继承 `HTMLParse.HTMLParse`, 并覆盖所需方法实现所需逻辑, attrs 表示该标签的属性, 如 `href`, `id` 等
    - `handle_starttag(tag, attrs)`: 遇到HTML标签开始标记时, 需要处理的逻辑. 如遇到 `<html>`
    - `handle_endtag(tag)`: 遇到标签结束标记时, 需要处理的逻辑. 如遇到 `</html>`
    - `handle_data(data)`: 如何处理开始标签和结束标签之间的数据. 如遇到 `<html>Data</html>`中的 Data
3. 常用方法
    - `feed(html)`: 将文本数据导入Parse, 支持 unicode/str, 建议 unicode.
        - `feed()`可以被多次调用, 直到调用 `close()`. 没有结束标签的数据会被程序缓冲, 直到传入结束标签或者调用 `close()`

    