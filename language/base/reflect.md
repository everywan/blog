# 反射
反射是程序在运行时 访问/修改 自身状态或行为的能力.
反射是动态编程思想的一种, 是一种编程思想/技巧/概念.

个人认为, 动态编程在未来将产生重大的影响. 如要普及
编程教育, 通过动态编程设计更简单的语言实践. 或对于
AI等, 使用动态编程是程序更灵活.

用技术语言讲, 反射是实现一套系统, 能使程序在运行时
也能 访问/修改 程序当前的 状态/行为(如类/方法), 而
不是只能在编译前修改状态. 如程序可以在运行时根据条
件动态给类添加额外字段, 而不需要在写代码时预定义各
种类.

反射常用于第三方插件制作. 如当我们没有权限更改依赖
库时, 可以通过反射制作插件, 从而达到修改依赖库的目的.

反射也可以用于元数据编程, 从而减少重复工作量. 如在
gorm中, 需要动态对比两个值 v1/v2 来获取那些字段更新
了, 就可以通过反射自动比较/获取.

## 反射的实现
反射的实现可以按照语言类型分类, 
1. 解释型语言, 如Python. 解释型语言是动态语言, 一般没
  有类型, 在运行时可以直接访问/修改自身当前的状态和
  行为. 可以认为自带反射.
2. 编译型语言(特定平台运行), 如Java/C#, 编译出的代码
  是在 JVM/.Net 运行的. Java/C# 通过中间语言实现反射.
3. 编译型语言(机器码), 如C++/Go, 编译出的代码直接在
  机器执行. C++官方没有实现反射, Go 官方实现了反射.

语言具体分类参考 [语言分类](/language/language.md)

反射实现可以分为两部分,
1. 在运行时获取类信息
2. 在运行时更改类信息

### 运行时获取类信息
Java实现

首先将 `.java` 代码编译为 `.class` 代码,
然后 `.class` 在jvm执行. 而class文件中包含该类的所有
信息, 如类名, 字段, 方法. 程序通过访问 class 文件获取
类信息. C# 同理.

具体参考 [Java class file](https://en.wikipedia.org/wiki/Java_class_file)

----
Go 实现

Go的每一种类型都实现了 rtype, rtype 包含该类型的所有
信息(size,kind,method等).

Go内部定义了 emptyInterface 类型, 所有类型都可以转换
为 emptyInterface. 通过 `e.rtype` 获取该类型的rtype.

具体可参考如下代码
1. 通过 TypeOf/ValueOf 方法了解Go反射是如何实现的, 
  如何一步步找到类型信息的.
  - [reflect/type](https://github.com/golang/go/blob/master/src/reflect/type.go)
  - [reflect/value](https://github.com/golang/go/blob/master/src/reflect/value.go)
2. Go 运行时类型的信息 `_type`. 可以了解到在运行时,
  类型信息都有哪些, 如何定义, 以及怎样被赋值的.
  - [Go运行时type](https://github.com/golang/go/blob/master/src/runtime/type.go)

部分代码抄录
```Go
type emptyInterface struct {
	typ  *rtype
	word unsafe.Pointer
}
func TypeOf(i interface{}) Type {
	eface := *(*emptyInterface)(unsafe.Pointer(&i))
	return toType(eface.typ)
}
func (t *rtype) Method(i int) (m Method) {
  ...
}
```

----
C++ 官方没有实现反射. 因为基本无法更改C++源码, 所以无法
从根本上实现. 民间有通过读取类文件的方式魔法实现反射.

具体实现感兴趣的同学可以自己去查.

### 运行时更改类信息
当获取类信息后, 如果值是可被寻址(如指针类型), 直接更改
相应地址的值即可.

对于私有字段/非导出字段
1. private字段可以访问, 原则上可以修改但一般不允许.
2. java 可以修改访问权限, 修改private字段.
3. Go认为private字段是readonly的(flagEmbedRO), 所以程序
  上限制了修改. 当检测到修改非导出字段时直接报错.

关于Go对非导出字段的设置参考 `reflect/value.go` 的
CanSet方法.
[reflect/value](https://github.com/golang/go/blob/master/src/reflect/value.go)

## 反射的用法
反射用法三大原则
1. 从 interface{} 可以反射出对象.
2. 从反射对象可以获取 interface{} 变量. 即反射对象可
  以获取 类/值 的各种数据.
3. 要改变反射对象, 其值必须可设置(V.CanSet()).

三大原则参考
- [golang blog: The Laws of Reflection](https://blog.golang.org/laws-of-reflection)
- [Go 语言设计与实现](https://draveness.me/golang/docs/part2-foundation/ch04-basic/golang-reflect/)

Type 一般与类的类型/结构有关. 如获取子成员, 扩展函数,
tag标签, 也可以动态添加 字段/扩展函数.
- 扩展函数: 参考的C#的术语

Value 一般与运行时实例的值有关. 如获取/修改实例的值,
调用相关的方法. 也可以通过 Value 获取 Type 值.

常用的函数如下, 具体使用请参考文档
1. `TypeOf(interface{})` 获取传入值的类型. ValueOf 同理
2. `Elem()` 返回v持有的接口保管的值的Value封装, 或者
  v持有的指针指向的值的Value封装. 即当传入类型是
  interface/pointer 时, 通过Elem()获取真实类型.
3. `StructField` 字段值类型的封装, 描述结构体中的一个
  字段的信息.
3. `NumField() int` 返回结构体持有的字段总数(匿名字段
  算一个字段), 可以查找隐藏字段.
4. `Field(int) StructField` 获取index位置的字段信息.
  当结构体不变时, 排序是稳定的.
5. `FieldByName(string) (StructField,bool)` 根据类型
  名查找字段

反射使用示例
- 传入结构体, 构建 insert sql. 用于批量执行.
  [sqlbuilder](https://github.com/xgxw/foundation-go/blob/master/helper/sqlbuilder/sqlbuilder.go#L17)
- 通过反射将map值设置到struct
  [setfield](https://github.com/xgxw/foundation-go/blob/master/utils/reflect.go#L10)

### 反射在Java中的应用
<!-- deprecated -->
#### 注解
1. Java 注解: 以元数据的方式, 提供有关不属于程序本身的程序的数据. 注释对他们注释的代码的操作没有直接的影响.
    - https://docs.oracle.com/javase/tutorial/java/annotations/
1. C# 特性: 可以在CLR中添加类似于关键字的描述性声明称为特性.  特性使你能够将额外的描述性信息放到可使用运行时反射服务提取的元数据中
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

示例
1. 用处: 自动将方法注册到以该方法名为路径的web服务. 如定义了 ShowMsg() 方法, 则会自动注册 /ShowMsg 和处理器的绑定
    - **自动**将某个结构体(或者说类)的**所有方法**绑定到url路径
    - 根据相应的string执行相应的函数, 同时可以获取设置参数, 返回结果
5. [示例代码](/Lib/Reflect.go): 使用go语言实现

