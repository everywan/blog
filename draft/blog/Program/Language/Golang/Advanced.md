<!-- TOC -->

- [Go 进阶知识](#go-进阶知识)
    - [知识](#知识)
        - [defer](#defer)
            - [练习一:defer/返回值顺序](#练习一defer返回值顺序)
            - [练习二:defer函数生成](#练习二defer函数生成)
        - [goroutine (待完成)](#goroutine-待完成)
            - [goroutine超时](#goroutine超时)
            - [goroutine超时](#goroutine超时-1)
        - [异常处理](#异常处理)
        - [select (待完成)](#select-待完成)
        - [chan (待完成)](#chan-待完成)
            - [练习](#练习)
        - [读写锁, 进程阻塞 (待完成)](#读写锁-进程阻塞-待完成)
        - [网络服务](#网络服务)
            - [监听服务](#监听服务)
            - [controller函数](#controller函数)
        - [signal.Notify](#signalnotify)
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

### goroutine (待完成)
> 留坑
1. --
2. goroutine 只能自杀: A stop channel is a good way to do it. A goroutine must stop itself. There is no way to externally kill one.
    - goroutine 只能自杀, 不能从外界关闭. 所以, 除了使用通道判断超时外, 还需要goroutine程序本身支持中断/停止信号, 否则只是关闭当前函数, goroutine函数并没有退出
    - 对于 socket 而言, 关闭 conn 则会使socket程序的 `write/read` 函数退出, 从而kill goroutine中相关程序
    - 通常, 对于并发程序(go语言)而言, 设计两类 chan, 一个用于传输data, 一个用于传输信号. 在并发程序中判断信号量执行 *自杀* 等逻辑, 在主程序中使用chan判断超时

#### goroutine超时
> 详细参考: [GO_socket项目实践](https://github.com/everywan/IOT_Server)   
> 参考文章: [为脚本执行设置超时时间](http://ulricqin.com/post/set-script-timeout-use-golang/)

```Go
func SendToObject(msg []byte, conn net.Conn) {
	WriteMsgWithHandleTimeout(7*time.Second, msg, conn)
}
func WriteMsgWithHandleTimeout(timeout time.Duration, msg []byte, conn net.Conn) {
	// 超时通道
	doneCh := make(chan error, 1)
	go func() {
		conn.Write(msg)
		doneCh <- nil
	}()
	// 设置超时
	select {
	case <-time.After(7 * time.Second):
		{
			xslog.Error(fmt.Sprintf("执行超时, 关闭当前连接, 指令集是: %x", msg))
			// 将信息从通道中取出
			go func() {
				<-doneCh
			}()
			// 如果发生超时, 关闭连接
			return
		}
	case err := <-doneCh:
		{
			if err != nil {
				xslog.Error(fmt.Sprintf("执行错误, 错误是: %x, 指令集是: %x", err, msg))
			}
			break
		}
	}
}
```
#### goroutine超时
参考 [defer函数生成](#练习二:defer函数生成)

### 异常处理
> 参考: http://www.cnblogs.com/ghj1976/archive/2013/02/11/2910114.html

1. Go语言中没有 `throw/try/catch/finally` 机制. Go使用 `panic()` 抛出异常, 使用 `recover()` 捕获异常
    - 因为drfer延迟执行的函数 任何情况下都会执行, 所以defer可以替代 try/finally
2. 返回错误的两种办法
3. 示例一: 使用有名返回值, 若在defer中捕获到错误就赋值给返回值
    ```Go
    func f()(err error){
        defer func(){
            // 判断程序是否有异常
            if err = recover();err!=nil{
                // 自定义逻辑处理
                fmt.Printf("%+v",err)
            }
        }()
        b := []byte{10}
        fmt.Printf("%x",b[100])
    }
    ```
3. 示例二: 使用匿名返回值, 在程序中添加判断, 不符合要求则返回异常.
    ```go
    func f()error{
        switch s := source.(type) {
        case string:
            return nil
        default:
            return nil, fmt.Errorf("％v testError","msg")
        }
    }
    ```

### select (待完成)
1. --
2. select中只要有一个case符合条件就会立即执行并且break(跳出select)
3. 多个case可以执行时, 则 伪随机方式抽取一个case执行
4. 如果没有case能被执行且有default, 则执行default.(case 如果是管道读取, 则不要写default)
6. 参考
    - [goroutine超时](#goroutine超时)

### chan (待完成)
1. channel: 有类型的管道, 使用前必须创建: `ch := make(chan int [size])`
    - 从管道读取消息: `v:=<-ch`, 消息进入管道: `ch<-v`
    - 参考: [深入理解 Go Channel](http://legendtkl.com/2017/07/30/understanding-golang-channel/)

#### 练习
1. 如下程序能否正常运行
    ```Go
    func (set *threadSafeSet) Iter() <-chan interface{} {
        ch := make(chan interface{})
        go func() {
            set.RLock()
            for elem := range set.s {
                ch <- elem
            }
            close(ch)
            set.RUnlock()
        }()
        return ch
    }
    ```
2. _对于无缓冲区的chan, 只有写入的元素直到被读取后才能继续写入, 否则就一直阻塞_
3. `ch := make(chan interface{}) 和 ch := make(chan interface{},1)` 区别
    - 无缓冲的 不仅仅是只能向 ch 通道放 一个值 而是一直要有人接收, 那么`ch <- elem`才会继续下去, 要不然就一直阻塞着. 也就是说有接收者才去放, 没有接收者就阻塞
    - 而缓冲为1则即使没有接收者也不会阻塞, 因为缓冲大小是1. 只有当 放第二个值的时候 第一个还没被人拿走, 才会阻塞 

### 读写锁, 进程阻塞 (待完成)
> 参考: [读写锁简介](https://studygolang.com/articles/3027)    
> [GO语言并发编程之互斥锁、读写锁详解](http://www.jianshu.com/p/00d510729ab5)   
> [线程阻塞](https://www.douban.com/note/484590266/)
1. 读写锁由 `sync.RWMutex` 信号量控制. 写锁定: `func (*RWMutex) Lock/Unlock`,  读锁定: `RLock/RUnlock`
    - 对已被**写锁定**的读写锁进行**写锁定**, 会造成当前Goroutine的阻塞, 直到该读写锁被写解锁. 如果有多个Goroutine因此而被阻塞, 那么当对应的写解锁被进行之时只会使其中一个goroutine的运行被恢复
    - 对已被**写锁定**的读写锁进行**读锁定**, 会造成当前Goroutine的阻塞, 直到该读写锁被写解锁. 如果有多个Goroutine因此而被阻塞, 那么所有因欲进行读锁定而被阻塞的Goroutine的运行都会被恢复
    - 两个不同的读写锁不会相互干扰.
    - 对已被**读锁定**的读写锁进行**写锁定**, 那么写锁定会在所有的读锁定全部解锁后才进行.如果有多个读锁定,只会让其中一个被恢复.
    - 对已被**读锁定**的读写锁进行**读锁定**没有任何问题.
2. 线程阻塞由 `sync.WaitGroup` 信号量控制(同步等待组)
    - 作用: 阻塞主线程,等待所有的 goroutines 都完成
    - 类似于C++的智能指针, WaitGroup保存着所有的引用, 使用 wc.Add() 添加引用计数, 当goroutin完成时,调用wc.Done()减少一个引用计数, wc.Wait() 等待计数为0时停止阻塞
3. 示例如下: 目的: 保证所有的goroutine读取到的序号之是唯一的
    - 只有 Lock/Unlock 保证了所有 goroutine 读取到了唯一值, RLock 没有效果
    ```Golang
    var m *sync.RWMutex
    var wc sync.WaitGroup
    var gloableSerialNo = uint16(1)
    func main() {
        m = new(sync.RWMutex)
        for i:=0;i<100;i++{
            wc.Add(1)
            go getSerialNo(&gloableSerialNo)
        }
        wc.Wait()
        fmt.Println(gloableSerialNo)
    }
    func getSerialNo(funcNameSerialNo *uint16)uint16{
        defer func(){
            m.Unlock()
            wc.Done()
        }()
        m.Lock()
        serilaNo := *funcNameSerialNo
        time.Sleep(time.Second)
        *funcNameSerialNo = *funcNameSerialNo + 1	
        return serilaNo
    }
    ```

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