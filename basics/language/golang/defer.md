- [defer](#defer)
  - [作用域](#%E4%BD%9C%E7%94%A8%E5%9F%9F)
  - [执行流程](#%E6%89%A7%E8%A1%8C%E6%B5%81%E7%A8%8B)
  - [参数生成](#%E5%8F%82%E6%95%B0%E7%94%9F%E6%88%90)
  - [示例](#%E7%A4%BA%E4%BE%8B)
    - [defer与panic](#defer%E4%B8%8Epanic)
    - [defer与return](#defer%E4%B8%8Ereturn)
    - [defer参数生成](#defer%E5%8F%82%E6%95%B0%E7%94%9F%E6%88%90)
  - [TODO](#todo)

# defer
defer: 参数是 **函数**, defer关键字 **延迟** 函数的执行, 且defer延迟执行的函数 **在任何情况下都被执行.**
1. 多个defer函数时, defer 延迟执行的函数 依次入栈. 然后上层函数返回后依次pop执行
2. defer 函数只能使用当前函数中在该defer之前声明的变量.

## 作用域
defer 延迟执行的函数的作用域为:
1. 所有在该 defer 语句之前声明的变量.
2. 该函数内声明的变量与传入的变量.

## 执行流程
要了解defer的执行流程, 首先要了解下在 Go 中 return 执行的流程

在Go中 return 的执行流程
1. 在 Go 中, return 返回值分为两种: 匿名返回值,具名返回值. 具名返回值在函数声明时被声明, 匿名返回值在return执行时声明. 需要注意的是, 匿名返回值是新声明的变量, 与函数内声明的变量不同.
2. 所以, Go 中 return 执行顺序为: 返回值赋值 => 返回值返回.

正常情况下, defer 函数在 return 执行时被执行, 流程为: 返回值赋值 => defer 函数执行 => 返回值.
当程序发生异常时, 程序在 panic 抛出异常前执行, 所以可以使用defer捕获函数执行时的异常.

所以, defer 会延迟函数的执行, 并且在任何情况下defer都会被执行. 
对于多个defer， 会按照入栈顺序依次执行.

思考一个问题: defer 是否可以更改函数返回值?
1. defer 在对返回值赋值后执行. 当返回值为匿名返回值时, defer 访问的函数内的变量与返回值不是同一个变量, 所以无法更改返回值. 但是, 当返回值是具名返回值时, defer 可以访问到返回值, 也可以更改返回值
   1. 示例参见 [defer与return](#defer与return) test2/test4 (具名/匿名返回值)
2. 当返回值为指针时, 如果defer可以更改指针指向的内容(当所使用的变量在defer之前声明), 那么defer也算是在一定程度上更改了返回值. 这是一种比较hacker的方法.
   1. 示例参见 [defer与return](#defer与return) test3

示例参见
1. [defer与panic](#defer与panic)
2. [defer与return](#defer与return)

## 参数生成
之前讲到, defer关键字的参数是函数, 与闭包等匿名函数不同的是, 如果 defer 参数的参数也是函数的话, 则程序会立即执行参数中的函数, 将其转化为变量/常量, 然后将其放入 defer 专用的执行栈中等待执行.

也就是说, defer 参数的参数中, 不允许使用函数.

示例参见
1. [defer参数生成](defer参数生成)

## 示例
### defer与panic
猜测如下函数输出
```Go
func defer_call() {
    defer func() { fmt.Println("打印前") }()
    defer func() { fmt.Println("打印中") }()
    defer func() { fmt.Println("打印后") }()
    panic("触发异常")
}
```

### defer与return
猜测那些函数的defer可以更改返回值
```Go
func main() {
    fmt.Println(test2())
    fmt.Println(*test3())
    fmt.Println(test4())
}
func test2() (a int) {
    defer func() { a = a + 1 }()
    return a + 1
}
func test3() *int {
    a := 0
    defer func() { a = a + 1 }()
    a = a + 1
    return &a
}
func test4() int {
    a := 0
    defer func() { a = a + 1 }()
    return a + 1
}
```

### defer参数生成
猜测如下函数输出
```Go
func calc(index string, a, b int) int {
    ret := a + b
    fmt.Println(index, a, b, ret)
    return ret
}
func main() {
    a := 1
    b := 2
    defer calc("1", a, calc("10", a, b))
    a = 0
    defer calc("2", a, calc("20", a, b))
    b = 1
}
```

`defer calc("1", a, calc("10", a, b))` 的执行流程:
 1. 为了生成目标函数, `calc("10", a, b)` 首先被执行. 此时将 a,b 的值是程序执行到此时a b的值, 即 `a=1, b=2`
 2. 生成 `calc("1", a, calc("10", a, b))` 函数, 拷贝参数值到函数中, 即 `calc("1",1,3)`
 3. 将calc函数压入栈, 程序继续执行.

## TODO
1. defer延迟执行的函数是怎么存储的, 以及该函数的变量值存储到哪里了
