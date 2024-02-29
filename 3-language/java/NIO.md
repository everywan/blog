# NIO
> [IBM介绍文档](https://www.ibm.com/developerworks/cn/education/java/j-nio/j-nio.html)   
> [Java API](http://tool.oschina.net/apidocs/apidoc?api=jdk-zh), `java.nio`部分
NIO是为了弥补传统I/O工作模式的不足而研发的. 

NIO的工具包提出了基于Selector(选择器),Buffer(缓冲区),Channel(通道)的新模式; Selector(选择器),可选择的Channel(通道)和SelectionKey(选择键)配合起来使用, 可以实现并发的非阻塞型I/O能力.

## 组件
1. Buffer 是一个对象(数组), 它包含一些要写入或者刚读出的数据
    - 面向流的 I/O 中, 数据直接写入或者数据直接读到 Stream 对象中, 在NIO中,按buffer读取
    - Buffer 与 chanel 交互, 读写数据. 取代了之前从流中读取数据的模式
2. Channel: 一个对象, 通过channel读取和写入数据. 数据从通道写入缓冲区, 或者从缓冲区写入通道
    - 通道是双向的
    - 可以结合 go 的 chan 理解, 但是 go-chan 可以直接操作,这是不同的一点
3. selector
### Buffer
1. 主要由 状态变量 访问方法 组成, 有 ByteBuffer, CharBuffer, ShortBuffer, IntBuffer, DoubleBuffer 等类型, 状态变量和访问方法都类似.
2. 状态变量: 使用 position/limit/capacity 变量记录缓冲区任意时刻的状态
    - position: 读取位置
    - limit: 读取的长度, 即要读取多少个字节
    - capacity: 缓冲区的最大容量, 即数组的长度. `len+pos<=cap`
    - 参考 go/python 里的切片: `s :=make([]int,len,cap)` 理解buffer的结构. 但是不同的是, NIO的buffer可以通过`flip()`函数调整pos和limit, 而后将数据写入通道. 即切片只是一个结构, 而buffer是一整个逻辑
3. 访问方法
    - `buffer.flip()`: 设置 limit=pos, pos=0; 即调用 `flip()` 后, 新的 `buffer[pos,limit]` 就是之前所写入的内容
    - `ByteBuffer.get()`: 从buffer获取数据. ABC 是相对于pos和limit读取的, 即 从当前pos开始, pos会在读取后增加. D忽略pos/limit, 也不修改pos/limit值
        - A `byte get();`: 获取单个字节
        - B `ByteBuffer get(byte dst[]);`: 将一组字节读到一个数组中
        - C `ByteBuffer get(byte dst[], int offset, int length);`: 将一组字节读到一个数组中
        - D `byte get(int index);`: 从缓冲区特定位置获取一个字节
    - `ByteBuffer.put()`: 写入buffer数据.
        - `ByteBuffer put( byte b );`
        - `ByteBuffer put( byte src[] );`
        - `ByteBuffer put( byte src[], int offset, int length );`
        - `ByteBuffer put( ByteBuffer src );`
        - `ByteBuffer put( int index, byte b );`
    - `ByteBuffer.allocate(1024);`: 创建&分配缓冲区
    - `ByteBuffer.wrap(new byte[1024]);`: 将数组包装为缓冲区
    - `buffer.slice();`: 获取当前 pos到limit 之间的切片, 返回类型是 ByteBuffer.
        - 该切片和原缓冲区指向同一个底层数组.
    - `ByteBuffer.asReadOnlyBuffer()`: 将缓冲区变成 只读缓冲区
4. 分散/聚集: 将数据读取到一个缓冲区数组, 或者将一个缓冲区数组写入到chan中
5. 文件锁定: 排它锁, 共享锁. 限制多用户读写使用

### Selector
1. Selector: 用于异步IO
2. 代码示例
```Java
// 创建一个 Selector 对象
Selector selector = Selector.open();

// 创建一个 channel
ServerSocketChannel ssc = ServerSocketChannel.open();
ssc.configureBlocking(false);

// 监听一个IP地址
ServerSocket ss = ssc.socket();
InetSocketAddress address = new InetSocketAddress(ports[i]);
ss.bind( address );

// 将channel注册到selector. channel.register(selector,要监听的事件)
// SelectionKey.OP_ACCEPT: 新的连接建立时触发该事件. int型值
// 返回值 SelectionKey: 标示在 指定selector 中 该通道注册的 key. 当selector通知某个传入事件时, 是通过 SelectionKey 查找的, 并且 SelectionKey 还可用于取消注册.
SelectionKey key = ssc.register(selector, SelectionKey.OP_ACCEPT);

// selector.select(): 阻塞线程, 直到至少一个已注册的事件发生; 返回值是 返回发生的事件的数量. (类似与go语言里的select,都会阻塞当前程序的执行. 不过go语言里的select用法不同, 并且若多个发生, go是随机选一个case去执行,然后退出)
int num = selector.select();

Set selectedKeys = selector.selectedKeys();
Iterator it = selectedKeys.iterator();
while (it.hasNext()) {
    SelectionKey key = (SelectionKey)it.next();
    
    // SelectionKey.readyOps(): 获取发生事件的类型. SelectionKey.OPS.. 值都是int型的, 所以通过 & 可以检查时间发生的类型
    // key.isAcceptable() 也可以检查 此键的通道是否已准备好接受新的套接字连接
    if( (key.readyOps() & SelectionKey.OP_ACCEPT) == SelectionKey.OP_ACCEPT) {
        // Accept the new connection
    }
    
    // 移除SelectionKey. 如果不删除处理过的键, 那么它仍然会在主集合中以一个激活的键出现, 这会导致程序尝试再次处理它
    it.remove();
}
// 删除通道 等等操作
```
#### 编码处理
1. 文件/数据处理 一定要考虑编码的问题.
```Java
// 创建一个字符集的实例
Charset latin1 = Charset.forName("ISO-8859-1");

// 创建该字符集的 解码器 和 编码器
CharsetDecoder decoder = latin1.newDecoder();
CharsetEncoder encoder = latin1.newEncoder();

// 解码读取到的字符, 然后交给程序处理.
CharBuffer cb = decoder.decode(inputData);
// 编码需要写入缓冲区的数据
ByteBuffer outputData = encoder.encode(cb2);
```

### demo
```Java
// 开辟缓冲区
ByteBuffer buffer = ByteBuffer.allocate( 1024 );
```

### 问题
1. 如果不以流的方式读写, 那么每次IO都需要重新打开文件么? 或者如何记录读写位置的?
    - NIO 读取文件的流程: *从 FileInputStream 获取 Channel; 创建 Buffer; 将数据从 Channel 读到 Buffer 中* 也就是说, 根本上还是以流的方式读写的, 只不过对于程序员而言是面向缓冲区读写而不是面向流. 类似于加了中间件

## 原理
