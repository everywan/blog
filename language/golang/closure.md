# 闭包
闭包与作用域相关.

匿名函数/lambda函数也是闭包的一种, 此处不再描述.

使用闭包函数需要编程语言允许函数作为变量, 否则无法传递函数到其他作用域, 所以函数绑定作用域也就没有意义.

闭包函数将变量的作用域与函数绑定, 从而可以访问原作用域的变量.

## 闭包函数的形式
主要有如下两种方式生成闭包, 具体如何选择看业务场景, 也可以混用.
```Go
type closureFunc func() string

// 通过函数生成闭包函数
func implement1(name string) closureFunc {
	return func() string {
		return fmt.Sprintf("implement 1: name %s", name)
	}
}

// 将结构体扩展函数作为闭包函数.
type closureDemo struct{
  Msg string
}

func (c *closureDemo) implement2() string {
  return c.Msg
}
```

## 闭包函数的妙用

夹带私货.

假设现在有一个输出服务, 每个业务都需要在输出之前做特殊处理, 经过讨论, 决定添加中间件以实现功能.
一般而言, 输出服务在输出前依次调用各个中间件以实现特殊处理(参考 web 框架中的中间件, 如 echo/iris/gin 等)

```Go
package print

func main(){
  Print(func()string{return "test"})
}

type PrintHandleFunc func() string

// 输出服务, 可以输出到 es, hdfs 等, 此处为了简单只是 stdout
func Print(f printHandleFunc) {
	fmt.Println(f())
}

package user
// 在其他包内调用 print 包统一输出, 夹带私货的同时符合print包的要求.
func main(){
  print.Print(UserPrint("everywan"))
}

func UserPrint(name string) print.PrintHandleFunc {
	return func() string {
		return fmt.Sprintf("user %s login", name)
	}
}

package order
func orderPrint(orderID, msg string) print.PrintHandleFunc {
	return func() string {
		return fmt.Sprintf("order print: %s,%s", orderID, msg)
	}
}
```

## 缺点
闭包函数会使变量一直不能释放, 使用不当会造成内存泄漏.
