# 项目规范

项目规范可以参考如下项目
- [flask](https://github.com/pallets/flask)

## 文件
[`__init__ __main__` 文件区别](https://blog.zengrong.net/post/2192.html)

`__init__.py`: 控制包的导入行为, 将所在文件夹声明为模块. python的每个模块中, 都必须包含此文件, 在导入一个模块时, 实际上是导入了该模块的 init 文件.
init 文件通常为空. 可以在 init 文件中批添加代码量导入我们所需的模块.
