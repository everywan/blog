# 开发规范
参考书籍目录
1. [阿里巴巴Java开发规范](https://yq.aliyun.com/articles/69327)

## 代码
异常
1. 抛出/捕获异常的消耗远大于条件判断, 所以能用条件判断的就不要用异常处理. 而且异常是用来解决意外情况的, 所以不要用异常做条件控制, 流程控制.
2. 不要 try-cache 大段的代码, 只捕获特定的异常, 对于无法处理的异常要抛出给调用者, 而不是不处理抛弃, 最外层的业务使用者必须处理异常.

规范
1. 方法的返回值可以为 null, 不强制返回空集合, 或者空对象等, 必须添加注释充分, 说明什么情况下会返回 null 值.
    - NPE问题: NullPointerException, 空指针异常, 当应用程序试图在需要对象的地方使用 null 时，抛出该异常.
    - 尽量不返回null, 而是返回相应的零值. 防止 NPE, 是程序员的基本修养. (go语言默认值)
2. 门面模式: 外部与一个子系统的通信必须通过一个统一的外观对象进行, 为子系统的一组接口提供一个一致的界面
3. 区间左闭右开原则, 即包含左边界值, 不包含右边界值.
4. 

命名规范
1. 文件名使用下划线, url根据需求决定使用连字符还是下划线
    - 下划线: 下划线连接的单词会被认为是一个单词, 而文件名是一个标识符, 整体是一个关键词. 而且, 连字符命名的源文件和目录不能被 `java/python import`. 所以 变量名, 文件名 使用下划线.
    - 连字符: 连字符连接的单词, 会被认为是多个单词, 搜索引擎会将连字符的单词拆开. 所以如果有SEO的需要, 建议url中使用连字符.
2. 蛇形命名(snake): 单词间全部使用下划线隔开
3. 驼峰命名...


性能
1. 对 trace/debug/info 级别的日志输出, 必须使用条件输出形式或者使用占位符的方式. 因为直接使用字符串拼接时, 日志不会打印, 但是会执行字符串拼接操作, 浪费性能
2. 类型定义尽量符合业务需求, 比如年龄使用 unsigned 而不用int.

hostname: 在hostname中, 建议使用 连字符 而非 下划线 和 点.
1. 在 [RFC952](https://tools.ietf.org/html/rfc952) 标准中, 不允许 hostname 包含下划线. 由此导致在 `java.net.URI` 等包中, 如果 hostname 中含有下划线, 就会抛出异常.
  - ` A "name" (Net, Host, Gateway, or Domain name) is a text string up to 24 characters drawn from the alphabet (A-Z), digits (0-9), minus sign (-), and period (.).`
2. 在 [RFC2181-sec11](https://tools.ietf.org/html/rfc2181#section-11) 中指出, DNS 不会对 hostname 做任何限制. 也就是说, DNS 允许下划线.
  - `Those restrictions aside, any binary string whatever can be used as the label of any resource record.  Similarly, any binary string can serve as the value of any record that includes a domain name as some or all of its value`
  - `In particular, DNS servers must not refuse to serve a zone because it contains labels that might not be acceptable to some DNS client programs`
3. 个人理解: 在原来的标准中, 确实限制 hostname 中不能有下划线, 在后续标准中, 不在对此做限制(标准是体现在真实的网络中, 是否存在主机不支持此种格式(个人看法)). 举例如在 Java 中, `java.net.URI` 遵循 RFC952, 所以不能包含下划线. 但在 `java.net.URL` 中则无此限制. 至于为什么不统一, 应该是为了保证已存程序的稳定运行吧.
4. 参考文章
  - [Can (domain name) subdomains have an underscore “_” in it?](https://stackoverflow.com/questions/2180465/can-domain-name-subdomains-have-an-underscore-in-it)
  - [JDK(java.net.URL) 中的 一个 "bug"](https://www.tanglei.name/blog/conflicts-between-java-net-url-and-java-net-uri-when-dealing-with-hostname-contains-underscore.html)

## 数据库
数据库
1. 单表行数超过 500 万行或者单表容量超过 2GB, 才推荐进行分库分表
2. 最左原则: Mysql检索数据时, 会从联合索引的最左边开始匹配.

sql
1. 不要使用 count(列名) 或 count(常量)来替代 count(*). count(*)是 SQL92 定义的标准统计行数的语法, 跟数据库无关, 跟 NULL/NOT-NULL 无关.
    - count(*) 统计 值为null 的行, count(常量) 不统计.

根据业务类型区分讨论
1. 不得使用外键与级联, 一切外键概念必须在应用层解决(即在程序层解决)
    - 互联网行业应用不推荐使用外键: 用户量大, 并发度高, 为此数据库服务器很容易成为性能瓶颈, 尤其受IO能力限制, 且不能轻易地水平扩展; 若是把数据一致性的控制放到事务中, 也即让应用服务器承担此部分的压力, 而引用服务器一般都是可以做到轻松地水平的伸缩;
    - 传统行业用户量固定, 并发一般, 可以使用外键/级联更新.
