# Context

在很多场景中, 上下文都是很重要的一部分. 我们在编写服务时, 都应该有 上下文 这个参数, 以便服务之间传递数据.

举例如下: 假设我们有 商品表(product), 规格表(sku) 和 文件表, 理所当然应拆分为三个服务. 删除商品逻辑如下: 当删除商品时, 我们需要同时删除属于该商品的所有规格, 然后删除商品所有的描述文件, 最后删除商品. 那么问题来了:  当删除规格失败时, 如何回滚对文件表的操作? 或者说相反时如何处理? 通常解决方案如下
1. 在 goods 表中直接访问 sku/file 的表: 错, 拆分就是为了解耦, 这么做增加了耦合, 也会引入大量重复代码.
2. 采用分布式XA事务: 消耗太大.
3. 为每个函数添加 `tx *database.DB` 参数: 不够优雅
4. 添加 context 作为上下文, 在 context 中添加 tx: 我认为最好的办法

接下来我们讲讲 context.

context 是线程安全的
context 是多级继承的

先主要说下 context 如何携带数据. 

context 源码中, Value 是一个函数: `context.Value(interface{})interface{]}`

context传入数据的方法: `ctx := context.WithValue(context.Background(),"key","value")`
context取出数据的方法: `value := context.Value("key")`, 可以看到是通过 Value 函数直接取出

那么问题来了, context 能否存储多个key呢? 又是如何实现的呢? 如我们执行如下代码
```Go
ctx := context.WithValue(context.Background(), "test1", "test1")
ctx = context.WithValue(ctx, "test2", "test2")
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
