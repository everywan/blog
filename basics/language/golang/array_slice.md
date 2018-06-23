<!-- TOC -->

- [Go数组/切片](#go数组切片)
    - [Go-数组](#go-数组)
    - [切片](#切片)
        - [切片的数据结构](#切片的数据结构)
        - [切片声明&&定义](#切片声明定义)
        - [步长](#步长)
        - [切片range](#切片range)
        - [切片拷贝](#切片拷贝)
            - [练习题一:切片默认值](#练习题一切片默认值)
        - [append](#append)
            - [习题一:理解append和扩容](#习题一理解append和扩容)
            - [习题二:append练习](#习题二append练习)
        - [其他合并方法](#其他合并方法)
            - [byte数组/切片合并](#byte数组切片合并)
        - [遍历](#遍历)
        - [陷阱](#陷阱)
            - [切片引用导致GC无法回收](#切片引用导致gc无法回收)

<!-- /TOC -->

# Go数组/切片
> 参考 [Go 切片:用法和本质](https://blog.go-zh.org/go-slices-usage-and-internals)

1. [数组定义](/Program/TechArticle/Array.md)

## Go-数组
1. 声明
    - 常规: `var array []int` 声明一个固定长度的数组, 默认长度为0, 下标不可超过数组长度.
    - 声明&初始化: `array := [...]int{1, 2}`, 注意, `...`表示自动统计数量, 不加 `...` 则表示声明切片 
2. Go语言中, 数组是 **值类型**. 
    - 即拷贝一个数组, 是将所有值拷贝过去, 而不是拷贝指针.
    - 同理, 因为数组是值类型, 所以函数传值时, 传递的参数是数组的拷贝, 而不是该数组的指针.
    - 同其他语言一样, 数组的大小是数组属性的一部分.
3. 数组的零值是其各元素的默认值, 如 `[3]int` 即 `[0 0 0]`

## 切片
### 切片的数据结构
    ```Go
    struct Slice
    {   // must not move anything
        byte*     array;      // actual data,                   指针 指向数组的某个位置
        uintgo    len;        // number of elements,            表示从指针指向位置 向后取多少个元素
        uintgo    cap;        // allocated number of elements,  表示该数组的最大长度
    };
    ```
1. 切片定义: **切片是数组某个部分的引用**, 是引用类型
    - 切片的长度不能超过数组长度 或者说 cap
2. 对于切片, 需要注意, 切片本身的值, 切片地址, 切片元素指向的地址, 是不同的. 就像 指针, 指针地址, 指针指向的地址 是不同的. 首先要学会区分这三个区别. 举例如下
    - `fmt.Printf("%p\n", &s[0])`: 切片中第一个元素的地址
    - `fmt.Printf("%p\n", &s)`: 该切片的地址(即切片结构体的地址, 而非其中元素), 因为切片本身也是一个结构体.
    
### 切片声明&&定义
1. 通过make: 函数签名: `func make([]T, len, cap) []T`
    - T表示类型, length表示初始长度, cap表示切片最大容量, 不指明 cap 时,1.ap=len.
2. 通过数组: `var array [10]int; slice := array[0:5:10]`
    - 格式为: `array[pos,_len,_cap]`
    - len: `_len-pos`, cap: `_cap-pos`
3. 通过切片: `sa := make([]int,5,10); slice := sa[3:4:cap]`
    - len/cap 与数组方式相同
    - 需要注意的是, `slice[1:2:cap]` 方法定义了一个新切片, 而不是在原切片上操作/取值.
4. 声明&初始化: `slice := []int{1,2,3}`
    - 等同于 make + 赋值.
5. 切片默认值
    - 只声明切片时, 不分配内存, 切片的零值是nil. 长度为0的切片是 `make([]T,0)`, 不是 nil(分配了空间).
    - 切片定义后, 在 **len** 内, 切片元素初始化为其类型的默认值. 如 int 初始化为0, string 初始化为 `""`

### 步长
1. 切片步长的取值是直接在原切片对应的底层数组上取值, 然后创建一个新的 slice, 指向数组的新位置. (如果 slice 是从数组取值的, 那么是在计算 slice 偏移之后. 如果 slice 是直接定义的, 那么类似于偏移量=0).
    - 举例如下: `a := make([]int,5,10); b:=[6:10]`, b 内容为指向`[0 0 0 0]`, len==cap==4 的切片
    - 所以, 切片步长是直接在原切片对应的数组上取值/定义新切片的, 只要不超过 cap, 那么就不会报错.
2. `a[:]` 的默认值: 因为 步长是按照 左闭右开 计算的, 为了保证可以取到所有值, 所以 左侧默认值为0, 右侧默认值为 len.
3. 阅读源码, 验证以上结论
    - 步长如何取值的? 是不是直接在数组/原切片指向的底层数组上取值的?
    - `a[:]`的默认值是什么?

### 切片range
1. 对 slice 使用 range 循环时, range 会预先计算 slice 的 len, 然后循环. 也就是说, range 只会循环 slice 中的 len 部分.
2. 问题
    - 查看 range 源码, 研究看如何实现的.

### 切片拷贝
1. 切片拷贝: slice拷贝只是拷贝slice结构体本身, 不影响真实数据, 即新slice与原slice中的元素地址相同.
    - 因为切片是一个结构体, 在结构体中定义了指针指向数组. 所以不管是slice的深复制或者浅复制, slice中的指针指向的地址都不变, 即数组中的真实数据也就不变.
    
#### 练习题一:切片默认值
1. 练习: 预测以下函数输出, 解释原因
    ```Go
    func main() {
        s := make([]int, 2)
        s = append(s, 1, 2, 3)
        fmt.Println(s)
    }
    ```
    - _输出[0 0 1 2 3]_
    - 切片声明后, 切片元素都是其初始化值. 因为append是在len之后追加数据, 所以append追加元素不会覆盖初始值.
2. 切片默认值与nil
    ```Go
    func main() {
        var aa []int
        var bb = make([]int, 0)
        fmt.Println(aa == nil)
        fmt.Println(bb == nil)
    }
    ```
    - _未初始化的slice是nil, 但是 长度为0的slice不是nil_
3. json库如何处理 slice零值(nil) 和 空值(长度为0)
    ```Go
    func main() {
        var aa []int
        test(aa)
        var bb = make([]int, 0)
        test(bb)
    }
    func test(aa []int) {
        json, _ := json.Marshal(aa)
        fmt.Println(string(json))
    }
    ```
    - _nil slice被序列化为`null`, 空值被序列化为 `[]`_

### append
> 此小节可以通过习题例子学习/验证
>
> 参考: [深入解析 Go 中 Slice 底层实现](https://halfrost.com/go_slice/)

1. append()源码:
    ```Go
    func append(slice []Type, elems ...Type) []Type
    ```
    ```Go
    // reflect中的append定义
    // Append appends the values x to a slice s and returns the resulting slice.
    // As in Go, each x's value must be assignable to the slice's element type.
    func Append(s Value, x ...Value) Value {
        s.mustBe(Slice)
        s, i0, i1 := grow(s, len(x))
        for i, j := i0, 0; i < i1; i, j = i+1, j+1 {
            s.Index(i).Set(x[j])
        }
        return s
    }
    ```
    - `...Value` 表示 变长参数
    - 传入/返回的参数都必须是slice, 不能是数组
    - append() 返回值是一个新的slice结构体(查看源码便知). 但是 新/老切片 中指针是否变化根据扩容规则而定
        - 即: append() 返回的 slice 地址与 传入的 slice 地址不同
        - 但是, 传入slice/返回slice 的 指针/len/cap 是否相同取决于 扩容规则
2. 扩容规则
    - 如果切片的容量小于 1024 个元素, 扩容时容量翻倍. (`if cap<1024{cap=cap*2}`)
    - 如果切片的容量大于等于 1024 个元素, 扩容时容量增加1/4. (`if cap<1024{cap=cap*1.25}`)
    - 注意: 扩容扩大的容量都是针对原来的容量而言的, 即原来的**切片**的**cap**, 不是数组.
3. `s = append(s, 1, 2, 3)`, s 是新地址还是老地址
    - 如果 s 的cap够用, 则会直接在 s 指向的数组后面追加元素, 返回的slice和原来的slice是同一个对象.
    - 如果 s 的cap不够用, 则会重新分配一个数组空间用来存储数据, 并且返回指向新数组的slice. 这时候原来的slice指向的数组并没有发生任何变化
    - 在任何情况下, 返回的结果都是追加之后的slice

#### 习题一:理解append和扩容
1. 预测以下函数输出, 解释原因
    ```Go
    func print(s []int, x string) {
        fmt.Printf("%s = %v, Pointer = %p, len = %d, cap = %d\n", x, s, &s[0], len(s), cap(s))
    }

    func main() {
        s := []int{5}
        print(s, "s")
        s = append(s, 7)
        print(s, "s")
        s = append(s, 9)
        print(s, "s")
        x := append(s, 11)
        print(x, "x")
        y := append(s, 12)
        print(y, "y")
        z := append(y, 13)
        print(z, "z")
    }
    ```
    - 输出如下
        ````
        s = [5], Pointer = 0xc4200200c8, len = 1, cap = 1
        s = [5 7], Pointer = 0xc420020100, len = 2, cap = 2
        s = [5 7 9], Pointer = 0xc420012340, len = 3, cap = 4
        x = [5 7 9 11], Pointer = 0xc420012340, len = 4, cap = 4
        y = [5 7 9 12], Pointer = 0xc420012340, len = 4, cap = 4
        z = [5 7 9 12 13], Pointer = 0xc4200221c0, len = 5, cap = 8
        ````
    - 验证以下结论
        - 扩容规则
        - append 返回切片: 当cap足够大时返回老切片地址, 当cap需要扩容时返回新切片的地址

#### 习题二:append练习
1. 练习: 预测以下函数输出, 解释原因
    ```Go
    func main(){
        s := []int{5}
        s = append(s, 7)
        s = append(s, 9)
        x := append(s, 11)
        y := append(s, 12)
        fmt.Println(s, x, y)
    }
    ```
1. 答案: _[5 7 9] [5 7 9 12] [5 7 9 12]_
    - 原因: _由slice的扩容机制可知, 在 `s = append(s, 9)` 时, `cap(s)==4`, 所以 x/y 赋值时, 切片并没有扩容_
        1. s地址: `[5 7 9]`, 相对地址: `[0x00 0x01 0x02]` len=3, cap=4.
        2. x 追加元素: `[5 7 9 11]`, 因为 s 的 cap 足够大, 不需要扩容, 所以相对地址为: `[0x00 0x01 0x02 0x03]`
        3. y 追加元素: `[5 7 9 12]`, 因为 s 的 cap 足够大, 不需要扩容, 所以相对地址为: `[0x00 0x01 0x02 0x03]`
        3. y追加元素时, 复写了 0x03 的值, 所以 输出 x/y 的值相同
    - 参考: https://www.zhihu.com/question/27161493

### 其他合并方法
1. copy(): 先计算出总长度, 然后根据切片赋值
    ```Go
    a := []byte("aaa")
    b := []byte("bbb")
    var c = make([]byte,len(a)+len(b))
    copy(c, a)
    copy(c[len(a):], b)
    ```
#### byte数组/切片合并
1. `bytes.Join()`
    - 函数签名: `func Join(s [][]byte, sep []byte) []byte`: 将一系列[]byte切片连接为一个[]byte切片, 之间用sep来分隔, 返回生成的新切片
    ```Go
    BytesCombine([]byte("aaa"),[]byte("ccc"),[]byte("ccc"))
    func BytesCombine(pBytes ...[]byte) []byte {
        return bytes.Join(pBytes, []byte())
    }
    ```
2. `bytes.buffer`: 一个实现了读写方法的可变大小的字节缓冲区, 零值是一个空的可供读写的缓冲, 使用 `bytes.NewBuffer()` 创建
    - 函数签名: `func NewBuffer(buf []byte) *Buffer`: 使用buf作为初始内容创建并初始化一个Buffer. buf会被作为返回值的底层缓冲切片(即返回切片的地址与buf相同)
    ```Go
    buffer := bytes.NewBuffer(_content)
    buffer.WriteByte(byte(0))
    buffer.Write([]byte{0,60})
    buffer.Write([]byte{0,10})
    buffer.Write([]byte{0,60})
    ```

### 遍历
> 需要注意的是, for循环中, 对于每次循环, **变量i指针不变**, 每次都是将元素的值拷贝到i.   
> 参考 [Go循环](/blog/Program/Language/Golang/Advanced.md#循环)
1. 常规for循环
    ```Go
    for i := 0; i <len(mySlice); i++ { 
        fmt.Println("mySlice[", i, "] =", mySlice[i])
    }
    ```
2. range
    ```Go
    for index, value := range mySlice { 
        fmt.Println("mySlice[", index, "] =", value)
    }
    ```

### 陷阱
#### 切片引用导致GC无法回收
1. 因为切片不复制底层数组, 而整个数组被保存在内存中, 直到数组不被引用才会被GC. 所以, 存在因为一个切片被使用而导致整个数组的内存不被释放的情况
    - 示例: 遍历文件, 从文件中取出 指定位置/大小 的内容, 以切片形式返回. 如此便会导致整个数组不会被GC
    ```Go
    var digitRegexp = regexp.MustCompile("[0-9]+")
    func FindDigits(filename string) []byte {
        b, _ := ioutil.ReadFile(filename)
        return digitRegexp.Find(b)
    }
    ```
1. 解决
    - 将要返回的slice保存到一个新的slice或者数组中
