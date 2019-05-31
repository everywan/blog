# 单元测试
单元测试基础参考 [单元测试](/standard/tdd/unit.md), 深入了解可查看源码(在 `$GOROOT/src/testing/`)

Go 语言自动测试框架规则如下
1. 测试代码以 `_test.go` 结尾
2. 测试包名为 `_test.go` 文件所在位置, 即 `package 所在包`
3. 测试使用 testing 包, 需要 `import "testing"`
4. 测试执行使用 `go test` 执行测试, 默认当前路径, 也可以指定路径执行

测试函数签名如下, 参数必须使用此格式, 函数名建议使用如下格式.
1. 单元测试: `func Test_xxx(t *Testing.T){}`
2. 基准测试: `func Benchmark_xxx(b *Testing.B){}`
  - 并发基准测试: `func(pb *testing.PB)`, 一般 在基准测试中需要并行设置中测试性能 使用. 具体参见后续介绍.

----

测试代码如下
```Go
package main
import "testing"

func add(x, y int) int {
    return x + y
}

// 单元测试
func Test_Add(t *testing.T) {
    ret := add(2, 3)
    if ret != 5 {
        t.Error("Expected 5, got ", ret)
    }
}

// 基准测试
func Benchmark_Add(t *testing.B) {
    ret := add(2, 3)
    if ret != 5 {
        t.Error("Expected 5, got ", ret)
    }
}
```

## 单元测试
推荐参照 [单元测试](/standard/tdd/unit.md) 使用相关框架方便编写测试用例

---

命令示例: `go test -v -cpu=1 --count=1 -timeout 30s github.com/xxx/xxx/internal/services -run Test_XXX`
- `run pattern`: 通过 正则 匹配出所有符合条件的函数. 所以根据需要确定是否加 `$`.
- v 用于输出测试信息
- count: 当 count=1 时每次都重新生成, 而不是用缓存.

## 基准测试
基准测试支持在指定位置调用 `b.StartTimer()/StopTimer()` 显示对测试进行计时.

具体函数使用参考 [testing godoc](https://studygolang.com/static/pkgdoc/pkg/testing.htm).

---

命令示例: `go test -benchmem -cpuprofile profile/cpu.prof -memprofile profile/mem.prof -timeout 30s github.com/xxx/xxx -bench=. -run BenchmarkTest_XXX`
- cpuprofile: 记录cpu使用情况, 记写到指定文件中直到测试退出
- benchmem: 打开当前基准测试的内存统计功能

---

输入格式如下
````
goos: linux
goarch: amd64
pkg: github.com/xxx/xxx/controllers
BenchmarkTest_Xxx-8 	5000000000	         200 ns/op	       32 B/op	       2 allocs/op
PASS
ok  	github.com/xxx/xxx/controllers	0.009s
````

`BenchmarkTest_Xxx-8 	5000000000	         200 ns/op	       32 B/op	       2 allocs/op`
- `BenchmarkTest_Xxx-8` 函数名称, `-8` 表示使用8个CPU
- `5000000000` 测试次数
- `200 ns/op` 每次执行耗时200纳秒
- 以下两项在命令行参数中有 `-benchmem` 或 函数中有 `b.ReportAllocs()` 时才会输出
  - `32 B/op` 每次执行分配32字节内存
  - `2 allocs/op` 每次执行分配2次对象

### 并发基准测试

## pprof
常用命令如下, cpuprofile 和 memprofile 类似.
```Bash
# 进入交互式终端, controllers.test 为 go test 时生成的文件
go tool pprof controllers.test profile/cpu.prof

# 以web方式查看.
go tool pprof -http=:8080 profile/mem.prof

# 生成 pdf/svg 格式
go tool pprof -pdf profile/cpu.prof > profile/cpu.pdf
go tool pprof -svg profile/cpu.prof > profile/cpu.svg
```

## 第三方工具
常用的工具有
1. [GoConvey](https://github.com/smartystreets/goconvey): 管理/运行测试用例, 支持断言/web界面. 主要是强化原生go-test功能.
2. [GoStub](https://github.com/prashantv/gostub)
3. [GoMock](https://github.com/golang/mock)
4. [SqlMock](https://github.com/DATA-DOG/go-sqlmock): 模拟DB链接 

### goconvey
用法

```Go
import (
  "testing"
  . "github.com/smartystreets/goconvey/convey"
)

func TestSpec(t *testing.T) {
  // Convey 签名: func Convey(items ...interface{})
  // 参数介绍: 测试用例名称,*testing.T,handle()
	Convey("Given some integer with a starting value", t, func() {
		x := 1
	 	So(x, ShouldEqual, 1)
	})
  // Convey 可以嵌套. 嵌套时内层Convey无需传入t.
	Convey("Given some integer with a starting value", t, func() {
		x := 1
		Convey("The value should be greater by one", func() {
			So(x, ShouldEqual, 2)
		})
	})
}
```

一个Convey表示一个测试用例/域(scope), 嵌套Convey可表示测试用例之间的关系, 在某个Convey中触发了 `t.Fail()` 不影响其他Convey.

一个测试用例(Convey)中有一个或多个So(So 决定执行哪种断言. 原文: _which assertions are made against the system under test_), 从而决定该测试用例是否通过.

当有So失败时, 就会触发 `t.fail()`, 然后结束该Convey(即跳出). GoConvey 使用 [断言函数实现库](https://github.com/smartystreets/assertions) 实现断言.

GoConvey 支持 SkipConvey/SkipSo, 可以跳过指定的测试用例, 且对于Skip的测试, 测试日志会添加 skipped 标记

参考:
1. [GoConvey使用](https://www.jianshu.com/p/e3b2b1194830)
2. [GoConvey-Godoc](https://godoc.org/github.com/smartystreets/goconvey/convey)

----

原理


### 参考
2. https://www.jianshu.com/p/70a93a9ed186
3. https://www.jianshu.com/p/598a11bbdafb
4. https://ruby-china.org/topics/10977
5. https://www.jianshu.com/p/2f675d5e334e


## 参考
1. [testing godoc](https://studygolang.com/static/pkgdoc/pkg/testing.htm)
2. [testing-源码](https://github.com/golang/go/tree/master/src/testing)
3. [Testing 选项](https://www.cnblogs.com/yjf512/archive/2013/01/22/2870927.html), 选项 `test.x` 等效于 `x`
4. [pprof](https://segmentfault.com/a/1190000016412013)
