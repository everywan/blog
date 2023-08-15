## sbt 
- 中文文档: https://www.scala-sbt.org/release/docs/zh-cn/Basic-Def.html
- 英文文档: https://www.scala-sbt.org/1.x/docs/index.html

1. 执行 sbt 进入命令行交互模式
2. 批处理: `sbt clean compile "testOnly TestA"`, 命令如有参数, 则使用`""`包裹起来, 如其中的 testOnly


常用命令

| 命令      | 介绍  |
|:----------|:---   |
| compile   | 编译  |
| `~compile`| 持续构建测试(`~`对于其他命令也适用), 即当文件变化时自动重新编译  |
| package   | 将代码和资源打包为一个jar(`src/main/resources java scala`)  |
| reload    | 重新加载构建定义(`build.sbt project/*.scala *.sbt`)  |
| run       | 执行主类  |
| taskname  | 直接输入在 sbt 文件中定义的taskname, 即可执行相应的task  |
| show      | 显示 sbt 根路径定义的变量, 如 version 等, 多项目的话会显示多个  |
| `!:`      | 显示所有历史命令  |
| `!:n`     | 显示前N条历史命令  |

### 构建定义
直到项目被重新加载前, 一个设置有一个固定的值.

```Scala
# 多项目构建
lazy val utilProject = (project in file("util")).settings(...)

# Key Type
# settingKey: 只计算一次的key
var jdbc = settingKey[String]("...")
# taskKey: 定义一个task, 每次执行task都会重新计算
var clean = taskKey[Unit]("...")
```

### 目录结构
````
build.sbt       # 项目构建代码
project/        # 根项目 build.sbt 的元构建代码, project 项目可递归, 递归项目为上层项目的元构建代码.
  <*.scala, defines helper objects and one-off plugins>
  build.scala   # 元构建根项目的一个源文件
  build.sbt     # 元元构建项目的根项目
  project/      # 如上, 根项目元构建代码的 元构建代码, 即元元构建, 可重复 0到多次.
src/
  main/
    resources/
       <files to include in main jar here>
    scala/
       <main Scala sources>
    java/
       <main Java sources>
  test/
    resources
       <files to include in test jar here>
    scala/
       <test Scala sources>
    java/
       <test Java sources>
target/
  <Generated files>
````

## scala
部分用法可以 想当然/参考kotlin/参考java/参考其他语言

- scala 没有 static, 实例默认是val, 即不可变实例.
- case class: 样例类, 一般用于模式匹配.
  - 默认实现 toString,hashCode,copy,equals方法
  - 默认可以序列化
- object: 在scala中, object 包含自己的定义, 并且是自己定义的唯一单例. 可以理解为单例.
- trait: 特征类型, 包含多个方法和字段. 其实就是接口, interface. class 可以 extend 一个或多个 trait.
  - 可以包含默认实现


语法糖
- `_`: https://my.oschina.net/joymufeng/blog/863823
  - 作为通配符: `import scala.math._`
  - `:_*`: 将参数作为参数序列处理 `val s = sum(1 to 5:_*)`, 将 1到5 作为参数序列处理
  - 一个集合中的每个元素. `a.filter(_%2)` a 中的没一个元素
  - 元组中, 使用 `_1/_2` 等访问组员
  - 在 class 中, 有参数 x, `def x_ = ...` 表示在getter之后执行. 参考: https://docs.scala-lang.org/tour/classes.html

```Scala
// Function: lambda函数, 匿名函数
val X = (x: Int)=>x+1
// Methods: 使用def定义, 可以指定返回类型
def add(x: Int):Int = x+1
// case class
case class Point(x: Int, y: Int)
// trait
trait Greeter{
  def greet(name:String): Unit
}
```

类型系统: https://docs.scala-lang.org/tour/unified-types.html
- top type: Any, 空值为 Nothing
  - 值类型: AnyVal类型, 与其他语言同
  - 引用类型: AnyRef类型, 继承自 `java.lang.Object`, 空值为Null
