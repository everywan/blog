<!-- TOC -->

- [Python入门](#python入门)
    - [基础知识](#基础知识)
        - [new/init区别](#newinit区别)
        - [单例模式](#单例模式)
        - [实践操作](#实践操作)
    - [进阶](#进阶)
        - [获取对象属性](#获取对象属性)
        - [range/xrange](#rangexrange)
    - [坑点](#坑点)
    - [练习](#练习)

<!-- /TOC -->

# Python入门
> 基本和其他语言差不多. 记录了部分自己之前不了解的, 或者Python独特的用法

- [yield迭代器](/Program/Language/Python/Yield.md)
- [GIL全局解释器锁](/Program/Language/Python/GIL.md)

## 基础知识
1. 使用 dic2 更新 dic1 中对应 key 的值 `dic1.update(dic2)`
1. `raw_input/input: raw_input`: 将输入封装为string, 而input假设输入的是合法字符串（"like this"）
1. with关键字: 上下文管理器. 类似 C# 中的 using语句: `using(){}`
    - `using(class1,class2...)` 中 class 必须实现  IDisposable()方法, 才能在using结束后释放 非托管资源
    - with 的实现是利用进入 with 语句时调用 `_enter_` 方法,返回值绑定在as关键字. 退出时调用 `_exit_` 方法.
    - 托管资源: 托管堆上分配的内存资源, 即.NET可以自动进行回收的资源
    - 非托管资源: .NET不知道如何回收的资源, 最常见的一类非托管资源是包装操作系统资源的对象. 比如 文件, 流, 网络连接等.
    - nested : 将多个 with 链接起来. `with nested(A(), B(), C()) as (X, Y, Z) == with A() as X:    with B() as Y:  with C() as Z`
1. 分片: array[begin:end:step], 且Array索引[0]和[length]前后都有一个默认的不可见索引,所以, 不写begin/end时也会将最后一个取出来
    - 可以有以下用法：
        - nums[:3]提取前三个
        - nums[::4]提取[0,4,8]
        - nums[-3:]提取后三个
        - nums[:7] == [9,8,7]
    - 支持插入/删除：
        - nums[1:1]=[2,3,4]在[0]后插入[2,3,4]
        - nums[0,2]将前两个元素置空
    - Array[-1]： 倒着数第一个
    - 使用分片获取字符串中的指定字串
1. `*parm`: 代表多个参数
    ```Python
    def test (*parm):
        pass
    test(x,y,z)
    ```
1. `**parm`: 代表多个带关键字的参数
    - `test(a="aaa",b="bbb")`
1. `len()/a.__len__()`: 数组/字符串长度
1. `Array*2`, (浅)复制数组元素(只有引用类型有效, 值类型没有深浅复制之分)
    ````
    a = [[]]
    a = a*2 == [[],[]]
    a[0].append(2)
    a == [[2],[2]]
    a[0] = [1]
    a == [[1],[2]]
    ````
1. 深复制方法 `a = copy.deepcopy(b)`
1. 字符串格式化
    - `"%s:%s:%s" % (hh,mm,ss)`
    - `"{0}:{1}:{2}".format(hh,mm,ss)`
2. 迭代器：若 class 实现了 `_iter_` 方法, 则可对其进行迭代
2. 使用main函数
    ```Python
    if __name__ == '__main__':
        pass
    ```
2. `fun._doc_`打印帮助文档
    ```Python
    def fun():
        'Introduced'
        // 或者
        // """Introduced"""
    ```
2. `float/float!=1`, 因为 `float/float` 结果为float类型, == 会先比较类型, 然后才会比较值
    - `2.0/3.0` 得到的结果即为浮点型
2. 属性: `a. xx=property(get(),set(),del(),doc)`
3. `eval(x)`: 求值, x是字符串
3. `exec(x)`: 执行. `exec('print "out_test"')  # out_test`
3. `repr(x)`: 创建字符串封装x的值
    - `str()`: 返回可打印表示的字符串
    ```Python
    str("3+4")          # '3+4'
    repr("3+4")         # "'3+4'"

    eval(str("3+4"))    # 7
    eval(repr("3+4"))   # '3+4'

    from datetime import datetime
    now = datetime.now()
    str(now)            # '2018-03-17 21:52:12.529000'
    repr(now)           # 'datetime.datetime(2018, 3, 17, 21, 52, 12, 529000)'
    ```
3. 排序函数
    ```Python
    # 指定iterable中 进行排序 的字段
    sorted(iterable, cmp=None, key=None, reverse=False)
    ```
3. python函数内可以加空行, 只要保证缩进相同即可
4. 三目运算符: 使用 if/else 实现: `a=b if b>2 else 4`
5. 断言: `assert a==1`, 如果断言失败 默认抛出 `AssertionError` 异常.
    - 断言失败抛出异常并添加自定义信息: `assert a==1,'wrong value'`
9. `r'string'` 效果等同于C#中的 `@'string'`, 作用是使string中转移字符失效.(Java中无此原生实现)
9. python2 无法输入中文：python默认将代码文件内容当作asci编码处理, 但asci编码中不存在中文, 因此抛出异常. 常用的方法为：
    a. 将源编码转换为utf-8形式：首行添加  `# coding:utf-8`

### new/init区别
1. `__new__(cls)` 方法用于创建实例对象,分配空间
1. `__init__(self, ...)`方法 是对实例对象内的属性等执行初始化赋值
2. `__new__(cls)` 是通过调用父类或者object的 `__new__(cls)` 方法创建对象的, 具体如何创建应与python编译器底层有关.
3. 使用
    - [单例模式](#单例模式)

### 单例模式
```Python
# 定义
_instance = None
def __new__(cls):
    if randomRideTime._instance is None:
        randomRideTime._instance = object.__new__(cls)
        randomRideTime._instance.__init__()
    return randomRideTime._instance
# 使用
randomRideTime.__new__(randomRideTime)
randomRideTime._instance.getStartTime()
```

### 实践操作
- 将当前时间格式化输出：
    `time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.time()))`
- 当前时间戳, 浮点型, 整数部分是秒
    `time.time()`
- `time.ctime()` 和 `time.asctime()`
    - asctime 将时间转换为ascii码
    - 输出格式： `Thu Jul 06 00:09:06 2017`

## 进阶
1. `[]` 内通过匿名函数生成数组
    - `['/user/{page}/'.format(page=page) for page in range(1, 4)]` 结果: `['/user/1/', '/user/2/', '/user/3/']`
2. `()` 内通过匿名函数生成生成器表达式
    - `('/user/{page}/'.format(page=page) for page in range(1, 4)` 结果: 元素为`('/user/1/', '/user/2/', '/user/3/')`的生成器表达式
3. `{}` 内通过匿名函数生成set集合
    - `{'/user/{page}/'.format(page=page) for page in range(1, 4)}` 结果: `set(['/user/2/', '/user/3/', '/user/1/'])`
4. `zip(*args)`: 将可迭代的对象中对应的元素打包成元组, 然后返回由这些元组组成的列表
    - 示例: `a=[1,2] b=['a','b'] zip(a,b)`  输出: `[(1,'a'),(2,'b')]`

### 获取对象属性
1. `dir(object)`: 获取对象的所有属性和方法
2. `getattr(object, name[,default])`: 获取对象Object名称为name的**属性值**, 效果等同于`o.name`.
    - default参数: 如果找不到则返回 default. 不设置 则触发AttributeError
    - 对象属性: 是指对象拥有的字段. map的键值对不是属性, 不能使用`getattr()` 
    - 示例: `a={}`, `getattr(a,'__doc__')` 返回map的doc文档

### range/xrange
1. `range([start,] stop[, step])`: 根据start与stop指定的范围以及step设定的步长, 生成一个序列
    - `range(5)`: `[0, 1, 2, 3, 4]`
2. xrange: 用法与range完全相同, 不过 xrange 生成一个迭代器
    - 使用 `list(xrange(5))` 生成list对象, 返回所有值
3. 区别: xrange适合做循环, range适合获取list对象
    - `range()` 会直接开辟所需的所有内存空间, 而 `xrange()` 是生成器, 每次调用只返回一个值
    
## 坑点
1. linux/win 下, Python2 中 `str()` 函数默认的编码方式不同
    - win `str("中国")`
        - 输出: `'\xd6\xd0\xd9\xfa'`, GBK编码
    - linux `str("中国")`
        - 输出: `\xe4\xb8\xad\xe5\x9b\xbd`, UTF-8编码
    - `str(u"中国")`
        - 输出: `'ascii' codec can't encode characters in position 0-1: ordinal not in range(128)`

## 练习
1. 求两个数的Hamming Distance
    - 汉明距离:两个等长字符串之间的汉明距离是两个字符串对应位置的不同字符的个数,即将一个字符串变换成另外一个字符串所需要替换的字符个数
    ```Python
    # coding:utf-8
    x=input("请输入第一个数:")
    while not isinstance(x, int):
        print "请输入整数"
        x = input("请输入第一个数:")
    y = input("请输入第二个数:")
    while not isinstance(y, int):
        print "请输入整数"
        y = input("请输入第二个数:")
    t = 1
    z = x ^ y
    if z == 0:
        t = 0
    while z > 0:
        z = (z & (z-1))
        if z:
            t = (t + 1)
    print t
    #以上那么多, 可用一行完成其功能：
    print bin(x ^ y).count("1")
    ```
2. 八皇后问题
    ```Python
    # coding:utf-8
    print "Sec2:八皇后问题"
    result = []
    # 注意需要传递 xs,ys的值而非引用. 否则无法为每一次递归创建副本(深/浅复制)

    def calcu(xs, j):
        if j > 7:
            result.extend(xs)
        else:
            i = 0
            # 对此行每一列做判断看是否符合要求
            while i < 8:
                # 判断该点是否符合规则
                t = 0
                istrue = False
                while t < len(xs):
                    if (i == xs[t]) | (abs((float(i)-xs[t])/(float(j)-t)) == 1):
                        break
                    else:
                        t += 1
                        if t == len(xs):
                            istrue = True
                if istrue:
                    xss = []
                    xss[0:0] = xs
                    # 由于Python传值或传引用是根据参数判断的, 不可指定, 所以只能新建一个副本, 用此副本的值走此次符合规则值的分支, 原值继续向下判断
                    xss.append(i)
                    calcu(xss, j + 1)
                i += 1
    # 若想得出所有的集合, 将xlist从0到1全赋值一次即可
    xlist = [0]
    calcu(xlist, 1)
    print result
    # 将结果打印出来
    while result:
        print
        print "--begin"
        for i in range(0, 8):
            xx = result.pop(len(result) - 1)
            for j in range(0, 8):
                if j == xx:
                    if j == 7:
                        print "_#"
                    else:
                        print "#_",
                else:
                    if j == 7:
                        print 7
                    else:
                        print str(i)+"_",
        print "--end"
        print
    ```