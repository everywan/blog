# 性能分析
性能分析, 是一种以收集程序运行时信息为手段, 研究程序行为的分析方法, 即动态程序分析.

一般而言, 通过如下方式获取运行时信息: 
新起一个线程, 每经 hz 秒(或手动)触发, 获取cpu使用率和调用栈.

一般而言, 使用 profile 收集一个堆栈的运行时信息.

## pprof
pprof 用于收集Go程序运行时信息, 并提供可视化工具展示.

参考: [godoc](https://golang.org/pkg/runtime/pprof/)

或者直接看源码 [pprof.go]($GOROOT/src/runtime/pprof/pprof.go)

pprof 基本实现如下:
启动一个 goroutinue, 每过100ms(默认值)调用 `runtime.readProfile()` 获取cpu/堆栈信息, 记录到profile.

### 使用
pprof 使用场景主要为以下三种
1. 基准测试. 输出 cpu/mem 使用信息
  - 示例: `go test -cpuprofile cpu.prof -memprofile mem.prof -bench .`
2. web server. web服务程序. 使用 `net/http/pprof` 库.
3. standalone program. 所有非HTTP程序. 使用 `runtime/pprof` 库.

以 `runtime/pprof` 举例, copy自pprof的godoc.
主要分为 CPUProfile 和 MemoryProfile.

```Go
func main() {
  // 一般都是通过 flag 传入, 为了方便如此写了
	cpuProfile, err := os.Create("./cpu.prof")
	if err != nil {
		log.Fatal("create file error")
	}
	defer cpuProfile.Close()
	err = pprof.StartCPUProfile(cpuProfile)
	if err != nil {
		log.Fatal("start cpu error")
	}
	defer pprof.StopCPUProfile()

  dosomething()

	memProfile, err := os.Create("./mem.prof")
	if err != nil {
		log.Fatal("create file2 error")
	}
	defer memProfile.Close()
	runtime.GC()
	err = pprof.WriteHeapProfile(memProfile)
	if err != nil {
		log.Fatal("start mem error")
	}
}

func dosomething() {
  r := ""
	for i := 0; i < 1000000; i++ {
    r += string(i)
	}
  return r
}
```

而后, 直接执行程序即可, 会在当前目录生成 `cpu.prof` 和 `mem.prof`, 
然后使用 `go tool pprof xx.prof` 打开文件.

pprof tool 常用方法, 具体在进入 pprof shell 后, 通过 `help` cmd 查看
1. 通过web打开: `go tool pprof -http=:8080 cpu.prof`
2. 查看前5个记录(排序后): `top5`, 前5个最耗时的调用.

注意情况
1. 注意查看报错, 可能需要安装一些依赖包.
2. 测试学习pprof时, 注意程序不要太简单了, 否则可能会出现程序执行成功, 但是 prof 查看信息为空的情况. 
这是因为程序执行时间太短, 导致pprof还没打点就结束了, 而且 pprof 信息也看不到有用的信息(每100ms打点时,
程序已经跳出测试函数)

### pprof_Profile
通过 pprof 新建一个 Profile, 通过 Add(tag,debug) 将当前的堆栈信息写入Profile, 并将这段信息标记为tag.

pprof 维护一个 profiles 的结构体, 其中包含用户定义的 Profile, 和预置的Profile, 通过 unique name 确定.

按照API接口调用即可.

示例
```Go
func main() {
	profile, err := os.Create("./my.prof")
	defer profile.Close()

	p1 := pprof.NewProfile("s1")
  // 添加标记
	p1.Add("init", 0)
	countAndSay(70)
	p1.Add("done", 0)

	w := bufio.NewWriter(profile)
	defer w.Flush()
  // 输出
	p1.WriteTo(w, 1)
}
```

需要注意的是
1. 需要手动 Flush Writer. `profile.WriteTo()` 不会将数据刷到硬盘.
2. `p.Add(v,d)` 添加的是标记, 将此时的堆栈信息以 v 为key保存.

Go 预置的Profile, 可以通过 `Lookup()` 获取这些 Profile.
````
goroutine    - stack traces of all current goroutines
heap         - a sampling of memory allocations of live objects
allocs       - a sampling of all past memory allocations
threadcreate - stack traces that led to the creation of new OS threads
block        - stack traces that led to blocking on synchronization primitives
mutex        - stack traces of holders of contended mutexes
````

heap profile 是最近活跃的objects的分配情况的抽样, 在最后一次gc之前.
heap 默认配置为 `inuse_space`(活动对象, 即 gc 没有回收的objects)
其他参数还有 `-inuse_space -inuse_objects -alloc_space -alloc_objects`

allocs profile 与 heap 类似, 但 allocs 显示自程序启动后所有的 objects 分配情况的抽样, 包括gc回收过的.
即 heap 指定 `alloc_space`(开辟过内存的objects)

CPU Profile 因为需要持续的, 流式的输出信息, 所以使用 StartCPUProfile/StopCPUProfile 分析.

### 实现
获取 CPU/Mem 信息就与 系统调用 和 Go runtime 相关了, 等以后有机会补充吧.
