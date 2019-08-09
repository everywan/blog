# Context

Context 提出时最核心的功能是在 goroutine 之间传递 cancel 信号, 用于解决 goroutine 无法从外部关闭的问题.

下面从两个方面介绍 Context:
1. 在 goroutine 中传递 cancel 信号
2. 作为上下文

## 是什么
context 是线程安全的
context 是多级继承的

## 如何携带数据
先说下 context 如何携带数据. 

context 源码中, Value 是一个函数: `context.Value(interface{})interface{]}`

context传入数据的方法: `ctx := context.WithValue(context.Background(),"key","value")`
context取出数据的方法: `value := context.Value("key")`, 可以看到是通过 Value 函数直接取出

那么问题来了, context 能否存储多个key呢? 又是如何实现的呢? 如我们执行如下代码
```Go
ctx := context.WithValue(context.Background(), "test1", "test1")
fmt.Printf("%p\n", ctx)
ctx = context.WithValue(ctx, "test2", "test2")
fmt.Printf("%p\n", ctx)
ctx = context.WithValue(ctx, "test2", "test3")
```

翻阅源码, 可知 `WithValue()` 返回的结构体 valueCtx, 源码如下
```Go
type valueCtx struct {
	Context
	key, val interface{}
}
// 取值
func (c *valueCtx) Value(key interface{}) interface{} {
	if c.key == key {
		return c.val
	}
	return c.Context.Value(key)
}
// 附赠 WithValue 的源码
func WithValue(parent Context, key, val interface{}) Context {
	if key == nil {
		panic("nil key")
	}
	if !reflect.TypeOf(key).Comparable() {
		panic("key is not comparable")
	}
	return &valueCtx{parent, key, val}
}
```

由 valueCtx 的结构可以得出如下结论, 每次使用 WithValue 时, 就会生成一个新的 valueCtx, 然后将 key val 导入到新的valueCtx中. 由于Go语言的特性, valueCtx 可以直接调用Context内的值, 也就是可以直接获取上一个context的key-val, 就像该key-val直接属于context内一样. (注意, WithValue 返回的context不能调用 valueCtx 的字段和扩展方法, 因为 WithValue 返回的是 Context, 只能调用父类 Context 的方法)

再多说一笔无关的, 输出地址时要用 `fmt.Printf("%p\n", ctx)` 而不是 `fmt.Println(&ctx)`, 后者输出的是指向ctx指针的指针的地址, 前者才是 ctx指针的地址

## 如何实现线程安全

## cancel信号
父goroutine通过调用 cancel 方法取消子goroutine

参考
```Go
// 带cancel返回值的Context，一旦cancel被调用，即取消该创建的context
func WithCancel(parent Context) (ctx Context, cancel CancelFunc)

// 带有效期cancel返回值的Context，即必须到达指定时间点调用的cancel方法才会被执行
func WithDeadline(parent Context, deadline time.Time) (Context, CancelFunc)

// 带超时时间cancel返回值的Context，类似Deadline，前者是时间点，后者为时间间隔
// 相当于WithDeadline(parent, time.Now().Add(timeout)).
func WithTimeout(parent Context, timeout time.Duration) (Context, CancelFunc)
```

需要 父/子 goroutine 写代码判断 `ctx.Done()` 信号(通过 chanel), 通过select等方式, 如果收到则终止该 goroutine

demo参考:
```Go
func someHandler() {
    // 创建继承Background的子节点Context
    ctx, cancel := context.WithCancel(context.Background())
    go doSth(ctx)

    //模拟程序运行 - Sleep 5秒
    time.Sleep(5 * time.Second)
    cancel()
}

//每1秒work一下，同时会判断ctx是否被取消，如果是就退出
func doSth(ctx context.Context) {
    var i = 1
    for {
        time.Sleep(1 * time.Second)
        select {
        case <-ctx.Done():
            fmt.Println("done")
            return
        default:
            fmt.Printf("work %d seconds: \n", i)
        }
        i++
    }
}

func main() {
    fmt.Println("start...")
    someHandler()
    fmt.Println("end.")
}
```

## 作为上下文
在很多场景中, 上下文都是很重要的一部分. 我们在编写服务时, 都应该有 上下文 这个参数, 以便服务之间传递数据.

举例如下: 假设我们有 商品表(product), 规格表(sku) 和 文件表, 理所当然应拆分为三个服务. 删除商品逻辑如下: 当删除商品时, 我们需要同时删除属于该商品的所有规格, 然后删除商品所有的描述文件, 最后删除商品. 那么问题来了:  当删除规格失败时, 如何回滚对文件表的操作? 或者说相反时如何处理? 通常解决方案如下
1. 在 goods 表中直接访问 sku/file 的表: 错, 拆分就是为了解耦, 这么做增加了耦合, 也会引入大量重复代码.
2. 采用分布式XA事务: 消耗太大.
3. 为每个函数添加 `tx *database.DB` 参数: 不够优雅
4. 添加 context 作为上下文, 在 context 中添加 tx: 我认为最好的办法

接下来我们讲讲 context.

## 坏处
### Context污染
为了实现 goroutine 从外部关闭, 确实会造成所有的 goroutine 都需要将 context 作为地一个传入的参数, 否则无法接收 `ctx.Done()` 信号.

我不确定作者和讨论的点是不是如我所言, 所以附链接如下, 看官自行判断吧.
- [Golang Context 是好的设计吗？](https://segmentfault.com/a/1190000017394302)
- [context-should-go-away-go2](https://faiface.github.io/post/context-should-go-away-go2/)
- [google-group 讨论](https://groups.google.com/forum/#!searchin/golang-nuts/transaction%7Csort:date/golang-nuts/eEDlXAVW9vU/IChp34xpCQAJ)

### 实现不完全
context 用于解决 goroutine 之间传递 cancel 信号的问题, 但是无法在 goroutine 之间传递信息.

