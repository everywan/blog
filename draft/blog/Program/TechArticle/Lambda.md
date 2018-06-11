# 匿名函数和Lmbda

<!-- TOC -->

- [匿名函数和Lmbda](#匿名函数和lmbda)
    - [C++](#c)
    - [Python](#python)

<!-- /TOC -->

## C++
- Lambda函数： `auto add_fun = [i](int j){return i+j;};`
    - `auto` 表示自动类型推断
    - `[]` 表示捕获列表(从作用域中)
    - `()` 表示lambda函数的参数列表
    - `{}` 表示函数体
    - `add_fun(2)` 调用示例

## Python
- 列表解析
    - `pageID = 3,  ["{} in page{page_i}".format("a",page_i=page_j)for page_j in range(1,pageID)]`
    - result: `['a in page1','a in page2']`
- 生成器解析, 迭代器的值如上
    - `pageID = 3,  ["{} in page{page_i}".format("a",page_i=page_j)for page_j in range(1,pageID)]`
    - result: `<generator object <genexpr> at 0x7f3e725d7af0>`
