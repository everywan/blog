<!-- TOC -->

- [Java编程语言](#java编程语言)
    - [基础](#基础)
        - [多进程和多线程](#多进程和多线程)
        - [JDBC](#jdbc)
            - [示例](#示例)
        - [泛型](#泛型)
        - [系统相关类:System](#系统相关类system)
            - [字段](#字段)
            - [方法](#方法)
        - [时间操作](#时间操作)
        - [文件读写](#文件读写)
            - [从url地址获取文件流](#从url地址获取文件流)
            - [写入文件](#写入文件)
        - [==/equal](#equal)
        - [接口回调](#接口回调)
    - [习题](#习题)
    - [数据库连接池](#数据库连接池)
        - [Durid](#durid)
    - [Maven](#maven)
        - [maven配置jar的打包方式](#maven配置jar的打包方式)
        - [maven_项目模块本地jar依赖_ClassNotFound](#maven_项目模块本地jar依赖_classnotfound)
        - [maven_多环境配置](#maven_多环境配置)

<!-- /TOC -->

# Java编程语言

## 基础
1. java bean: JavaBean是一种规范, 为外部工具/框架提供统一的处理规范
    - 参考: https://www.zhihu.com/search?type=content&q=bean
    - spring中,在项目中定义的bean.xml文件均可通过函数加载到内存,然后通过gebBean()或类似函数加载到对象中
    - bean 规范如下:
        - 有一个public的无参构造函数: 实例化对象
        - 属性可以通过get/is, set方法或者遵循特定命名规范的其他方法访问:为了获取/设置字段的值
        - 可序列化(实现java.io.Serializable接口): 为了保存对象的状态
2. [字符串的拼接方式](/Program/Language/summary.md#字符串的拼接方式)
3. java8中新加的有意思的 **Map函数**
    - `map.computeIfAbsent()`: 如果指定的key不存在, 则通过指定的匿名函数计算出新的值设置为key的值
        - 示例: `map1.computeIfAbsent(key, value -> map2.get(_key));`
    - `map.computeIfPresent(key, lambda/匿名函数)`: 如果指定的key存在, 则根据匿名函数求出新值newValue, 如果newValue不为null, 则设置newValue为key对应的value, 如果newValue为null, 则删除该key
        - 示例: `map1.computeIfPresent(key,(_key, value) -> map2.get(_key) + value);`
    - `map.compute()`: computeIfAbsent与computeIfPresent的综合
    - `map.merge(key, newValue, BiFunction<? super V, ? super V, ? extends V> remappingFunction)`: 如果指定的key不存在, 则设置newValue为value值, 否则根据newValue和value通过BiFunction计算得到新值. 如果newValue为null, 则删除该key. 
    - `map.putIfAbsent()`
    - `map.replace(key,value)/replace(key,oldvalue,newvalue)`: 替换值／当值与旧值相同时才替换为新值
    - `map.remove(key,newvalue)`: 当值与newvalue相同时执行remove操作
4. 创建Lambda表达式: Lambda表达式只能用来简化仅包含一个public方法的接口的创建
    ```Java
    // http://www.voidcn.com/article/p-zwxskzpm-bdp.html
    public interface In {
        int func(int a,int b,int c);
    }
    In in =(a,b,c)->a+b+c;
    In in1 =(a,b,c)->{
        return a+b+c;
    };
    // 或者使用java8中部分类自带的lambda函数
    List<String>.foreach(s->{})
    ```
5. final修饰的基础类型不可以修改, 但是final修饰的 map/list 依然是可以 put/add 的
6. json 转换 map: `HashMap<String,Object> result = new ObjectMapper().readValue(response, HashMap.class);` 
7. Scanner: 基于正则表达式的文本扫描器, 可以从文件,输入流,字符串中解析出基本类型和字符串类型的值, 支持多行, 

### 多进程和多线程
> [多进程和多线程](/Program/TechArticle/ThreadAndProcess.md)  

### JDBC
> 参考: [executeQuery/executeUpdate/execute的区别](http://zhangyinhu8680.iteye.com/blog/1295744)
1. `execute()`, `executeQuery()`, `executeUpdate()` 区别
    - `execute()`: 允许执行查询语句, 更新语句, DDL(Create/Update等)语句, 返回 Boolean
        - 返回值为true时, 表示执行的是查询语句, 可以通过`getResultSet()`方法获取结果
        - 返回值为false时, 执行的是更新语句或DDL语句, 通过`getUpdateCount()`方法获取更新的记录数量
    - `executeQuery()`: 允许执行 SQL查询 语句, 返回单个 `ResultSet` 对象
    - `executeUpdate()`: 允许执行 INSERT, UPDATE, DELETE 或 DDL(Create/Update的) 等不返回内容语句, 返回更新计数

#### 示例
```Java
public void getNearPoint(String tableName){
    Class.forName(JDBC_DRIVER);
    String dbUrl = String.format("jdbc:mapd:%s:%d:%s","this.domain","this.port","this.database");
    Connection conn = null;
    Statement ps = null;
    try {
        conn = conn = DriverManager.getConnection(dbUrl,"userName","password");
        ps = conn.createStatement();
        String sql = String.format("select * from %s ",tableName);
        ResultSet rs = ps.executeQuery(sql);
        if(rs.wasNull()){
            return;
        }
        while(rs.next()){
            System.out.println(rs.getDouble("distance"));
        }
        rs.close();
        ps.close();
    }catch (SQLException e){
        logger.error("Flush Mapd 抛出 SQLException, 错误信息: "+e.getMessage());
        e.getStackTrace();
    }finally {
        try {
            conn.close();
        }catch (SQLException e){
            e.getStackTrace();
        }
    }
    return;
}
```

### 泛型
> 参考: [java 泛型详解](http://blog.csdn.net/s10461/article/details/53941091)
1. 泛型的三种使用方式: 泛型类, 泛型接口, 泛型方法
    - 所有泛型方法声明都有一个类型参数声明部分, 位于: `public <T> 返回值`
    - 泛型方法体的声明和其他方法一样. 注意类型参数只能代表引用型类型, 不能是原始类型(像int,double,char的等)
    ```Java
    // 泛型类
    public class Generic<T>{ 
        //key这个成员变量的类型为T,T的类型由外部指定  
        private T key;
    }
    // 泛型类的定义和实现
    public class Pair<T,V>{
        public Pair(){}
        public Pair(Map<? extends K, ? extends V> map){}
    }
    Pair<String, Integer> pair = new Pair<String, Integer>(null);

    // 泛型接口
    public interface Generator<T> {
        public T next();
    }
    // 泛型方法
    public <T> T genericMethod(Class<T> tClass)throws InstantiationException ,
    IllegalAccessException{
            T instance = tClass.newInstance();
            return instance;
    }
    ```
3. `?` 标示类型通配符
    - `static <K, V> Map<K, V> unmodifiableMap(Map<? extends K, ? extends V> var0) {}`
    - `? extends K` 表示参数的key要是K类或者其子类的对象

### 系统相关类:System
> java.lang.System
> 参考: [介绍](http://blog.csdn.net/quinnnorris/article/details/71077893?utm_source=gold_browser_extension) 
> [深度解析](https://www.cnblogs.com/afraidToForget/p/6625357.html)

1. 不可实例化: System类的构造器由private修饰, 不允许被实例化. 因此, 类中的方法也都是static修饰的静态方法.
#### 字段
- 标准输入流: `public final static InputStream in;`
- 标准输出流: `public final static PrintStream out;`
- 标准错误流: `public final static PrintStream err;`
#### 方法
1. `System.currentTimeMillis()`: 返回毫秒数. 获取的是操作系统的时间
2. `System.getPropertys()`: 获取系统属性(主要与 Jdk 和 当前运行程序相关的值)
    - `System.getProperty(user.dir)`获取当前程序运行路径. 
        - tomcat容器运行的项目中, 获取的是 `~/tomcat/webapps`(tomcat的运行路径)
2. `System.getEnv()`: 获取操作系统环境变量相关信息
3. `System.gc()`: 回收未用对象或失去了所有引用的对象
4. `System.exit(int)`: 终止当前正在运行的 Java 虚拟机. 参数解释为状态码

### 时间操作
1. 示例: 
    `String time = LocalDateTime.parse("20170706001400",DateTimeFormatter.ofPattern("yyyyMMddHHmmss")).plusHours(1).format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")).toString();`
2. 在 jdk1.8 版本之后才支持 `LocalDateTime` 和 `DateTimeFormatter`
3. `LocalDateTime.parse(s,formatter)` 解析字符串
4. `DateTimeFormatter.ofPattern("yyyyMMddHHmmss")` 生成 formatter
5. `LocalDateTime.now` 可以直接获取当前时间
6. `Java.sql`中, 只有 `Date/Time/Timestamp`
    - Date: 只有日期
    - Time: 只有时间
    - Timestamp: 时间戳(大部分数据库都支持,包括MAPD)
7. url 传递时间参数时, 需要注意：
    - 特殊字符的转义：比如 `-` 和 空格 都会被转义掉, 导致后台不能识别. 所以采用 `yyyyMMddHHmmss` 格式
    - 不要加 "" : 比如 `url?time="20170706001400"`, 传到后台时, 接收到的是`"20170706001400"`（第一个字符是 `"` ）导致parse失败
        - 在 spring boot 上测试的, 确实如此

### 文件读写
- 参考1: [Java 按行读取文件](http://blog.csdn.net/u010889616/article/details/51477037)
- 参考2: [Java读取文件方法大全](http://www.cnblogs.com/lovebread/archive/2009/11/23/1609122.html)

1. 将InputStream转换到BufferReader: BufferedReader可以按行操作文件
    - `BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(is));`
2. BufferReader读取文件(按行)
    ```Java
    String str = null;  
    while((str = bufferedReader.readLine()) != null)  
    {  
        System.out.println(str);  
    }  
    ```
#### 从url地址获取文件流
```Java
URL url;
try {
        url = new URL(tracksDownloadUrl);
        // 打开连接
        URLConnection con = url.openConnection();
        // 输入流
        InputStream is = con.getInputStream();
}catch(...){...}
```
#### 写入文件
```Java
try{
    // 写入
    // BufferedWriter out=new BufferedWriter(new FileWriter(fileName));
    // 追加写入
    BufferedWriter out=new BufferedWriter(new OutputStreamWriter(new FileOutputStream(fileName, true)));
    out.write("Hello World:");
    out.newLine();  //注意\n不一定在各种计算机上都能产生换行的效果
    out.write("Bey!");
    out.close();
} catch (IOException e){
    e.printStackTrace();
}
```
### ==/equal
1. equal是方法, == 是操作符
2. 一般而言, == 用于原生类型的比较(值类型), equal用于引用类型的比较
3. equal是Object的方法, 各个对象都可以重写equal方法从而适应不同的业务规则.
4. equal默认比较对象的地址.
5. 对于对象而言, == 用于比较地址, 对于值类型, ==比较值
5. String 类重写了 equal 方法: 比较两个字符串的值是否相同.

### 接口回调
1. 接口回调的意思是, 如有 Boss Work 两个类, 在Boss中发布任务, Work 领取任务 -> 创建新线程执行任务 -> 完成任务, 然后回调Boss的某个方法去执行后续逻辑
2. demo
```Java
public interface CallBack
{
    public void doEvent();
}
public class Boss implements CallBack
{
    public void doEvent()
    {
        System.out.println("打电话给老板，告知已经完成工作了");
    }
}
public class Employee
{
    CallBack callBack;
    public Employee(CallBack callBack)
    {
        this.callBack=callBack;
    }
    public void doWork()
    {
        System.out.println("玩命干活中....");
        callBack.doEvent();
    }
}
```

## 习题
1. 假设有如下语句: `for(Person obj:A.fun())`, 其中`A.fun()`返回`List<Person<T>>`
    - 问: 该语句是否正确? 此时`A.fun()`返回什么类型
    - 答: *因为`A.fun()`没有被明确告诉T是什么类型, 所以会直接返回`List<Object>`.* 
    - 推论: 在foreach语法糖中, 只是简单的简化了foreach循环, 而不会使用obj的类型去转化待循环对象
    - 正确写法: `List<Person> a = A.fun();for(Person obj:a))` 或者　`a =(List<Person>)A.fun();for(Person obj:a))`
2. 假设有如下语句: `String a = null;a += "a";`
    - 问: 能否执行成功? 如果可行,a的值是什么
    - 答: *a的值为 nulla*
3. 假设,在迭代 `ArrayList/HashMap test` 实例时, 如果尝试更改对象的元素, 比如删除, 是否可行?
    - 示例: `Map<String,String> test = new HashMap();for(String key:test.keySet()){if("2".equals(key))test.remove(key);};`
    - 答: *不可行,会报错: `java.util.ConcurrentModificationException`*
    - 解释: 参考:http://www.jianshu.com/p/c5b52927a61a
    - AbstarctList/Map 中有一个域modCount, 每次对集合进行修改时都会modCount++, 而foreach的原理是使用Iterator实现的, 当Iterator初始化时会初始化变量expectedModCount, 值与modCount相同. 然后每次修改集合时, 都会导致modCount的改变；当modCount与expectedModCount不相同时, 就会引发`java.util.ConcurrentModificationException` 异常
4. `Map map = System.getenv(); map.put("test","test");` 可以成功执行么?
    - 参考: [UnsupportedOperationException异常介绍](https://stackoverflow.com/questions/1005073/initialization-of-an-arraylist-in-one-line/1005089#1005089)
    - `Collections.unmodifiableMap(Map)`: 不可修改的Map. put方法代码如下: `public V put(K var1, V var2) {throw new UnsupportedOperationException();}`
    - `Arrays.asList()` 返回由指定数组支持的固定大小的列表, 所以不支持添加和删除. 详细看其实现代码, add方法代码如下 `public void add(int var1, E var2{throw new UnsupportedOperationException();}`
    - 适用场景: 希望数据是只读的(比如`System.getenv()`), 不希望客户端改变数据. 另外, 这两种类型 执行/内存 效率更高一些. 
    - 参考2: [unmodifiableMap是必要的么](https://stackoverflow.com/questions/3999086/when-is-the-unmodifiablemap-really-necessary)
    - 答: *不可行,会报错: `UnsupportedOperationException异常`*
    
## 数据库连接池
> [连接池简介](http://www.cnblogs.com/roren/p/5810565.html)

1. 连接池：对于共享资源, 有一个很著名的设计模式: 资源池(Resource Pool). 该模式正是为了解决资源的频繁分配,释放所造成的问题. 为解决我们的问题, 可以采用数据库连接池技术. 数据库连接池的基本思想就是为数据库连接建立一个“缓冲池”. 预先在缓冲池中放入一定数量的连接, 当需要建立数据库连接时, 只需从“缓冲池”中取出一个, 使用完毕之后再放回去. 我们可以通过设定连接池最大连接数来防止系统无尽的与数据库连接. 更为重要的是我们可以通过连接池的管理机制监视数据库的连接的数量,使用情况, 为系统开发,测试及性能调整提供依据. 

### Durid
> [Druid官方介绍](https://github.com/alibaba/druid/wiki)
> [各种连接池性能对比测试](https://github.com/alibaba/druid/wiki/各种连接池性能对比测试)




## Maven
1. maven 依赖jar的 scope. 参考: [maven依赖的作用域](http://blog.csdn.net/u011191463/article/details/68066656)
    - compile: maven默认的scope属性, 表示被依赖项目需要参与当前项目的编译, 当然后续的测试, 运行周期也参与其中, 是一个比较强的依赖. 打包的时候通常需要包含进去. 
    - privode: 相当于compile, 但是在打包阶段做了exclude的动作, 别的设施(Web Container)会提供
    - runtime:(注：不太了解)表示被依赖项目无需参与项目的编译, 不过后期的测试和运行周期需要其参与. 与compile相比, 跳过编译而已, 说实话在终端的项目（非开源, 企业内部系统）中, 和compile区别不是很大. 比较常见的如JSR×××的实现, 对应的API jar是compile的, 具体实现是runtime的, compile只需要知道接口就足够了. Oracle jdbc驱动架包就是一个很好的例子, 一般scope为runntime. 另外runntime的依赖通常和optional搭配使用, optional为true. 我可以用A实现, 也可以用B实现. 
    - test: 仅仅参与测试相关的工作, 包括测试代码的编译, 执行. 比较典型的如junit
    - system: 与provided类似, 不过被依赖项不会从maven仓库抓, 而是从本地文件系统拿, 一定需要配合systemPath属性使用. 
2. 依赖jar的读取
    - 一般情况下,　jvm会读取`.jar`中的`/META-INF/MANIFEST.MF`文件, 从其中读取主类的位置和引用的jar依赖包的位置.
    - maven默认不会把依赖的jar包输出.
    - 使用Intelij自带的artifacts打包会将所有的依赖打到jar包里.
3. maven.plugins
3. 配置多种环境
4. jar中scope的依赖传递关系
    - A–>B–>C. 当前项目为A, A依赖于B, B依赖于C. 知道B在A项目中的scope, 那么C在A中的scope?
        - *当C是test或者provided时, C直接被丢弃, A不依赖C； 否则A依赖C, C的scope继承于B的scope* 

### maven配置jar的打包方式
1. 
```xml
<!--注: 该配置会将所有依赖存放到pom.xml指定的路径中, 并且会在MANIFEST.MF文件中指定依赖的jar路径, 而不是像Artifacts打包那样全部存到生成的jar里面. 如果部署时不想上传某些jar包, 直接从maven-dependency-plugin指定的输出路径中去掉相应的jar包即可-->
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-jar-plugin</artifactId>
            <configuration>
                <archive>
                    <manifest>
                        <addClasspath>true</addClasspath>
                        <!--mainclass寻找依赖的路径-->
                        <classpathPrefix>../lib/</classpathPrefix>
                        <!--主类名称-->
                        <mainClass>Main</mainClass>
                    </manifest>
                </archive>
            </configuration>
        </plugin>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-dependency-plugin</artifactId>
            <executions>
                <execution>
                    <id>copy</id>
                    <phase>package</phase>
                    <goals>
                        <goal>copy-dependencies</goal>
                    </goals>
                    <configuration>
                    <!--依赖jar生成的位置-->
                        <outputDirectory>
                            ${project.build.directory}/lib
                        </outputDirectory>
                    </configuration>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```
2. Spring Boot 中,可以用如下方式将依赖打到jar包中
```xml
<build>
    <finalName>wzs_demo</finalName>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
    </plugins>
</build>
```

### maven_项目模块本地jar依赖_ClassNotFound
> 参考: [Mavn 项目 引入第三方jar包 导致ClassNotFoundException](https://blog.csdn.net/evan_leung/article/details/50762878)

1. 问题: 在使用Maven构建的项目中, 有 `Mobile-client`,`System-privoder` 和 `Common` 三个模块, 简称 M S C 三个模块.
    - M S 模块都依赖 C 模块, C模块依赖一个第三方的,本地的jar依赖(不能通过配置pom从远程仓库下载). 
    - 如果使用配置本地依赖的方式, 编译时没有问题,但运行 M S 模块时,执行到与 C 中本地jar(本例中是alipay)依赖相关的代码就会报错.
    - 本地依赖的配置方式
        ```xml
        <dependency>
            <groupId>com.alipay</groupId>
            <artifactId>alipay</artifactId>
            <version>1.0.0</version>
            <scope>system</scope>
            <systemPath>${project.basedir}/src/main/resources/lib/alipay-sdk-java20180122110032.jar</systemPath>
        </dependency>
        ```
2. 原因
    - 当本地依赖包通过以上方式导入时, 程序并不会使用maven构建,jar包. 所以 M S 模块都无法访问 C 中涉及到 第三方依赖(alipay)的部分, 所以会抛出 ClassNotFound 的异常 
    - 有时间需要了解下maven的原理, 了解下maven是怎么构建jar包和处理模块依赖,本地依赖,模块依赖中的本地依赖的.
3. 解决方案: 将该本地依赖包安装到本地maven仓库中, 然后该包就可以通过maven管理
    - maven安装命令: `mvn install:install-file -Dfile=./lib/alipay-sdk-java.jar -DgroupId=com.alipay -DartifactId=alipay -Dversion=1.0.0 -Dpackaging=jar -DgeneratePom=true`

### maven_多环境配置
以下文件配置了dev/prod两个开发环境, activeByDefault节点设置默认激活环境
```xml
<profiles>  
    <profile>  
        <id>dev</id>  
        <activation>  
            <activeByDefault>true</activeByDefault>  
        </activation>  
        <properties>
            <profileActive>dev</profileActive>
            <!-- dev环境配置dubbo示例 -->
            <dubbo.container>logback,spring</dubbo.container>
            <dubbo.shutdown.hook>true</dubbo.shutdown.hook>
            <dubbo.application.name>wzs_demo</dubbo.application.name>
            <dubbo.application.owner>wzs</dubbo.application.owner>
            <dubbo.registry.protocol>zookeeper</dubbo.registry.protocol>
            <dubbo.registry.address>192.168.1.2:2181</dubbo.registry.address>
            <dubbo.registry.client>curator</dubbo.registry.client>
            <dubbo.registry.file>/data/zookeeper/web_admin.cache</dubbo.registry.file>
            <dubbo.application.logger>slf4j</dubbo.application.logger>
            <dubbo.logback.level>error</dubbo.logback.level>
            <dubbo.monitor.protocol>registry</dubbo.monitor.protocol>
            <!-- dev环境配置日志输出方式示例 -->
            <access.log.appender>STDOUT</access.log.appender>
        </properties>
    </profile>  
    <profile>  
        <id>prod</id>  
        <properties>  
            <profileActive>online</profileActive>  
        </properties>  
    </profile>  
</profiles>
```