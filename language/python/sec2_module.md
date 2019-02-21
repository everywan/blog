<!-- TOC -->

- [Python模块](#python模块)
    - [基础模块/知识](#基础模块知识)
        - [sys/os/commands](#sysoscommands)
        - [文件管理](#文件管理)
        - [堆-heapq](#堆-heapq)
        - [time](#time)
        - [random](#random)
        - [集合-set](#集合-set)
        - [操作MySQL](#操作mysql)
        - [自动构建Linux命令规范](#自动构建linux命令规范)

<!-- /TOC -->

# Python模块

## 基础模块/知识
1. import模块会先解释/运行模块中的代码
1. Python中, A ,  B项目可以互相引用, 但是会先执行主程序的, 再执行import模块的主函数
    - C#中, 循环引用是不会允许的, 编译器会直接检查并报错
    - 并且, C#对类库的加载时动态的, 不会在加载时执行类库的代码, 而是在调用时执行
3. [NumPy](https://zh.wikipedia.org/wiki/NumPy): 数组运算, 矩阵运算, 三角函数计算 用于扩充math库
4. matplotlib: 绘图库, 类似与MATLAB
4. hashlib: hash求值, 用于签名, 加密
5. difflib: 计算两个序列的相似程度

### sys/os/commands
> 与Python解释器(sys)/操作系统(os)有关功能的模块

- sys: 与Python解释器联系紧密的变量和函数
    ```Python
    sys.argv # 从命令行传递到Python解释器的参数, 包括脚本名称
    sys.exit(arg) # 退出当前程序, 并将arg作为返回值返回
    sys.moudles # 将模块名称映射到实际存在的模块上（只应用于目前导入的模块）
    sys.platform # 解释器正在运行的平台
    sys.path # 解释器会从这些目录查找import的modules
    sys.stdin stdout stderr # 标准输入, 输出, 错误流
    ```
- os: 访问多个操作系统服务的功能
    ```Python
    os.environ # 对环境变量进行映射 例 os.environ["pythonpath"]
    os.system(command) # 在子shell中执行操作系统命令, 返回值: 命令执行的退出状态码
    os.popen(command) # 在子shell中执行操作系统命令, 返回值: 命令执行的输出
    os.sep # Path 字符串中分隔符: / \\
    os.pathsep # 分割多个 path 的分隔符 linux:":" windows:";"
    os.linesep # 行的分隔符 linux:"\n" windows:"\r\n"
    os.urandom(n) # 返回n个字节的加密强随机数据
    os.getcwd() # 获取当前路径
    os.path.exists(directory) # 如果目录不存在就返回False
    os.path.isfile('test.txt') # 如果不存在就返回False
    os.mkdirs() # 创建目录
    ```
- commands: os模块补充
    ```Python
    commands.getstatusoutput(cmd) # 获取命令的返回值和输出,结构 (status,output)
    ```

### 文件管理
> `open(filename[, mode, buffering])`

1. open()和file()相似, 读取时都返回一个file对象, 写入时没有文件则创建
1. fileinput模块可以按行读取文件(适合遍历大文件), open()直接读取所有行
1. python3中弃用了file, 所以推荐使用open()函数
2. 使用二进制读写文件的原因: Python会对文件做一些自动转换, 将windows格式的换行: `\r\n` 转换为Linux格式 `\n`, 读写都会自动转换. 导致处理某些二进制文件(比如图片)会破坏原有结构
2. `file.truncate() # 清空文件内容`
2. buffering: 0 无缓冲,立即写回. -1 使用默认缓冲区大小. 1 使用内存替代硬盘. >1 代表缓冲区大小. 只有使用 flush() 或 close()才会刷新缓冲, 更新到硬盘上
9. 新手提示
    - 操作模式: r read, w write, a append, b 二进制
9. 推荐使用with读写文件, 具体查看Sec1中的托管/非托管资源介绍
    ```Python
    with open() as temp:
        for line in temp:
            ...
    ```
9. readlines()时去除line的换行符: 
    ```Python
    line.strip()
    line[:-1]
    ```
### 堆-heapq
```Python
heapq.heappush(heap,x) # 将x入堆
heapq.heappop(heap) # 将堆中最小的元素弹出
heapq.heapify(heap) # 将heap转换为合法的堆:此heap为min-heap,任意父节点小于其子节点,即 x[i] < (x[2i] | x[2i]+1)
heapq.heapreplace(heap,x) # 将 heap 中最小的元素换为 e
heapq.nlargest(n,iter) # 返回iter中第n大的元素 (heap 实现了_iter_ 方法)
heapq.nsmallest(n,iter) # 返回iter中第n小的元素
```

### time
- 时间元组 (year, mon, mday, hour, min, sec, wday, yda, isdst)
```Python
time.asctime([tuple]) # 将时间元组转换为字符串
time.localtime([secs]) # 将秒数转换为日期元组,无参则表示 now
time.mktime(tuple) # 与localtime 相反, 转换为秒数
time.sleep(secs) # 让解释器休眠 secs 秒
time.strptime(string[, format]) # 将字符串解析为时间元组
time.time() # 当前时间
```

### random
```Python
random.random() #返回0<b<=1之间的随机实数
random.getranbits(n) # 以长整型形式返回n个随机位
random.uniform(a,b) # 返回随机实数n,其中 a<=n<b
random.randrange([start], stop, [step]) # 返回range(start, stop, step)中的随机数
random.choice(seq) # 从序列seq中返回随机元素, 返回的值是seq元素的深复制
random.shuffle(seq[, random]) # 将seq变为随机序列  random参数为函数, 估计是自定义的随机算法吧,没有尝试
random.sample(seq, n) # 从序列seq中选出n个随机且独立的元素
```

### 集合-set
1. set: 集合的元素只能是不可变值 == 元素可散列(set为集合,可进行逻辑运算). 但是集合是可以增删元素的
2. frozenset: 不可变（可散列）的集合. 构造函数创建给定 set 的副本. 
```Python
a=set([1,2])
b=set([2,3])
a.add(b)==wrong,b可变
a.add(frozen(b)) == ([1,2,frozen([2,3])])
```

### 操作MySQL
1. 安装 MySQL-python: `sudo apt-get install python-mysqldb`
    - 使用`pip install MySQL-python`安装MySQL-python, 可能遇到`mysql_config not found`错误, ubuntu下执行`apt install libmysqlclient-dev`即可
    - 原因: `mysql_config` 用于编译mysql客户端, 配置mysql的编译设置. 而通过apt/yum安装的mysql是不需要编译的,自然也没有这个文件.
2. 基本操作: 参考: https://www.cnblogs.com/fnng/p/3565912.html
    ```Python
    import MySQLdb
    conn= MySQLdb.connect(host='localhost',port = 3306,user='root',passwd='hold?fish:palm',db ='fish',)
    cur = conn.cursor()
    aa = cur.execute(sql)
    // sql: select
    print cur.fetch`one|many`(aa)
    // sql: insert, 执行单条／多条
    cur.execute("insert into student values(%s,%s)",('3','Huhu'))
    cur.executemany("insert into student values(%s,%s)",[
            ('3','Tom'),　('3','JackMa'),])
    cur.close()
    // conn.commit()方法在提交事务. 在向数据库插入一条数据时必须要有这个方法，否则数据不会被真正的插入。
    conn.commit()
    conn.close()
    ```

### 自动构建Linux命令规范
> 参考: [python官方](https://docs.python.org/3/library/optparse.html), [中文博客](http://www.cnblogs.com/captain_jack/archive/2011/01/11/1933366.html)  
> 用途: 为Python脚本生成标准的, 符合 Unix/Posix 规范的命令行说明. 参考 `ls -l, ls --list`

- 简单示例: 添加option
    ```Python
    from optparse import OptionParser
    [...]
    parser = OptionParser()
    parser.add_option("-f", "--file",action="store", dest="filename",
                    help="write report to FILE", metavar="FILE")
    parser.add_option(...)
    (options, args) = parser.parse_args()
    ```
- 传递参数: action 是 `parse_args()` 方法的参数之一, 指示 optparse 当解析到一个命令行参数时该如何处理. 默认为 store
    - `action="store", dest="filename"`, dest是参数的变量名
    - `(options, args) = parser.parse_args()` 将参数赋值给options(字典型, key为dest指定的string串, 值为参数值), args中为命令中多余的参数