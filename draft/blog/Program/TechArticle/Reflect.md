# 反射
> 参考: [go语言中文文档](https://studygolang.com/pkgdoc) reflect章节    
> 参考2: https://www.cnblogs.com/cxiaojia/p/6193606.html

<!-- TOC -->

- [反射](#反射)
    - [介绍](#介绍)
        - [常用](#常用)
        - [设置值](#设置值)
        - [数据结构](#数据结构)
    - [反射的主要应用](#反射的主要应用)
        - [注解](#注解)
    - [示例](#示例)

<!-- /TOC -->

## 介绍
以GO举例  
? 表示还不太了解该内容
### 常用
1. 遵循以下原则
    - `reflect.Value` 用来设置值,执行类的方法, `reflect.Type` 用来获取类的信息.
    - 只有公有成员可以被reflect改变值, 私有成员是无法改变
1. `func TypeOf(i interface{}) Type`: 接收任何的`interface{}`参数, 并且把接口中的动态类型以`reflect.Type`形式返回(具体类型)
    - 如果需要改变对象的值/调用其中的方法, 需要传递变量的地址
1. `func ValueOf(i interface{}) Value`:  接收任何的`interface{}`参数, 并将接口的动态值以`reflect.Value`形式返回(具体值)(`reflect.Value`也可以包含一个接口值)
2. ? `func (v Value) Elem() Value`: 以`reflect.Value`类型返回指针指向的变量(可以使用Isnil显式检测空指针)
2. `func (v Value) NumMethod() int`: 返回指定类型的公共方法的数目
2. 返回v持有值类型的函数形式的Value封装
    - `func (v Value) Method(i int) Value`: 获取第i个 函数形式的Value封装.(按照string顺序读取)
    - `func (v Value) MethodByName(name string) Value`: 根据方法名称 获取函数形式的Value封装
3. `func (v Value) Call(in []Value) []Value`: 通过反射执行方法
    - 示例: `v.MethodByName(cmd).Call(args)`
    - 设置参数: `args := []reflect.Value{reflect.ValueOf(msg[0])}`. 有多少个参数依次排列即可. reflect.ValueOf() 会自动对应到参数的类型
    - 获取返回值: Call 返回 []Value, `values[0].String()` 返回第0个返回值, 且其返回值是string类型(必须与函数值返回类型相同,否则会报错)
3. `NumIn() int`: 返回func类型的参数个数. (Type类型里有详细介绍)
    - `In(i int) Type`: 返回func类型的第i个参数的类型
3. `NumOut() int`: 返回func类型的返回值个数. (Type类型里有详细介绍)
    - `Out(i int) Type`: 返回func类型的第i个返回值的类型
3. `func (v Value) NumField() int`: 返回v持有的结构体类型值的字段数，如果v的Kind不是Struct会panic(即v必须是结构体类型)
    - `func (v Value) Field(i int) Value`: 返回结构体的第i个字段(的Value封装)
    - `func (v Value) FieldByName(name string) Value`: 返回该类型名为name的字段(的Value封装)(会查找匿名字段及其子字段)
    - `func (v Value) FieldByIndex(index []int) Value`: 返回索引序列指定的嵌套字段的Value表示，等价于用索引中的值链式调用本方法

### 设置值
1. 只有Elem()函数的返回值是可以寻址的
    ````
    x := 2
    a := reflect.ValueOf(2) // 等同于 reflect.ValueOf(x)
    b := reflect.ValueOf(&x) // 返回 *int, 不可寻址
    c := c.Elem() // int, 可以寻址
    ````
1. 可以使用 `CanAddr()` 方法判断 `reflect.Value`变量是否可寻址
2. 改变值
    ````
    x := 2
    d := reflect.ValueOf(&x).Elem() // d代表变量x
    // 方法一
    px := d.Addr().Interface().(*int)   // px := &x
    *px = 3 // 通过反射改变了x
    // 方法二
    d.Set(reflect.ValueOf(4))   // 变量类型需要和 ValueOf() 参数的类型相同
    ````

### 数据结构
1. Method 结构
    - `reflect.Type.Method(i)` 返回一个`reflect.Method`类型的实例, 描述这个方法的名称和类型
    - `reflect.Value.Method(i)` 返回一个`reflect.Value`, 代表一个方法值, 即一个已绑定接收者的方法
    - `reflect.Value.Method(i)` 可以调用Func类型的Value
    ````
    type Method struct {
        // Name是方法名。PkgPath是非导出字段的包路径，对导出字段该字段为""。
        // 结合PkgPath和Name可以从方法集中指定一个方法。
        // 参见http://golang.org/ref/spec#Uniqueness_of_identifiers
        Name    string
        PkgPath string
        Type  Type  // 方法类型
        Func  Value // 方法的值
        Index int   // 用于Type.Method的索引
    }
    ````
1. Value结构: Value为go值提供了反射接口. 可以包含一个任意类型的值
    - 在调用有分类限定的方法时, 可以使用Kind方法获知类型的分类. 调用该分类不支持的方法会导致运行时的panic
    ````
    type Value struct {
        // 内含隐藏或非导出字段
    }
    ````
1. Type结构: Type类型用来表示一个go类型, 是一个有很多方法的接口, 可以用来识别类型以及透视类型的组成部分. 接口的实现是类型描述符, 接口中的动态类型也是类型描述符
    ````
    type Type interface {
        // Kind返回该接口的具体分类
        Kind() Kind
        // Name返回该类型在自身包内的类型名，如果是未命名类型会返回""
        Name() string
        // PkgPath返回类型的包路径，即明确指定包的import路径，如"encoding/base64"
        // 如果类型为内建类型(string, error)或未命名类型(*T, struct{}, []int)，会返回""
        PkgPath() string
        // 返回类型的字符串表示。该字符串可能会使用短包名（如用base64代替"encoding/base64"）
        // 也不保证每个类型的字符串表示不同。如果要比较两个类型是否相等，请直接用Type类型比较。
        String() string
        // 返回要保存一个该类型的值需要多少字节；类似unsafe.Sizeof
        Size() uintptr
        // 返回当从内存中申请一个该类型值时，会对齐的字节数
        Align() int
        // 返回当该类型作为结构体的字段时，会对齐的字节数
        FieldAlign() int
        // 如果该类型实现了u代表的接口，会返回真
        Implements(u Type) bool
        // 如果该类型的值可以直接赋值给u代表的类型，返回真
        AssignableTo(u Type) bool
        // 如该类型的值可以转换为u代表的类型，返回真
        ConvertibleTo(u Type) bool
        // 返回该类型的字位数。如果该类型的Kind不是Int、Uint、Float或Complex，会panic
        Bits() int
        // 返回array类型的长度，如非数组类型将panic
        Len() int
        // 返回该类型的元素类型，如果该类型的Kind不是Array、Chan、Map、Ptr或Slice，会panic
        Elem() Type
        // 返回map类型的键的类型。如非映射类型将panic
        Key() Type
        // 返回一个channel类型的方向，如非通道类型将会panic
        ChanDir() ChanDir
        // 返回struct类型的字段数（匿名字段算作一个字段），如非结构体类型将panic
        NumField() int
        // 返回struct类型的第i个字段的类型，如非结构体或者i不在[0, NumField())内将会panic
        Field(i int) StructField
        // 返回索引序列指定的嵌套字段的类型，
        // 等价于用索引中每个值链式调用本方法，如非结构体将会panic
        FieldByIndex(index []int) StructField
        // 返回该类型名为name的字段（会查找匿名字段及其子字段），
        // 布尔值说明是否找到，如非结构体将panic
        FieldByName(name string) (StructField, bool)
        // 返回该类型第一个字段名满足函数match的字段，布尔值说明是否找到，如非结构体将会panic
        FieldByNameFunc(match func(string) bool) (StructField, bool)
        // 如果函数类型的最后一个输入参数是"..."形式的参数，IsVariadic返回真
        // 如果这样，t.In(t.NumIn() - 1)返回参数的隐式的实际类型（声明类型的切片）
        // 如非函数类型将panic
        IsVariadic() bool
        // 返回func类型的参数个数，如果不是函数，将会panic
        NumIn() int
        // 返回func类型的第i个参数的类型，如非函数或者i不在[0, NumIn())内将会panic
        In(i int) Type
        // 返回func类型的返回值个数，如果不是函数，将会panic
        NumOut() int
        // 返回func类型的第i个返回值的类型，如非函数或者i不在[0, NumOut())内将会panic
        Out(i int) Type
        // 返回该类型的方法集中方法的数目
        // 匿名字段的方法会被计算；主体类型的方法会屏蔽匿名字段的同名方法；
        // 匿名字段导致的歧义方法会滤除
        NumMethod() int
        // 返回该类型方法集中的第i个方法，i不在[0, NumMethod())范围内时，将导致panic
        // 对非接口类型T或*T，返回值的Type字段和Func字段描述方法的未绑定函数状态
        // 对接口类型，返回值的Type字段描述方法的签名，Func字段为nil
        Method(int) Method
        // 根据方法名返回该类型方法集中的方法，使用一个布尔值说明是否发现该方法
        // 对非接口类型T或*T，返回值的Type字段和Func字段描述方法的未绑定函数状态
        // 对接口类型，返回值的Type字段描述方法的签名，Func字段为nil
        MethodByName(string) (Method, bool)
        // 内含隐藏或非导出方法
    }
    ````

## 反射的主要应用
- 依赖注入

### 注解
**介绍**
1. Java_注解: 以元数据的方式, 提供有关不属于程序本身的程序的数据. 注释对他们注释的代码的操作没有直接的影响.
    - https://docs.oracle.com/javase/tutorial/java/annotations/
1. C#_特性: 可以在CLR中添加类似于关键字的描述性声明称为特性.  特性使你能够将额外的描述性信息放到可使用运行时反射服务提取的元数据中
    - CLR(公共语言运行时): 是Microsoft CLI(公共语中言基础结构)的一个商业实现. CLI是一种国际标准，用于创建语言和库在其中无缝协同工作的执行和开发环境基础. 
    - 可以这么理解: .NET类似于JVM,都是虚拟机. C#编写的代码会先翻译成 IL语言(中间语言), 然后运行于 .NET/JVM 之上.
    - https://docs.microsoft.com/zh-cn/dotnet/standard/attributes/index
2. 感觉注解的实现, 应该就是在编译程序时, 通过反射将注解(元数据)注入到被注解代码中.
2. 两者作用类似.
    - 作用于类,方法或者字段, 扩展数据的元数据. 并且通过反射取出元数据(注解中的数据)的值
    - AOP思想
    - 与反射密不可分

**注解原理**
1. 注解, 一种面向切面的编程思想(AOP), 通过注解给类/方法/字段添加相应的属性. 个人感觉,Java注解的学习可以参考C#的特性.
1. 定义类: `java.lang.annotation`
2. 用途
    - 编译器信息: 检测错误或者取消警告
    - 编译时/部署时处理: 一些框架工具可以处理注解并且生成代码,xml文件等等
    - 运行时处理: 有些注释可以在运行时检查
3. @Target注解: 标记另一个注释来限制可以应用注释的Java元素。目标注释指定以下元素类型之一作为其值：
    - ElementType.ANNOTATION_TYPE 应用于注释类型。
    - ElementType.CONSTRUCTOR 应用于构造函数。
    - ElementType.FIELD 应用于一个领域或财产。
    - ElementType.LOCAL_VARIABLE 应用于局部变量。
    - ElementType.METHOD 应用于方法级别的注释。
    - ElementType.PACKAGE 应用于包装声明。
    - ElementType.PARAMETER 应用于方法的参数。
    - ElementType.TYPE 应用于任何类的元素。
3. @Inherited注解: 具有继承性（默认情况下不是这样）. 当用户查询注释类型并且类没有这个类型的注释时，查询该类的超类的注解类型。这个注解只适用于类声明。
3. @Repeatable: 重复注释(java8之后支持). 使注解定义为可重复的(可以重复注解一个类)
3. @Retention: 注解保留的时间
    - RetentionPolicy.CLASS: 编译器将把注释记录在class文件中。当运行Java程序时，JVM不在保留注释，这是默认值。
    - RetentionPolicy.RUNTIME: 编译器将把注释记录在class文件中。当运行Java程序时，JVM也会保留注释，程序可以通过反射获取该注释。
    - RetentionPolicy.SOURCE:  注解仅存在于源码中，在class字节码文件中不包含。
4. @Documented: 指定该元Annotation修饰的Annotation类将被javadoc工具提取成文档，如果定义Annotation类时使用了@Documented修饰，则所有使用该Annotation修饰的程序元素的API文档中将会包含该Annotation说明。
5. ? 只能通过反射获取注解中的值

## 示例
1. 用处: 自动将方法注册到以该方法名为路径的web服务. 如定义了 ShowMsg() 方法, 则会自动注册 /ShowMsg 和处理器的绑定
    - **自动**将某个结构体(或者说类)的**所有方法**绑定到url路径
    - 根据相应的string执行相应的函数, 同时可以获取设置参数, 返回结果
5. [示例代码](/Lib/Reflect.go): 使用go语言实现