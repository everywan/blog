# Go基础
## 单元测试
> 参考: https://studygolang.com/articles/8089

1. Go语言的自动测试框架规则如下
    - 测试代码以 `_test.go` 结尾
    - 测试代码中要 `import "testing"`
    - 测试函数签名: `func Test...(t *Testing.T){}`, 即以Test开始, 且传入 `*Testing.T` 参数
    - 测试包名为 test文件所在位置, 即 `package 所在包`
    - 测试执行使用 `go test` 执行测试, 默认当前路径, 也可以指定路径执行
1. 示例:
    ```Go
    package main
    import "testing"
    
    func add(x, y int) int {
        return x + y
    }
    func TestAdd(t *testing.T) {
        ret := add(2, 3)
        if ret != 5 {
            t.Error("Expected 5, got ", ret)
        }
    }
    // test输出
    // ok      wzsgit/demo/vendor/test_dir     0.001s
    ```
2. 性能测试 Benchmark, 用法基本与Test相同, 不同如下
    - 测试函数签名: `func Benchmark...(b *Testing.B){}`, 即以Benchmark开始, 且传入 `*Testing.B` 参数
    - 测试执行使用 `go test -bench .` 执行测试, 默认当前路径
2. 示例
    ```Go
    package test_dir
    import "testing"

    func add(x, y int) int {
        return x + y
    }
    func BenchmarkAdd(t *testing.B) {
        ret := add(2, 3)
        if ret != 5 {
            t.Error("Expected 5, got ", ret)
        }
    }
    // 输出
    /*
        goos: linux
        goarch: amd64
        pkg: wzsgit/demo/vendor/test_dir
        BenchmarkAdd-4          2000000000               0.00 ns/op
        PASS
        // 解释: 执行结果     执行目录        平均每次执行时间
        ok      wzsgit/demo/vendor/test_dir     0.003s
    */
    ```
### Testing
1. Testing.T / Testing.B / Testing.PB 后续再整理.
    - 参考: https://blog.csdn.net/cchd0001/article/details/48181239