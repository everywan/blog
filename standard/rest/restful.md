# RESTful架构
> 摘抄自[理解RESTful架构_阮一峰](http://www.ruanyifeng.com/blog/2011/09/restful.html?bsh_bid=1717507328)

## 由来
REST这个词, 是Roy Thomas Fielding 在他2000年的博士论文中提出的.

Fielding是一个非常重要的人, 他是HTTP协议(1.0版和1.1版)的主要设计者,Apache服务器软件的作者之一,Apache基金会的第一任主席. 所以, 他的这篇论文一经发表, 就引起了关注, 并且立即对互联网开发产生了深远的影响. 

他这样介绍论文的写作目的：
> 本文研究计算机科学两大前沿----软件和网络----的交叉点. 长期以来, 软件研究主要关注软件设计的分类,设计方法的演化, 很少客观地评估不同的设计选择对系统行为的影响. 而相反地, 网络研究主要关注系统之间通信行为的细节,如何改进特定通信机制的表现, 常常忽视了一个事实, 那就是改变应用程序的互动风格比改变互动协议, 对整体表现有更大的影响. 我这篇文章的写作目的, 就是想在符合架构原理的前提下, 理解和评估以网络为基础的应用软件的架构设计, 得到一个功能强,性能好,适宜通信的架构. 
> 
> (This dissertation explores a junction on the frontiers of two research disciplines in computer science: software and networking. Software research has long been concerned with the categorization of software designs and the development of design methodologies, but has rarely been able to objectively evaluate the impact of various design choices on system behavior. Networking research, in contrast, is focused on the details of generic communication behavior between systems and improving the performance of particular communication techniques, often ignoring the fact that changing the interaction style of an application can have more impact on performance than the communication protocols used for that interaction. My work is motivated by the desire to understand and evaluate the architectural design of network-based application software through principled use of architectural constraints, thereby obtaining the functional, performance, and social properties desired of an architecture. )

Fielding将他对互联网软件的架构原则, 定名为REST, 即Representational State Transfer的缩写. 我(阮一峰)对这个词组的翻译是"表现层状态转化". 

如果一个架构符合REST原则, 就称它为RESTful架构. 

## 理解
### 资源
REST的名称"表现层状态转化"中, 省略了主语. "表现层"其实指的是"资源"(Resources)的"表现层". 

所谓"资源", 就是网络上的一个实体, 或者说是网络上的一个具体信息. 它可以是一段文本,一张图片,一首歌曲,一种服务, 总之就是一个具体的实在. 你可以用一个URI(统一资源定位符)指向它, 每种资源对应一个特定的URI. 要获取这个资源, 访问它的URI就可以, 因此URI就成了每一个资源的地址或独一无二的识别符. 

所谓"上网", 就是与互联网上一系列的"资源"互动, 调用它的URI. 

### 表现层
"资源"是一种信息实体, 它可以有多种外在表现形式. 我们把"资源"具体呈现出来的形式, 叫做它的"表现层"(Representation). 

比如, 文本可以用txt格式表现, 也可以用HTML格式,XML格式,JSON格式表现, 甚至可以采用二进制格式；图片可以用JPG格式表现, 也可以用PNG格式表现. 

URI只代表资源的实体, 不代表它的形式. 严格地说, 有些网址最后的".html"后缀名是不必要的, 因为这个后缀名表示格式, 属于"表现层"范畴, 而URI应该只代表"资源"的位置. 它的具体表现形式, 应该在HTTP请求的头信息中用Accept和Content-Type字段指定, 这两个字段才是对"表现层"的描述. 

### 状态转化
访问一个网站, 就代表了客户端和服务器的一个互动过程. 在这个过程中, 势必涉及到数据和状态的变化. 

互联网通信协议HTTP协议, 是一个无状态协议. 这意味着, 所有的状态都保存在服务器端. 因此, 如果客户端想要操作服务器, 必须通过某种手段, 让服务器端发生"状态转化"(State Transfer). 而这种转化是建立在表现层之上的, 所以就是"表现层状态转化". 

客户端用到的手段, 只能是HTTP协议. 具体来说, 就是HTTP协议里面, 四个表示操作方式的动词：GET,POST,PUT,DELETE. 它们分别对应四种基本操作：GET用来获取资源, POST用来新建资源(也可以用于更新资源), PUT用来更新资源, DELETE用来删除资源. 

注意, GET/POST/PUT/DELETE 只是约定/规范, 并非强制执行, 所以有以下问题
1. 部分编程语言没有 PUT/DELETE 方法, 只是用 POST 方法模拟实现 PUT/DELETE 的功能
2. 部分浏览器不支持发送 PUT/DELETE 方法
3. 部分服务器不能正确理解 PUT/DELETE 请求(因为服务端没有实现)

### 综述
综合上面的解释, 我们总结一下什么是RESTful架构：
1. 每一个URI代表一种资源；
2. 客户端和服务器之间, 传递这种资源的某种表现层；
3. 客户端通过四个HTTP动词, 对服务器端资源进行操作, 实现"表现层状态转化". 

## 误区/实例
1. URI包含动词: 因为"资源"表示一种实体, 所以应该是名词, URI不应该有动词, 动词应该放在HTTP协议中. 
    - URI是 `/posts/show/1`, 其中show是动词, 这个URI就设计错了, 正确的写法应该是 `/posts/1`, 然后用GET方法表示show. 
    - 如果某些动作是HTTP动词表示不了的, 就应该把动作做成一种资源
        - 错误url: `POST /accounts/1/transfer/500/to/2`
        ````
        正确URL
        POST /transaction HTTP/1.1
        Host: 127.0.0.1
        
        from=1&to=2&amount=500.00
        ````
2. URI包含版本号. 版本号应该添加在 HTTP Header 中的 Accept字段 中: `Accept: vnd.example-com.foo+json; version=1.0`

## 问题
1. 静态资源访问需要后缀, 如 .html文件, .png文件

## 扩展
### 理查德森模型
> 参考[理解RESTful架构_阮一峰](http://www.ruanyifeng.com/blog/2011/09/restful.html?bsh_bid=1717507328) 后的评论内容
> 
> [理查德森模型](http://martinfowler.com/articles/richardsonMaturityModel.html)

REST架构的级别
- Level 0 POX (这个就不算REST了)
- Level 1 Resources
- Level 2 Http verbs
- Level 3 Hypermedia Controls

#### Level 0 POX
- 这类应用只有一个URI上的上帝接口, 根据交换的XML内容操作所有的资源. 往往导致上帝接口越来越复杂, 越来越难以维护.
#### Level 1 Resources
- 即静态资源服务器. 解决了 Level 0 的问题,但是自身耦合度也很高
#### Level 2 Http verbs
1. 即 使用 HTTP方法(GET/POST..) 操作(增删改查)各种资源.
2. 好处
    - 符合 HTTP 规范
    - 缓存: 按照HTTP协议, GET操作是安全的, 幂等(Idempotent)的. 即任意多次对同一资源的GET操作, 都不会导致资源的状态变化. 所以GET的结果是可以安全的cache. 所有http提供的cache facilities 都可以被利用起来, 大幅度提高应用程序的性能. 甚至你仅仅只在response里加上cache directives就可以免费获得网络上各级的缓存服务器, 代理服务器, 以及用户客户端的缓存支持. 互联网上几乎所有的应用你都可以粗略统计得到Get VS Non-Get的请求比例约为 4:1. 如果你能为GET操作加上缓存, 那将极大提供你的程序的性能.
    - Robust(鲁棒性): 在HTTP常用的几个动词里, HEAD, GET, PUT, DELETE 是安全的,幂等的. 因为对同一资源的任意多次请求, 永远代表同一个语义. 所以任何时候客户端发出去这些动词的时候, 如果服务器没有响应, 或者返回错误代码, 客户端都可以非常安全的再次执行同一操作而不用担心重复操作带来不同的语义及最终结果. POST, PATCH操作就不是安全的, 因为当客户端向服务器端发出请求后, 服务器没有响应或者返回错误代码, 客户端是不能安全的重复操作的. 一定只能重新与服务器确认现在的资源状态才能决定下一步的操作.
        - 鲁棒性: 即健壮/强壮, 即控制系统在一定(结构, 大小)的参数摄动下, 维持其它某些性能的特性
#### Level 3 Hypermedia Controls
> RESTful的架构本意是"在符合架构原理的前提下, 理解和评估以网络为基础的应用软件的架构设计, 得到一个功能强,性能好,适宜通信的架构. "
这个世界上规模最大的, 耦合度最低, 最稳定的, 性能最好的分布式网络应用是什么? 就是WEB本身.
规模,稳定,性能都不用说了. 为什么说耦合度低呢? 想一想每个人上网的经历, 你几乎不需要任何培训就可以上一个新的网络购物平台挑选商品,用信用卡付款,邮寄到自己家里.
把网站的程序想像成一个状态机, 用户在一系列状态转换中完成自己的目标. 这中间的每一步, 应用程序都告诉你当前的状态和可能的下一步操作, 最终引导用户从挑选商品,挑选更多商品,到支付页面,到输入信用卡信息,最终完成付费,到达状态机的终点.
>
> 这种service discoverablility和self-documenting就是level 3想解决的问题
>
> 在这里面, 告诉用户当前状态以及各种下一步操作的东西, 比如链接, 按钮等等, 就是Hypermedia Controls. Hypermedia Controls 就是这个状态机的引擎.
>
> Level 3的REST架构就是希望能够统一这一类的Hypermedia Controls, 赋予他们标准的, 高度可扩展的标准语义及表现形式, 使得甚至无人工干预的机器与机器间的通用交互协议边的可能. 比如你可以告诉一个通用的购物客户端, "给我买个最便宜的xbox", 客户端自动连上google进行搜索, 自动在前10个购物网站进行搜索, 进行价格排序, 然后自动挑选最便宜的网站, 进行一系列操作最终完成用信用卡付费, 填写个人收件地址然后邮寄.
> 
> 这些都依赖于Hypermedia Controls带来的这种service discoverablility和self-documenting
> 
> 更多的关于REST的细节及其应用和实现, 请参考Rest in Practice. 非常非常棒的一本书, 把REST讲的非常透彻.
