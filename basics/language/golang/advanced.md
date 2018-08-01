<!-- TOC -->

- [Go 进阶知识](#go-进阶知识)
    - [知识](#知识)
        - [defer](#defer)
            - [练习一:defer/返回值顺序](#练习一defer返回值顺序)
            - [练习二:defer函数生成](#练习二defer函数生成)
        - [网络服务](#网络服务)
            - [监听服务](#监听服务)
            - [controller函数](#controller函数)
        - [signal.Notify](#signalnotify)
        - [interface](#interface)
            - [泛型](#泛型)
            - [接口](#接口)
    - [应用](#应用)
        - [循环](#循环)
            - [示例](#示例)
        - [uint/byte 转换](#uintbyte-转换)
        - [调用C](#调用c)

<!-- /TOC -->
# Go 进阶知识
## 知识
### defer
1. defer: 参数是函数, defer关键字延迟函数的执行, 直到上层函数返回(即当前函数执行完成并且返回后)才执行(如果上层函数报错,则是在上层函数错误抛出后执行)
    - 延迟调用的参数会立刻生成，但是在上层函数返回前函数都不会被调用
    - 上层函数是指defer语句所在的函数
    - 多个defer函数时, defer 延迟执行的函数 依次入栈. 然后上层函数返回后依次pop执行
    - defer函数任何情况下都会被执行.
2. 猜测以下函数输出
    ```Go
    func defer_call() {
        defer func() { fmt.Println("打印前") }()
        defer func() { fmt.Println("打印中") }()
        defer func() { fmt.Println("打印后") }()
        panic("触发异常")
    }
    ```
2. 考察知识点
    - _多个defer函数时, 依次入栈, 然后函数返回时, 依次出栈执行_
    - _panic()在所有defer执行完后抛出, 并且被打印._

#### 练习一:defer/返回值顺序
1. defer/return/返回值 顺序
    - return 分为两部执行: 返回值赋值 和 return.
        - 执行顺序: 返回值赋值 -> defer -> return
        - 返回值分为两种: 匿名返回值和有名返回值, 匿名返回值在 return 执行时被声明, 有名返回值在函数声明时被声明. 所以defer可以修改有名返回值. 同时,若返回指针, 由于defer可以访问指针, 所以也可以改变指针的值.
    - 接着defer开始执行一些收尾工作
    - 最后函数携带当前返回值退出.
2. 猜测那些函数的defer可以更改返回值
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
2. _test2/3可以改变值_

#### 练习二:defer函数生成
1. defer/goroutine 的参数都是函数, 并且 调用的函数立即生成, 添加到栈/队列中去等待执行
2. 示例一: 
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
2. `defer calc("1", a, calc("10", a, b))` 的执行流程:
    1. 为了生成目标函数, `calc("10", a, b)` 首先被执行. 此时将 a,b 的值是程序执行到此时a b的值, 即 `a=1, b=2`
    2. 生成 `calc("1", a, calc("10", a, b))` 函数, 拷贝参数值到函数中, 即 `calc("1",1,3)`
    3. 将calc函数压入栈, 程序继续执行.
3. 待学习: defer延迟执行的函数是怎么存储的, 以及该函数的变量值存储到哪里了

### 网络服务
> 详细参考: [我的网站后台](https://github.com/everywan/xiagaoxiawan/tree/master/src/server)
1. 重定向: `func Redirect(w ResponseWriter, r *Request, urlStr string, code int)`
    - urlStr 表示重定向后的url地址
    - code: HTTP状态码, 根据状态码返回不同
        - 301 永久移动: 服务器返回此响应(对 GET 或 HEAD 请求的响应)时, 会自动将请求者转到新位置
        - 302 临时移动: 服务器目前从不同位置的网页响应请求, 但请求者应继续使用原有位置来进行以后的请求
        - 其他参考 [HTTP状态码](http://www.cnblogs.com/starof/p/5035119.html)

#### 监听服务
```Go
func startWebServer(ipaddr string, network string) {
	defer func() {
		if err := recover(); err != nil {
			logger.ERROR(fmt.Sprintf("启动socket网络服务(startWebServer) 发生错误: %+v", err))
		}
	}()
    // 添加handle
    http.HandleFunc("/v1/test", test)
	// 设置监听
	listenPort := configure.ReadConfigByKey("./init.ini", "Net", "listenPort")
	// 创建server对象, 设置超时时间
	server := &http.Server{
		Addr:         ":" + listenPort,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 5 * time.Second,
	}
	err := server.ListenAndServe()
	if err != nil {
		logger.ERROR(fmt.Sprintf("启动socket网络服务(startWebServer) 发生错误(ListenAndServe方法): %+v", err))
	}
}
```

#### controller函数
```go
func test(w http.ResponseWriter, r *http.Request) {
	result := "false"
	defer func() {
		if err := recover(); err != nil {
			logger.ERROR(fmt.Sprintf("执行web方法出错(test), 错误是: %+v", err))
		}
		jsonResult, _ := json.Marshal(result)
		fmt.Fprintf(w, "%s", jsonResult)
    }()
    // 解析URL中的查询字符串(POST或PUT请求主体要优先于URL查询字符串)
    r.ParseForm()
    if msg, ok := r.Form["msg"]; ok {
        result = msg
    }else{
        result = "true"
    }
}
```

### signal.Notify
1. `func Notify(c chan<- os.Signal, sig ...os.Signal)`: 将进程收到的系统Signal转发给chan c. 
    - 如果没有列出要传递的信号, 会将所有输入信号传递到c; 否则只传递列出的输入信号.
2. 如果当前进程向chan发送信号时产生阻塞, 则当前进程放弃发送此信号, 继续执行.
3. 可以使用同一通道多次调用Notify: 每一次都会扩展该通道接收的信号集, 唯一从信号集去除信号的方法是调用Stop. 
4. 可以使用同一信号和不同通道多次调用Notify: 每一个通道都会独立接收到该信号的一个拷贝.

### interface
[参考: 深入理解 Go Interface](http://legendtkl.com/2017/06/12/understanding-golang-interface/)

Go/interface 源码暂未阅读, 先不写

在Golang中
- 泛型编程: interface是一种抽象类型(相对而言, int/string 等都是具体类型).
- 接口编程: interface是一组抽象方法的组合, 不关心属性, 只关心行为(方法).
    - [鸭子类型: 当看到一只鸟走起来像鸭子,游泳起来像鸭子,叫起来也像鸭子, 那么这只鸟就可以被称为鸭子. 既注对象的行为, 而不关注对象所属的类型](https://zh.wikipedia.org/wiki/鸭子类型)

#### 泛型
判断 interface 类型
```Go
func do(v interface{}) {
    n, ok := v.(int)
    if !ok {
        // 断言失败处理
    }
}
```

[泛型编程](https://github.com/everywan/note/blob/master/basics/language/java/summary.md#%E6%B3%9B%E5%9E%8B): 泛型类/方法/接口, 既 T.

interface 实现泛型编程
1. 参数为 interface 类型, 在函数内判断 interface 的类型, 然后调用相应的方法. (只能是内置类型,或者双方有约定的类型)
2. 定义 interface 接口, 然后所有该方法依赖的方法都定义到接口里, 要求传入的参数必须实现该接口

#### 接口
[interface 简介](/basics/language/base/interface.md)

- **实现interface接口时, 必须保持方法接收者与接口定义的类型相同**. [详细参见: Go-结构体](/basics/language/golang/struct.md#接口继承)
- **接口类型无法被实例化, 但是接口可以使用接口声明一个空指针, 然后被绑定到实现该接口的类上**
- go语言的接口是非侵入式的

## 应用
### 循环
1. go 只有for循环, 且 for 循环中, 对于每次循环, 变量i指针不变.
2. 无限循环格式: `for {}`
3. while格式: `for i<100{}`
4. 正常格式: `for i:=0;i<100;i++{}`
5. 使用range: `for i, v:=range slice/map{}`
#### 示例
1. 示例一: 使用 range 对 map/struct 的遍历
    ```Go
    type student struct {
        Name string
        Age  int
    }
    func pase_student() map[string]*student {
        m := make(map[string]*student)
        stus := []student{
            {Name: "zhou", Age: 24},
            {Name: "li", Age: 23},
            {Name: "wang", Age: 22},
        }
        for _, stu := range stus {
            m[stu.Name] = &stu
        }
        return m
    }
    func main() {
        students := pase_student()
        for k, v := range students {
            fmt.Printf("key=%s,value=%v \n", k, v)
        }
    }
    ```
1. _对`for _, stu := range stus {}`遍历时, 每次循环都是值拷贝, i(这里是stu) 的地址是没有变化的. 所以最后m中的stu指向的都是同一个地址_
2. 示例二
    ```Go
    func main() {
        runtime.GOMAXPROCS(1)
        wg := sync.WaitGroup{}
        wg.Add(20)
        for i := 0; i < 10; i++ {
            go func() {
                fmt.Println("i: ", i)
                wg.Done()
            }()
        }
        for i := 0; i < 10; i++ {
            go func(i int) {
                fmt.Println("i: ", i)
                wg.Done()
            }(i)
        }
        wg.Wait()
    }
    ```
2. 考察知识点
    - _由于设置了`runtime.GOMAXPROCS(1)`, 所以程序是串行执行, 先执行主函数, 然后依次执行各个goroutine_
    - [函数调用](#函数调用)
    - _对于第一个 `go func`, i是外部for的一个变量, 地址不变化. 遍历完成后, 最终i=10. 所以`go func`执行时, i的值始终是10_

### uint/byte 转换
> uint/byte之间的转换,高位为0时,都会根据 uint的长度 自动补位     
```Go
// 方法1
bs := make([]byte, 2)
binary.BigEndian.PutUint16(bs, uint16(200))
// 方法2
buf := new(bytes.Buffer)
err := binary.Write(buf,binary.BigEndian,body)
buf.Bytes()
```

### 调用C
```Go
/*
#include <stdio.h>

int test() {
    printf("call c\n");
    return 0;
}
*/
import "C"
import (
	"fmt"
	"runtime"
)
func main() {
	runtime.GOMAXPROCS(runtime.NumCPU())
	C.test()
	fmt.Println(11)
}
```