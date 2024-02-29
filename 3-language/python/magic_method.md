# 魔术方法

Python 中以 `__` 开始和结束的方法称为魔术方法.

魔术方法在类/对象的某些事件触发时自动执行, 可以根据需要定制类功能/属性. 如通过 `__getitem__` 方法可以更改 `[]` 操作符的意义.

示例 : 更改 test 类 `[]` 操作符的意义
```Python
class test:
    def __getitem__(self,key):
        print(key[0],key[1])
        return "test"

t = test()
print(t[[1,2]])
```

参考: [Python中类的魔术方法](https://www.cnblogs.com/dachenzi/p/8185792.html)
