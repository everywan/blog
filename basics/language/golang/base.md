<!-- TOC -->

- [Go基础知识](#go基础知识)
    - [基础知识点](#基础知识点)
        - [求值策略](#求值策略)
        - [init函数](#init函数)
        - [指针](#指针)
            - [指针运算符](#指针运算符)
            - [指针输出](#指针输出)
        - [interface](#interface)
            - [go/java-interface对比](#gojava-interface对比)
    - [常用模块](#常用模块)

<!-- /TOC -->
# Go基础知识
## 基础知识点
1. `=`: 赋值， `:=`: 声明变量并赋值(不能在函数外使用)
2. 类型转换: `k:=float(64)` (对比Java:`(Float)64`)
3. 首字母大写: 包的public方法/结构体的public成员(private成员package外不可访问)
    - 在struct中, 当字段首字母小写时, 会导致某些外部函数不读取. 如 `encoding/json.Marshal(struct)` 就不会序列化首字母小写的字段
4. 变量定义: `var name type`
    - 函数定义: `func name() type{}`, 返回值类型后置
5. if/else/switch 语句在执行前都可以执行一个简单语句. 如: `if i:=f();i<100{}`
    - switch可以没有条件, 直接在分支中进行判断. 如: `switch {case hour<12: cmd}`
6. 空白标识符(blank identifier)`_`: 标识返回值中不需要声明的变量(如不需要map的key时). It avoids having to declare all the variables for the returns values.
    - 参考: https://stackoverflow.com/questions/27764421/what-is-in-a-golang-declaration
    - 对于 `import _package`, 会执行包内的 `init()` 函数, 而不使用包导出的变量和其他方法
7. 其他类型->字符串: `fmt.Sprintf("format",args)`
    - `%s` 字符串, `%v` 相应值的默认格式, `%+v` 输出结构体时添加相应字段名
    - `fmt.Println()` 实现了 `fmt.error, fmt.Stringer`等接口, fmt包在输出时匹配会尝试匹配其实现/方法
9. 实例化结构体: `point := new(Point)` 或者 `point := &Point{}`. `&T{}`等价与new.(底层调用new方法)
10. `map/slice/chan` 使用前必须创建
11. go语言每种类型都有自己的默认值
    - 常规: `int:0, bool:false, string:""`
    - `[指针，函数，interface，slice，channel,map]` 的默认值是nil. (nil不是关键字. nil
    只是一个预定义的变量)
    - struct的默认值不是nil, 而是其中各元素为默认值的结构体. 结构体判空使用: `if(Test{}) == test){}`
12. 创建对象: `make(Type, size)`, size表示初始容量. 注意, 对象/对象内元素会初始化为默认值.
    - make 用来为 slice, map 或 chan 类型分配内存和初始化一个对象(注意: 只能用在这三种类型上)
    - 示例: `var m map[string]int=make(map[String]int, 20)`
    - make 底层使用new实现的.
12. 创建对象指针: `new(Type)`: 分配新的内存，它的第一个参数是一个类型，不是一个值，它的返回值是一个指向新分配类型零值的指针
13. import: 导入包
    ```Go
    import (
        "fmt"       // 正常导入
        // fmt.Println("hello world")

        . "fmt"     // 忽略包前缀
        // Println("hello world")
        
        f "fmt"     // 添加包别名
        // f.Println("hello world")
    )
    ```
14. 常量只能是数字. 可以使用 `a0 = iota` 表示从0开始的一系列常量, iota表示递增, 支持诸多运算规则
    - `_ = iota+999`: 表示从 1000 开始
    - `_ = 1<<iota`: 表示每次递增都是左移一位

### 求值策略
1. go语言中, 所有的方法参数都是值传递.

### init函数
> https://zhuanlan.zhihu.com/p/34211611
1. `init()`: 初始化函数, go系统函数, 编译器会自动调用 init函数(init 先于 main 执行)
2. 每个包/文件里可以有多个init函数. 同一包中的init函数调用没有明确顺序, 不同包之前依赖调用顺序.
    - 当引用一个包时, 该包内的所有 init() 都被执行.
3. init函数没有输入参数,返回值, 不可以被调用
4. `import _ "net/http/pprof"`: 只调用该包的init函数, 不使用包导出的变量或者方法.

### 指针
1. go语言不支持指针加减
    - C/C++中, 加/减一个整数 是将该指针变量的原值(一个地址) 和 指针所指向的变量占用的内存单元字节数 相加或相减(保证了p+i指向p后的第i个元素)
    - 如: `p = array[0], 则 p+1 指向 array[1]`(假设array长度>2)

#### 指针运算符
1. 取地址运算符 `&`: 返回操作数的内存地址, 即取变量的地址.
    - 注意, `var2 := &var`, var是指针时, 取得是指针的地址, var2是指向指针var的指针.
2. 间接寻址运算符 `*`: 返回操作数所指向地址的变量的值, 即取指针的值.

#### 指针输出
1. go语言中输出指针值: `fmt.Print("%p\n", &s)`.
    - `fmt.Println(&var)` 封装了指针的输出: 对于值类型, 会输出var的地址, 对于引用类型, 输出var的值.
2. 示例
    ```Go
    func main() {
        m := []int{1, 2, 3}
        fmt.Printf("&m = %p, ", &m)
        fmt.Println(&m)
        n := [3]int{1, 2, 3}
        fmt.Printf("&n = %p, ", &n)
        fmt.Println(&n)
    }
    // 输出
    /*
    * &m = 0xc42000a080, &[1 2 3]
    * &n = 0xc420012360, &[1 2 3]
    */
    ```
### interface
go 语言中的
#### go/java-interface对比
> [interface-java](/basics/language/base/interface.md)

## 常用模块
1. strcov: 字符串->其他类型
2. encoding: 各种编码转换, 包括json编码struct等
    - json/struct转换: `json.Marshal()`, 返回struct中public的字段的json编码(会读取tag的值作为key值)
3. net: 网络相关的扩展, 如TCP/UDP链接，数据包的发送和接收
4. http: web服务器相关
5. time: 时间相关扩展
    - 格式化时间: `time.Now().Format("2006-01-02 03:04:05 PM")`
        - 在go语言中, 格式有如下限定: `月份 1,01,Jan,January, 日 2,02,_2, 时 3,03,15,PM,pm,AM,am, 秒 5,05， 年 06,2006, 周几 Mon,Monday, 时区时差表示 -07,-0700,Z0700,Z07:00,-07:00,MST, 时区字母缩写 MST`
        - 参考: http://www.cnblogs.com/baiyuxiong/p/4349595.html
    - `time.Sleep(time.Second)` 实现线程休眠