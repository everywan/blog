- [defer](#defer)
  - [作用域](#%E4%BD%9C%E7%94%A8%E5%9F%9F)
  - [执行流程](#%E6%89%A7%E8%A1%8C%E6%B5%81%E7%A8%8B)
  - [求值策略](#求值策略)
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
1. 在 Go 中, return 返回值分为两种: 匿名返回值,具名返回值.
  - 具名返回值在函数声明时被声明
  - 匿名返回值在return执行时声明. 匿名返回值与函数内声明的变量不同, 即使在函数内声明了变量并将该变量返回, 该变量也不是匿名返回值变量(原因未知, 后续可学习源码).
2. 在 Go 中 return 执行顺序为: 返回值赋值 => 返回值返回.

正常情况下, defer 函数在 return 执行时被执行, 流程为: 返回值赋值 => defer 函数执行 => 返回值.
当程序发生异常时, 程序在 panic 抛出异常前执行, 所以可以使用defer捕获函数执行时的异常.

所以, defer 会延迟函数的执行, 并且在任何情况下defer都会被执行. 
对于多个defer， 会按照入栈顺序依次执行.

思考一个问题: defer 是否可以更改函数返回值? 在 [defer与return](#defer与return) 中, 那些函数可以修改返回值?

提示:
1. 根据return/defer的执行流程, 虽然defer无法直接修改返回值(defer前返回值赋值已完成), 但是defer可以通过获取返回值地址, 然后修改地址内容的值来间接修改返回值.
2. 对于匿名非指针返回值, 在函数内获取不到返回值地址. 原因未知.
3. 对于指针型返回值, defer 可以直接访问到地址; 对于具名返回值, defer 可以在函数内获取返回值地址.

示例参见
1. [defer与panic](#defer与panic)
2. [defer与return](#defer与return)

## 求值策略
规则1: 在Go语言中, 求值策略=严格求值+传值调用. 参考 [求值策略](/skill/Evaluation.md)
- 严格求值: 函数实参在函数调用前就求值, 与之相对的是 Js 使用非严格求值(即惰性求值)
- 传值调用: 函数参数都是值传递, Go允许参数为函数. 值传递是指传递的是变量的拷贝.

规则2: 在闭包函数中, 函数体内引用外部变量是引用传递, 参数依旧参照规则1. 即闭包函数运行时使用该变量时, 才获取此时该变量的值.
- 闭包中使用引用传递要注意内存泄露的问题: 己分配的内存由于闭包函数还在使用从而无法释放, 造成系统内存的浪费, 导致程序运行速度减慢甚至系统崩溃等严重后果.

规则3: defer与闭包函数不同的是, defer 有专有的执行栈, 所有的defer函数都被压入栈中,等待执行.

举例说明 在defer函数中, 遵照上述两个规则. 如对于 `defer f(a,b){}`
1. 参数 a/b 符合规则1, 所以如果 a/b 是表达式/函数, 则会先被计算出常量值.
2. `f()` 函数体内的参数符合规则2, 即在使用时去取值.

示例参见
1. [defer参数生成](defer参数生成)
2. [闭包函数参数生成](闭包函数参数生成)

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
	fmt.Println(*test1())
	fmt.Println(test2())
	fmt.Println(*test3())
	fmt.Println(test4())
}

// 考察具名返回值
func test1() (a *int) {
	a = new(int)
	defer func() { *a = *a + 1 }()
	*a = *a + 1
	return a
}
func test2() (a int) {
	defer func() { a = a + 1 }()
	return a + 1
}

// 考察匿名返回值
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

只有 test1/test2/test3 可以修改返回值

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

### 闭包函数参数生成
```Go
func calc() func() {
	a, b := 1, 2
	f := func(a, b int) int {
		return a + b
	}
	a = 0
	f2 := func() {
		fmt.Println(f(a, b) + a + b)
	}
	return f2
}
func main() {
	calc()()
}
```

## TODO
1. defer延迟执行的函数是怎么存储的, 以及该函数的变量值存储到哪里了
