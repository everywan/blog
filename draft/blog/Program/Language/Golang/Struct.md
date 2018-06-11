<!-- TOC -->

- [结构体](#结构体)
    - [结构体方法](#结构体方法)
        - [指针类型还是值类型](#指针类型还是值类型)
        - [扩展方法-接口继承](#扩展方法-接口继承)
    - [结构体标签](#结构体标签)
    - [引用](#引用)
        - [C#扩展方法](#c扩展方法)

<!-- /TOC -->
# 结构体
1. 结构体中字段值有默认初始化, `string -> "", int -> 0` 等等

## 结构体方法
1. 方法接收者: 出现在 func 关键字和方法名之间的参数中.
    - 可以参考 C# 的扩展方法, 比较类似. ([C#扩展方法](https://docs.microsoft.com/zh-cn/dotnet/csharp/programming-guide/classes-and-structs/extension-methods))
2. 注意, 对于结构体方法/扩展方法, 扩展方法中**接收到的结构体**是**扩展方法调用者**的值拷贝. 具体见示例.
    - 所以, 一般推荐扩展方法使用 指针类型实现.
3. 示例: i 是 influx1 的值拷贝, 所以在 init 方法中更改 i 的值时, influx1 的值不会变化.
    ```Go
    var influx1 influxdbHelper

    type influxdbHelper struct {
        host string
    }

    func main() {
        influx1 = influxdbHelper{}
        fmt.Printf("%p\n", &influx1)
        influx1.init()
        fmt.Printf("%p\n", &influx1)
        fmt.Println(influx1)
    }

    func (i influxdbHelper) init() error {
        fmt.Printf("%p\n", &i)
        i.host = "aaaa"
        fmt.Println(i)
        return nil
    }
    ```
### 指针类型还是值类型
1. 因为结构体方法收到的是调用者的值拷贝, 所以使用值类型时会造成更大的空间占用. 所以, 对指针比较熟的情况下, 推荐使用指针.

### 扩展方法-接口继承
1. 若使用扩展方法实现interface时, 必须保持方法接收者与接口定义的**类型相同**(即指针类型则都为指针类型,值类型都为值类型)
2. 示例: 以下程序的输出和原因
    ```Go
    type People interface {
        Speak(string) string
    }
    type Stduent struct{}
    func (stu *Stduent) Speak(think string) (talk string) {
        if think == "bitch" {
            talk = "You are a good boy"
        } else {
            talk = "hi"
        }
        return
    }
    func main() {
        var peo People = Stduent{}
        think := "bitch"
        fmt.Println(peo.Speak(think))
    }
    ```
2. 答案: _运行错误, 因为Struct没有实现People的Speck方法, 所以不能用 Student 实例化 People 对象._
    - 解释: People 的 Speck() 是值类型的, 而 Student 实现的 Speck() 是指针类型. 两者类型不同
    
## 结构体标签
> 参考: http://www.01happy.com/golang-struct-tag-desc-and-get/

1. 结构体标签: 标签是结构体的可选字段, 用于标记结构体字段
    - 当序列化结构体为其他格式时(如JSON/BSON等), go 会读取tag内相应的字段作为键值
    - 截止到目前(2018.06), 除了go自动读取外(底层也是reflect包读取), 只能使用 reflect包 获取tag内容.
2. 为什么需要tag: 
    - 在golang中, 命名都是推荐都是用驼峰方式, 并且在首字母大小写有特殊的语法含义: 包外无法引用. 当与其他程序交互数据时, 因为 go 字段的首字母大小写有规定, 导致不符合其他程序的规范. 这是标签必须存在的原因.
    - 与不通程序交互时, 每个字段可能有不同的名称: 如字段名为 Id, 序列化为 bson 时为 `_id`, 序列化为 json 时为 id. 使用tag标签可以满足数据格式的多种需求.
3. 示例:
    ```Go
    type test struct{
        Testid int `json:"id"`
    }
    // json编码结构体, 会自动读取tag内容并设置key值
    u := &User{Testid: 1}
    j, _ := json.Marshal(u)
    // 使用反射读取键值, 自定义使用
    t := reflect.TypeOf(u)
    field := t.Elem().Field(0)
    fmt.Println(field.Tag.Get("json"))
    ```

## 引用
### C#扩展方法