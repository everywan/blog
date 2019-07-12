<!-- TOC -->

- [协程](#协程)
    - [协程-介绍](#协程-介绍)
    - [迭代器函数-yield](#迭代器函数-yield)
        - [yield-介绍](#yield-介绍)
        - [示例-消费者模型](#示例-消费者模型)
        - [示例-斐波那契数列](#示例-斐波那契数列)
        - [示例-按块读取文件](#示例-按块读取文件)
    - [Gevent](#gevent)
        - [协程状态](#协程状态)
        - [示例-curl下载](#示例-curl下载)
        - [示例-继承greenlet](#示例-继承greenlet)
        - [事件](#事件)
        - [队列](#队列)
        - [WSGI](#wsgi)

<!-- /TOC -->

# 协程
## 协程-介绍
1. 协程, 又称微线程, 纤程. 英文名Coroutine.
    - 协程如 lambda表达式/匿名函数 一样, 是一种编程思想/技巧
2. 什么是协程
    - **子程序**, 或者称为函数, 在所有语言中都是层级调用, 比如A调用B, B在执行过程中又调用了C, C执行完毕返回, B执行完毕返回, 最后是A执行完毕. 所以子程序调用是通过栈实现的, 一个线程就是执行一个子程序.
        - 子程序调用总是一个入口, 一次返回, 调用顺序是明确的.
    - **协程**看上去也是子程序, 但执行过程中, 在子程序内部可中断, 然后转而执行别的子程序, 在适当的时候再返回来接着执行.
        - 注意, 在一个子程序中中断, 去执行其他子程序, 不是函数调用, 有点类似CPU的中断
        - 子程序可以看成协程的一种: 即没有内部中断的协程
    - 和**迭代器**的区别: 迭代器每次调用 `next()` 执行的都是同一段代码逻辑, 但是协程可以执行不同的代码逻辑
3. 在任何时刻, 只有一个协程在运行, 而 multiprocessing或threading 轮转使用操作系统调度的进程和线程, 是真正的并行
    - 与**多线程**相比, 协程的优点在于
        - 避免了线程创建/切换带来的消耗
        - 不需要多线程的锁机制

## 迭代器函数-yield
### yield-介绍
> [参考-协程yield-廖雪峰](http://www.liaoxuefeng.com/wiki/001374738125095c955c1e6d8bb493182103fac9270762a000/0013868328689835ecd883d910145dfa8227b539725e5ed000)   
> [参考-yield-IBM](https://www.ibm.com/developerworks/cn/opensource/os-cn-python-yield/)

1. 迭代器函数: *结合代码更容易理解* [示例](#示例-斐波那契数列)
    - [迭代器表达式](/Program/Language/Python/Sec1-basis.md#进阶)
        - 示例: `('/user/{page}/'.format(page=page) for page in range(1, 4)`
        - 结果: 元素为`('/user/1/', '/user/2/', '/user/3/')`的迭代器表达式
    - **迭代器函数**: 函数中如果出现了yield关键字, 那么该函数是迭代器函数
2. 迭代器函数在一定程度上实现了协程机制
    - 通过调用 `send(msg)` 执行迭代器函数 且当遇到 yield关键字 时中断执行, 返回主程序执行.
    - 再次调用 `send(msg)` 则会从上次中断的位置继续执行, 直到再次遇到 yield关键字, 返回主程序执行
3. `coroutine.send(msg)`: 将msg传入给 迭代器函数, 返回结果是 yield关键字 的参数
    - `coroutine.next() == coroutine.send(None)`
    - 示例
        - 迭代器函数: `d = yield "hello"`
        - 主函数执行 `result = coroutine.send(3)`: result值为`hello`. 协程再次执行(再次调用`send()`)时, d的值为3
4. `coroutine.close()`: 手动关闭迭代器函数, 后面的调用会直接返回StopIteration异常.
5. 当 迭代器函数 执行到结束依然没有遇到中断时, 会抛出 StopIteration 异常. 解决方案如下:
    - for循环: for循环会检测异常且自动调用`next()`
    - 使用 `try/except` 捕获异常
6. 不能使用 `yield return`: `yield args` 返回 args, 而 return 是关键字, 不能作为参数返回

### 示例-消费者模型
> 复制于 https://www.liaoxuefeng.com/wiki/001374738125095c955c1e6d8bb493182103fac9270762a000/0013868328689835ecd883d910145dfa8227b539725e5ed000
1. 协程常用于 传统的生产者/消费者模型. 使用yield跳转到消费者执行消费,执行完毕后再切回生产者
```Python
import time
def consumer():
    r = ''
    while True:
        n = yield r
        print('[CONSUMER] Consuming %s...' % n)
        r = '200 OK'

def produce(c):
    c.next()
    n = 0
    while n < 5:
        n = n + 1
        print('[PRODUCER] Producing %s...' % n)
        r = c.send(n)
        print('[PRODUCER] Consumer return: %s' % r)
    c.close()

if --name--=='--main--':
    c = consumer()
    produce(c)
```
### 示例-斐波那契数列
> 详细参考[示例-IBM](https://www.ibm.com/developerworks/cn/opensource/os-cn-python-yield/)
1. 需求: 不借助全局变量的情况下, 在需要时才获取数列的下一个值

迭代器版本
```Python
class Fab(object): 

   def --init--(self, max): 
       self.max = max 
       self.n, self.a, self.b = 0, 0, 1 
 
   def --iter--(self): 
       return self 
 
   def next(self): 
       if self.n < self.max: 
           r = self.b 
           self.a, self.b = self.b, self.a + self.b 
           self.n = self.n + 1 
           return r 
       raise StopIteration()

for n in Fab(5): 
    print n 
```

yield版本
```Python
def fab(max): 
    n, a, b = 0, 0, 1 
    while n < max: 
        yield b 
        # print b 
        a, b = b, a + b 
        n = n + 1

for n in fab(5): 
    print n 
```
### 示例-按块读取文件
1. 如果直接对文件对象调用 `read()/readline()` 方法, 会导致不可预测的内存占用. 通过固定长度的缓冲区来不断读取文件内容可以是程序更稳定
```Python
def read-file(fpath): 
   BLOCK-SIZE = 1024 
   with open(fpath, 'rb') as f: 
       while True: 
           block = f.read(BLOCK-SIZE) 
           if block: 
               yield block 
           else: 
               return
```

## Gevent
> 参考: [gevent-廖雪峰](https://www.liaoxuefeng.com/wiki/001374738125095c955c1e6d8bb493182103fac9270762a000/001407503089986d175822da68d4d6685fbe849a0e0ca35000)   
> 参考: [gevent程序员指南](http://hhkbp2.github.io/gevent-tutorial/)

1. gevent: gevent通过greenlet为Python实现了比较完善的协程支持
    - greenlet: 以C扩展模块形式接入Python的轻量级协程.  Greenlet全部运行在主程序操作系统进程的内部, 但它们被协作式地调度
2. 基本思想: 当一个greenlet遇到IO操作时, 如访问网络, 就自动切换到其他的greenlet, 等到IO操作完成, 再在适当的时候切换回来继续执行. 由于IO操作非常耗时, 经常使程序处于等待状态, 有了gevent为我们自动切换协程, 就保证总有greenlet在运行, 而不是等待IO
    - 因为切换是在IO操作时自动完成, 所以gevent需要修改Python自带的一些标准库, 这一过程在启动时通过monkey patch完成
3. 实现
    - Gevent处理了所有的细节, 来保证你的网络库会在可能的时候(受限于网络或IO), 隐式交出greenlet上下文的执行权
4. 协程停止: 当主函数收到 SIGQUIT 信号时, 没有成功yield的 Greenlet 可能会挂起程序的执行(这会导致[僵尸进程](https://zh.wikipedia.org/wiki/僵尸进程)的产生, 需要在Python解释器之外被kill)
    - 解决方法: 在主进程中监听信号
        - 监听代码: `gevent.signal(signal.SIGQUIT, gevent.shutdown)`
        - [示例](#示例-curl下载)
5. `monkey.patch-all()`: 用于修改标准socket库中的阻塞式系统调用,使其成为协作式运行, 即修改标准库里的部分函数,使其支持gevent协程方式运行.

### 协程状态
|状态|类型|介绍
|:--------------|:----------|:--
|`started`      | Boolean   | 指示此Greenlet是否已经启动
|`ready()`      | Boolean   | 指示此Greenlet是否已经停止
|`successful()` | Boolean   | 指示此Greenlet是否已经停止而且没抛异常
|`value`        | 任意值     | 此Greenlet代码返回的值
|`exception`    | 异常       | 此Greenlet内抛出的未捕获异常

1. 使用样例
```Python
woker1 = gevent.spawn(worker)
# 获取Greenlet状态: 是否启动
state = woker1.started
state = woker1.successful()
result = worker1.value
```

### 示例-curl下载
```Python
# coding:utf-8
import urllib2
import gevent
import signal
from gevent import monkey; monkey.patch-all()

def worker(url):
    resp = urllib2.urlopen(url)
    print resp.url
    resp.close()

if --name--=='--main--':
    # 监听信号, 当主进程停止时结束协程(部分版本没有shutdown函数)
    # gevent.signal(signal.SIGQUIT, gevent.shutdown)
    # 设置超时
    timeout = gevent.Timeout(3)
    timeout.start()
    try:
        # joinall: 阻塞当前流程, 执行所有给定的greenlet, 执行流程只会在 所有greenlet执行完后才会继续向下走
        gevent.joinall([
            # spawn: 将worker函数封装到Greenlet内部线程
            gevent.spawn(worker,"http://www."+domain+".com") for domain in ["xiagaoxiawan","zhihu","google"]
            ])
    except gevent.Timeout:
        print("timeout!!")
```
### 示例-继承greenlet
```Python
import gevent
from gevent import Greenlet

class MyGreenlet(Greenlet):

    def --init--(self, message, n):
        Greenlet.--init--(self)
        self.message = message
        self.n = n

    def -run(self):
        print(self.message)
        gevent.sleep(self.n)

g = MyGreenlet("Hi there!", 3)
g.start()
g.join()
```

### 事件
> [事件](/ETC/Words.md#事件): 事件是一种 订阅/消费 的模型, 理解 gevent 的事件需要先了解什么是事件

1. 事件(event): 用于Greenlet之间的异步通信
    - event 采用`wait()`订阅事件,等待消息; 使用`set()`发布事件
    - 事件定义: `evt = gevent.event.Event()`
    - 订阅事件: `evt.wait()`; 发布事件: `evt.set()`
2. AsyncResult: 事件的一种扩展, 允许程序在唤醒调用上附加一个值. 具体参考例子
    - 有时也被称作是future或defered, 因为它持有一个指向将来任意时间可设置 为任何值的引用
    - 当从 `AsyncResult` 对象中读取数据时, 若还没有被赋值,则该函数陷入阻塞, 协程切换到其他函数执行.
```Python
# coding:utf-8
import gevent
from gevent.event import AsyncResult
# 创建AsyncResult对象
a = AsyncResult()

def setter():
    gevent.sleep(3)
    # 发送事件
    a.set('Hello!')

def waiter():
    # 监听事件. 当 AsyncResult 没有被赋值时, waiter函数执行被中断, 切换到其它函数执行
    print(a.get())

def worker3():
    # 测试函数, 当AsyncResult.get() 被阻塞时检测是否会调用本函数
    print "worker3"

gevent.joinall([
    gevent.spawn(waiter),
    gevent.spawn(setter),
    gevent.spawn(worker3),
])
```
### 队列

*等以上部分掌握的差不多了, 后续部分再整理*

### WSGI
1. WSGI: Web Server Gateway Interface
2. 使用 `gevent.pywsgi` 配合 Flask 实现 web server
```Python
from flask import Flask
import gevent.pywsgi
import gevent

app = Flask(--name--)

@app.route("/")
def handle():
    return "<h1>Hellp Flask</h1>"

gevent-server = gevent.pywsgi.WSGIServer(('',8000),app)
gevent-server.serve-forever()

```
