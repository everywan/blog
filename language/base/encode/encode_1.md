<!-- TOC -->

- [编码集/字符集](#编码集字符集)
- [编程语言中的编码](#编程语言中的编码)
    - [Python2 编码使用问题](#python2-编码使用问题)
- [ETC](#etc)

<!-- /TOC -->

**编码/解码**: 信息从一种形式或格式转换为另一种形式的过程

## 编码集/字符集
- 字符集: 一个文字系统所支持的所有抽象字符的集合
    - 单纯的字符集 实际上是不存在的, 每个抽象字符开发时必定有id, 如此, 字符集在开发时必定有相应id集合, 此id集合即为编码集. 比如 Unicode字符集和UCS编码集
    - 设想如果字符集开发没有_id, 如何将其录入系统? 如何与别人描述指定的抽象字符 等等问题. 所以, 字符集必有标准编码集
- 编码集： 将字符集转换为计算机可接受的形式的信息
    - 通常用来网络传输和存储数据, 采用编码后的字符集可以节省空间
- UCS-2/4 和 UTF-8/GBK
    - 在存储/网络传输时, 更适合使用 UTF-8/GBK 等编码存储多种语言的字符串, 更节省空间. UTF-8/GBK 对 Unicode字符集规定的二进制代码(即UCS编码值) 进行压缩(不同字符使用的频率不同, 原理类似哈夫曼最优编码)
    - 在编程语言内部, 更适合使用 UCS2/4 存储多种语言的字符串, 不同环境高度统一
- encode: 通常是将 **特殊字符** 通过某种编码集 **编码** 为 **Str类型**
    - 此处指的特殊字符有汉字, 还有其他少数语言的字体
    - `'中国'.encode()=="\xd6\xd0\xb9\xfa"`
- decode: 通常是将 **Str类型** 的值通过某种编码集 **解码** 为 **特殊字符** 的值
    - `"\xd6\xd0\xb9\xfa".decode()=='中国'`
- 举个栗子
    - unicode是字符集, UCS-2/4 是编码集
    - ascii既是编码集, 也是字符集
    - utf-8则是编码集

## 编程语言中的编码
- 接下来所言的 unicode类型 是指 UCS-2/4 编码存储的字符串. 这个世界上不存在 unicode编码集...
- Python2 字符串分为 unicde类型 和 str类型
    - unicode类型 是为了处理多种语言的文本而引入的(Python设计之初, unicode规范并没有建立)
- Python2 中, Unicode类型专门处理多种语言
    - 未编码的抽象字符只能用unicode类型存储, 字符串只能存储已编码的抽象字符和ASCII码
    - decode方法默认生成 unicode 类型
    - encode方法也可直接编码 unicode 类型为其他编码类型(gbk等)的字符串
    - unicode也可以通过编码/解码为Str类型
- Python3 中, 没有了unicode类型, 修改str定义为 "Unicode类型的字符串"
- Java/C# 中, 与Python3相同, 内部采用的都是 Unicode 16(UCS2) 存储字符串
- 所以, Python+win 是编码的大坑, 没有任何问题...

### Python2 编码使用问题
- unicode : `u'\u4e2d\u56fd'`
    - 直接 print unicode 编码格式的字符串, shell会根据操作系统活动页编码值对字符串进行编码
- print `[u'\u4e2d\u56fd]` 时, 不会直接对数组进行编码
- 使用 str.replace() 替换时, 中文要加编码. 正则时同理
    - `str.replace(u"中国".encode("utf-8"),"")`
- unicode封装的gbk: `u'\xd6\xd0\xb9\xfa'`
    - 在Scrapy抓取时, 偶尔碰到(神坑)
    - `u'\xd6\xd0\xb9\xfa'` 是用unicode类型封装的gbk编码, 需要先处理unicode类型, 然后可得到gbk编码的字符串
    - unicode类型不是字符串类型. 所以unicode类型转字符串使用 encode 方法
        ````
        import codecs
        item = u'\xd6\xd0\xb9\xfa'
        # 意如其名
        item = codecs.unicode_escape_encode(item)
        # item: ('\\xd6\\xd0\\xb9\\xfa', 4) (tuple元组类型)
        # 使用下标取字符串, 然后解码转义字符
        item = codecs.escape_decode(item[0])
        # item: ('\xd6\xd0\xb9\xfa', 16)
        ````

## ETC
- [进阶_编码判断程序](/Lib/IdentifyEncod.py)
- Linux_shell 中文默认使用utf-8编码, 这也是绝大多数情况下中文使用的编码(比较有国际范)
    ````
    >> locale
    LANG=en_US.UTF-8
    LANGUAGE=
    LC_CTYPE="en_US.UTF-8"
    LC_NUMERIC="en_US.UTF-8"
    LC_TIME="en_US.UTF-8"
    LC_COLLATE="en_US.UTF-8"
    LC_MONETARY="en_US.UTF-8"
    LC_MESSAGES="en_US.UTF-8"
    LC_PAPER="en_US.UTF-8"
    LC_NAME="en_US.UTF-8"
    LC_ADDRESS="en_US.UTF-8"
    LC_TELEPHONE="en_US.UTF-8"
    LC_MEASUREMENT="en_US.UTF-8"
    LC_IDENTIFICATION="en_US.UTF-8"
    LC_ALL=
    ````
- Win_CMD 默认使用gbk
    ````
    >> chcp
    活动代码页: 936
    ````
