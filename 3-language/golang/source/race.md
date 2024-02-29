# race
> `go help build|grep race`

race detection: 竞争条件检测.

启用 竞争检测时, 编译器会插桩代码, 使所有代码在访问内存时, 记录其访问时间和方法. 同时运行时库会观察对共享变量的未同步访问. 当竞争行为被检测到时, 就会输出警告信息.

使用: `go run/build -race main.go`

## 示例
> 参考 [golang中的race检测](https://www.cnblogs.com/yjf512/p/5144211.html)

如下代码中, 变量a在多个Goroutine中存在竞争关系, 示例如下.

```Go
func main() {
	a := 1
	go func() {
		a = 2
	}()
	a = 3
	fmt.Println("a is ", a)
	time.Sleep(2 * time.Second)
}
```

输出如下
````
$ go run -race main.go
a is  3
==================
WARNING: DATA RACE
Write at 0x00c0000160f0 by goroutine 6:
  main.main.func1()
      /home/wzs/go/src/demo/main.go:11 +0x38

Previous write at 0x00c0000160f0 by main goroutine:
  main.main()
      /home/wzs/go/src/demo/main.go:13 +0x88

Goroutine 6 (running) created at:
  main.main()
      /home/wzs/go/src/demo/main.go:10 +0x7a
==================
Found 1 data race(s)
exit status 66
```

分析如下代码, 推测是否可能会发生竞争.
```Go
func main() {
	start := time.Now()
	var t *time.Timer
	t = time.AfterFunc(randomDuration(), func() {
		fmt.Println(time.Now().Sub(start))
		t.Reset(randomDuration())
	})
	time.Sleep(5 * time.Second)
}

func randomDuration() time.Duration {
	return time.Duration(rand.Int63n(1e9))
}
```

答案参考文章链接.

_提示: time.AfterFunc() 会单独开一个线程, 而在 AfterFunc() 中调用t时, 存在main线程尚未赋值给t的可能性_

## 源码
race api 定义: `$GOROOT/src/runtime/race0.go`

示例: 当 slice 执行 `growslice()` 时, 会检测竞争条件, 代码摘录如下
```Go
// $GOROOT/src/runtime/slice.go
func growslice(et *_type, old slice, cap int) slice {
	if raceenabled {
		callerpc := getcallerpc()
		racereadrangepc(old.array, uintptr(old.len*int(et.size)), callerpc, funcPC(growslice))
	}
  ...
}
```

## 参考
1. [http://blog.golang.org/race-detector](http://blog.golang.org/race-detector)
  - [译文: 介绍Go竞争检测器](https://studygolang.com/articles/1531)

