<!-- TOC -->

- [单元测试 && 异常](#单元测试--异常)
    - [异常](#异常)
    - [doctest](#doctest)
    - [unittest](#unittest)

<!-- /TOC -->

# 单元测试 && 异常
> 单元测试在大项目里很有用, 但是 Python 大部分都用来写脚本了, 用处并不大

## 异常
- 自定义异常
    ```Python
    myExce = BaseException()
    myExce.message = "传入的i不是int类型, i:" + str(i)
    raise myExce
    ```
- 捕获异常
    ```Python
    try:
        if a==1:
            print 1
    except BaseException,e:
        # e为BaseException的实例
        # repr(e): 创建字符串封装 e 的值
        print repr(e)   # NameError("name 'a' is not defined",)
    ```
- traceback 模块: 获取详细异常信息
    ```Python
    import traceback  
    try:  
        1/0  
    except Exception,e:  
        traceback.print_exc()
    # 输出
    # Traceback (most recent call last):
    # File ".\test.py", line 3, in <module>
    #     if a==1:
    # NameError: name 'a' is not defined
    ````
## doctest
- 搜索那些看起来像交互式会话的 Python 代码片段, 然后尝试执行并验证结果
    ```Python
    def adddd(a, b):
        """
        >>> adddd(1,2)
        3
        >>> adddd(3,4)
        7
        """
        return a+b
    if __name__ == '__main__':
        import doctest
        import Sec5
        doctest.testmod(Sec5, verbose=True) # verbose 表示开启详细信息, 也可以在cmd中调用时添加 '-v'
        # doctest.testfile(test.txt) 使用test.txt里的测试用例测试. 内容类似""" """里的
    # 测试
    >python Sec5.py  -v
    Trying:
        adddd(1,danyuanceshi2)
    Expecting:
        3
    ok
    Trying:
        adddd(3,4)
    Expecting:
        7
    ok
    1 items had no tests:
        Sec5
    1 items passed all tests:
       2 tests in Sec5.adddd
    2 tests in 2 items.
    2 passed and 0 failed.
    Test passed.
    ```
## unittest
```Python
# coding:utf-8
import unittest

def adddd(a, b):
    return a+b
class MyTestClass(unittest.TestCase):
    # setUp() : 每个测试方法执行前执行
    # tearDown() : 每个测试方法之后执行
    def testSec4(self):
        print adddd(2, 3)
        # 只有当 "adddd(11, 11) == 223" 表达式成立时,才算通过测试,否则抛出 "AssertionError: Im just test" 异常
        self.failUnless(adddd(11, 11) == 223, 'Im just test')  # 不只是failUnless, 还有其他的, 顾名思义, 看IDE提示就行了
if __name__ == '__main__': # 双横线
    unittest.main()
```