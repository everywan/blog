## gradle

kts: kotlin script

Gradlew: 对 gradle 的封装, 因为不是每个人的电脑中都安装了gradle，也不一定安装的版本是要编译项目需要的版本，那么gradlew里面就配置要需要的gradle版本，然后用户只需要运行gradlew就可以按照配置下载对应的gradle到项目的目录中，仅仅给项目本身用，然后就是clean、build等操作，但是如果执行gradle clean 这样的命令的话，系统使用的是电脑环境变量中配置的gradle，或者是找不到命令。此时我们就用gradlew clean这个命令，其实内部调用的是本项目中的gradle来执行的，所以就相当于进行了一次包装。

https://www.zybuluo.com/xtccc/note/275168

https://www.kotlincn.net/docs/reference/using-gradle.html


kotlin + gradle hello world 教程

参考: https://www.520mwx.com/view/17430

分为以下步骤
1. 创建项目: `mkdir hellp && cd hello`
2. 使用 gradle 初始化项目: `gradle init --type java-application`
  - 此处先初始化为 java 项目, 后续通过更改文件改为 kotlin 项目
3. 删除gradleew辅助文件, 作用参考上述: `rm -rf src/main/java src/test/java gradle gradlew gradlew.bat`
4. 编辑 build.gradle, 使之符合规范. 具体教程参考:
  - [kotlin gradle 官方文档](https://www.kotlincn.net/docs/reference/using-gradle.html)
  - [kotlin gradle helloworld](https://github.com/Kotlin/kotlin-examples/tree/master/gradle/hello-world)
5. 创建 kotlin 源代码文件夹: `mkdir -p src/main/kotlin src/test/kotlin`
  - 按照规范, `src/main/kotlin` 为 kotlin 源码, `src/main/java` 为java源码. 如果按照其他规范组织源码的, 需要在 gradle 中配置kotlin源码路径. 具体参照上述 gradle 文档.
6. `vim src/main/kotlin/App.kt`: 
  ```Kotlin
  fun main(args: Array<String>) {
    println("hello kt")
  }
  ```
6. 配置完成, 运行: 
  - 生成 jar: `kotlinc src/main/kotlin/App.kt -include-runtime -d bin/main/hello.jar`
  - 运行: `java -jar bin/main/hello.jar`

buildscript中的声明是gradle脚本自身需要使用的资源。可以声明的资源包括依赖项、第三方插件、maven仓库地址等。而在build.gradle文件中直接声明的依赖项、仓库地址等信息是项目自身需要的资源。

gradle 打包 kotlin 项目

Dokka: 生成文档


Spark提供了两种创建RDD的方式：读取外部数据集，以及在驱动器程序中对一个集合进行并行化


https://www.tutorialkart.com/apache-spark/spark-rdd-map-java-python-examples/

https://github.com/jackiehff/spark-reference-doc-cn/

https://github.com/apache/spark/blob/master/examples

`PairFunction<T,K,V>`: 接受T元素, 返回 `<K, V>`. `JavaRDD<Int>.mapToPair(new PairFunction<Int,String,Payment>()`, T 即 Int, 返回的PairRDD 为 K=String,V=Payment.

rdd dataset dataframe
https://www.jianshu.com/p/71003b152a84

spark 本地环境测试: 直接下载二进制包, 放到$PATH 中, gradle run 项目就可以自动调用spark.


在kotlin中
```Kotlin
// 如下写法会有问题, 使用run等scope函数时, 在kotlin中会将 this 包含进来(误, 自以为, 没有认证).
// 而根据 spark/rdd 的规则, 当 filter/map 中含有外部变量时, 外部变量必须是可被序列化的. 所以在 filter/map 中不能使用 run 等函数, 直接写相关代码即可
rdd.filter { item -> 
  // run{} 错误,
  println(item)
  code...
}
```

gradle/maven providedCompile 函数由: `id:war` 插件提供
