- [Go基础知识](#go%E5%9F%BA%E7%A1%80%E7%9F%A5%E8%AF%86)
  - [知识点](#%E7%9F%A5%E8%AF%86%E7%82%B9)
    - [一句话概括](#%E4%B8%80%E5%8F%A5%E8%AF%9D%E6%A6%82%E6%8B%AC)
    - [类型默认值](#%E7%B1%BB%E5%9E%8B%E9%BB%98%E8%AE%A4%E5%80%BC)
    - [map/slice/chan/make](#mapslicechanmake)
    - [导入包](#%E5%AF%BC%E5%85%A5%E5%8C%85)
    - [求值策略](#%E6%B1%82%E5%80%BC%E7%AD%96%E7%95%A5)
    - [空白标识符](#%E7%A9%BA%E7%99%BD%E6%A0%87%E8%AF%86%E7%AC%A6)
    - [init函数](#init%E5%87%BD%E6%95%B0)
    - [指针](#%E6%8C%87%E9%92%88)
      - [指针运算符](#%E6%8C%87%E9%92%88%E8%BF%90%E7%AE%97%E7%AC%A6)
      - [指针输出](#%E6%8C%87%E9%92%88%E8%BE%93%E5%87%BA)
    - [signal.Notify](#signalnotify)
    - [for循环](#for%E5%BE%AA%E7%8E%AF)
      - [range遍历](#range%E9%81%8D%E5%8E%86)
    - [uint/byte 转换](#uintbyte-%E8%BD%AC%E6%8D%A2)
    - [调用C](#%E8%B0%83%E7%94%A8c)
  - [常用模块](#%E5%B8%B8%E7%94%A8%E6%A8%A1%E5%9D%97)


# Go基础知识
> [build-web-application-with-golang](https://github.com/astaxie/build-web-application-with-golang/blob/master/zh/preface.md)

## 知识点
### 一句话概括
1. `=`: 赋值， `:=`: 声明变量并赋值(不能在函数外使用)
2. 类型转换: `k:=float(64)` (对比Java:`(Float)64`)
3. 首字母大写: 包的public方法/结构体的public成员(private成员package外不可访问)
    - 在struct中, 当字段首字母小写时, 会导致某些外部函数不读取. 如 `encoding/json.Marshal(struct)` 就不会序列化首字母小写的字段
4. 变量定义: `var name type`
    - 函数定义: `func name() type{}`, 返回值类型后置
5. if/else/switch 语句在执行前都可以执行一个简单语句. 如: `if i:=f();i<100{}`
    - switch可以没有条件, 直接在分支中进行判断. 如: `switch {case hour<12: cmd}`
6. 其他类型->字符串: `fmt.Sprintf("format",args)`
    - `%s` 字符串, `%v` 相应值的默认格式, `%+v` 输出结构体时添加相应字段名
    - `fmt.Println()` 实现了 `fmt.error, fmt.Stringer`等接口, fmt包在输出时匹配会尝试匹配其实现/方法
7. 实例化结构体: `point := new(Point)` 或者 `point := &Point{}`. `&T{}`等价与new.(底层调用new方法)
8.  创建对象指针: `new(Type)`: 分配新的内存，它的第一个参数是一个类型，不是一个值，它的返回值是一个指向新分配类型零值的指针
9.  常量只能是数字. 可以使用 `a0 = iota` 表示从0开始的一系列常量, iota表示递增, 支持诸多运算规则
    - `_ = iota+999`: 表示从 1000 开始
    - `_ = 1<<iota`: 表示每次递增都是左移一位

### 类型默认值
go语言每种类型都有自己的默认值
- 常规: `int:0, bool:false, string:""`
- `[指针，函数，interface，slice，channel,map]` 的默认值是nil. (nil不是关键字. nil
只是一个预定义的变量)
- struct的默认值不是nil, 而是其中各元素为默认值的结构体. 结构体判空使用: `if(Test{}) == test){}`

### map/slice/chan/make
`map/slice/chan` 使用前必须创建

创建对象: `make(Type, size)`, size表示初始容量. 注意, 对象/对象内元素会初始化为默认值.
- make 用来为 slice, map 或 chan 类型分配内存和初始化一个对象(注意: 只能用在这三种类型上)
- 示例: `var m map[string]int=make(map[String]int, 20)`
- make 底层使用new实现的.

### 导入包
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

### 求值策略
1. go语言中, 所有的方法参数都是值传递.

### 空白标识符
在go语言中, 空白标识符有以下用途
1. 用在返回值: 标识返回值中不需要声明的变量, 避免声明返回值中不需要的变量. 好处在于: 编译器可以针对该情况进行优化,减少内存占用.
    - 示例: `card,_ := newCard()`.
2. 用在import: 导入包, 但是只执行包中的 `init()` 方法(即只初始化导入的包), 不引入包中的其他函数和变量. 常用情况如 mysql 包的导入
    - 示例: `import _ "github.com/go-sql-driver/mysql"`
3. 用于变量: 检查变量是否实现接口
    - 示例: `var _ Card = &CardService{}`: 判断 CardService 是否实现了 Card 的所有接口
4. 参考
    - [What is “_,” (underscore comma) in a Go declaration?](https://stackoverflow.com/questions/27764421/what-is-in-a-golang-declaration)
    - [Go 语言中下划线的用法分析总结](https://juejin.im/entry/5af25ecbf265da0b78687ce5)

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

### signal.Notify
1. `func Notify(c chan<- os.Signal, sig ...os.Signal)`: 将进程收到的系统Signal转发给chan c. 
    - 如果没有列出要传递的信号, 会将所有输入信号传递到c; 否则只传递列出的输入信号.
2. 如果当前进程向chan发送信号时产生阻塞, 则当前进程放弃发送此信号, 继续执行.
3. 可以使用同一通道多次调用Notify: 每一次都会扩展该通道接收的信号集, 唯一从信号集去除信号的方法是调用Stop. 
4. 可以使用同一信号和不同通道多次调用Notify: 每一个通道都会独立接收到该信号的一个拷贝.

### for循环
在 Go 中, 只有for循环. 对于每次循环, 只会改变变量i的值, i 的指针始终不变. range 时同理, 只改变循环因子的值, 不改变循环因子的指针. 即每次循环都只是给循环因子重新赋值.

for 循环的各种格式
1. 无限循环格式: `for {}`
2. while格式: `for i<100{}`
3. 正常格式: `for i:=0;i<100;i++{}`
4. 使用range: `for i, v:=range slice/map{}`

#### range遍历
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

_对`for _, stu := range stus {}`遍历时, 每次循环都是值拷贝, i(这里是stu) 的地址是没有变化的. 所以最后m中的stu指向的都是同一个地址_

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