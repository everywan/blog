# 并发编程-go

<!-- TOC -->

- [并发编程-go](#并发编程-go)
        - [goroutine (待完成)](#goroutine-待完成)
            - [goroutine超时](#goroutine超时)
        - [异常处理](#异常处理)
        - [chan (待完成)](#chan-待完成)
            - [练习](#练习)
        - [select (待完成)](#select-待完成)
        - [读写锁, 进程阻塞 (待完成)](#读写锁-进程阻塞-待完成)

<!-- /TOC -->

进程线程协程
多路复用/线程池
chan/select
sync.Mutex/WaitGroup/Once

Once: 只执行一次的的对象

```Go
var once Once
// func (o *Once) Do(f func())
once.Do(func() {})
// once需要传入值(使用闭包)
var filename string
once.Do(func(){config.init(filename)})
```

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
2. _对于无缓冲区的chan, 只有写入的元素直到被读取后才能继续写入, 否则就一直阻塞. 对于有缓冲的chan,只有当缓冲满了, 才会阻塞_
3. `ch := make(chan interface{}) 和 ch := make(chan interface{},1)` 区别
    - 无缓冲的chan是 `dataqsiz==0`, 发送者与接受者之间不经过缓冲, 直接拷贝数据. 而一旦 dataqsiz>0, 则所有的数据都经过缓冲区. 只有但缓冲区满了, 才会阻塞线程.

### select (待完成)
1. --
2. select中只要有一个case符合条件就会立即执行并且break(跳出select)
3. 多个case可以执行时, 则 伪随机方式抽取一个case执行
4. 如果没有case能被执行且有default, 则执行default.(case 如果是管道读取, 则不要写default)
6. 参考
    - [goroutine超时](#goroutine超时)

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
