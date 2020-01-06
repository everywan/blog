# 性能分析
性能分析, 是一种以收集程序运行时信息为手段, 研究程序行为的分析方法, 即动态程序分析.

一般而言, 通过如下方式获取运行时信息: 
新起一个线程, 每经 hz 秒(或手动)触发, 获取cpu使用率和调用栈.

## pprof
pprof 用于收集Go程序运行时信息, 并提供可视化工具展示.

API 参考: [godoc](https://golang.org/pkg/runtime/pprof/)

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

