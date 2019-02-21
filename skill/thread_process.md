<!-- TOC -->

- [线程和进程](#线程和进程)
    - [线程](#线程)
        - [线程状态](#线程状态)
        - [多线程编程](#多线程编程)
        - [常用方法](#常用方法)
        - [Runnable/Thread区别](#runnablethread区别)
        - [多线程示例](#多线程示例)
    - [线程池](#线程池)
        - [线程池示例](#线程池示例)
    - [多进程](#多进程)
        - [ProcessBuilder](#processbuilder)
        - [Runtime](#runtime)
        - [多进程示例](#多进程示例)
    - [练习题](#练习题)
    - [小结_TEMP](#小结_temp)

<!-- /TOC -->

- 本文讲解以 Java 为例, 各种语言使用方法都类似,可以互相参考
- [Python多线程/多进程](/language/python/thread_process.md)
- [Python协程](/language/python/coroutines.md)
    - 协程: 执行过程中可以中断并且返回到主线程执行

# 线程和进程
- 参考: [进程/线程的简单介绍](http://www.ruanyifeng.com/blog/2013/04/processes_and_threads.html)
- 参考: [Java 中的进程与线程](https://www.ibm.com/developerworks/cn/java/j-lo-processthread/)

1. 进程与线程, 本质意义上说, 是操作系统的调度单位, 可以看成是一种操作系统 "资源", 由操作系统控制底层实现. Java 作为与平台无关的编程语言, 必然会对底层(操作系统)提供的功能进行进一步的封装, 以平台无关的编程接口供程序员使用, 进程与线程作为操作系统核心概念的一部分无疑亦是如此. 
    - 操作系统: 管理和控制计算机硬件与软件资源的计算机程序, 是直接运行在"裸机"上的最基本的系统软件
2. 进程: 表示CPU处理的任务,一个任务就是一个进程,单核CPU只能同时运行一个任务(因为CPU一个核只能顺序执行一个).
    - 由操作系统在多个进程之间快速切换, 让每个进程都短暂地交替运行,从而实现 "多任务执行"
    - 进程由程序,数据和进程控制块三部分组成, 每个进程都有其自己的内存空间
3. 线程: 在一个进程内部,要同时干多件事,就需要同时运行多个"子任务",这些进程内的这些"子任务"称为线程(Thread).
    - 由操作系统在多个线程之间快速切换, 让每个线程都短暂地交替运行,从而实现"多线程"
    - 线程是最小的执行单元, 进程由至少一个线程组成
    - 如何调度进程和线程, 完全由操作系统决定, 程序自己不能决定什么时候执行, 执行多长时间. 
4. 进程线程区别(个人理解): 
    - 多进程就是在一个进程内部通过Process创建多个进程(系统命令),然后由操作系统去调度并发执行. 因为这个是系统层面的,所以自己一直了解的很抽象.
        - 联想一下, `ps` 查看的不就是进程么, 自己每执行一个命令都会至少创建一个进程,所以 多进程就是类似于自己执行了多个命令,如运行一个jar包两次,这个jar包就是多进程执行的,只是没有用程序控制.
    - 多线程就是在一个进程/程序内, 自己通过Thread创建多个任务(线程),然后由操作系统去调度并发执行.

## 线程 
### 线程状态
1. 创建:执行new方法创建对象, 即进入创建状态
2. 就绪:创建对象后, 执行start方法, 即被加入线程队列中等待获取CPU资源, 这个时候即为就绪状态
3. 运行:CPU腾出时间片, 该thread获取了CPU资源开始运行run方法中的代码, 即进入了运行状态
4. 阻塞:如果在run方法中执行了sleep方法, 或者调用了thread的wait/join方法, 即意味着放弃CPU资源而进入阻塞状态, 但是还没有运行完毕, 带重新获取CPU资源后, 重新进入就绪状态
5. 停止:一般停止线程有两种方式:1执行完毕run方法, 2调用stop方法, 后者不推荐使用. 可以在run方法中循环检查某个public变量, 当想要停止该线程时候, 通过thread.para为false即可以将run提前运行完毕, 即进入了停止状态

### 多线程编程
> 参考: [Java编程要点](https://waylau.gitbooks.io/essential-java/docs/concurrency-Processes%20and%20Threads.html)

1. 用法: 覆盖/重载 Runnable/Thread 中的 run 方法,实现自己的逻辑, 然后调用 start 方法执行
2. `Thread.run()/Thread.start()`执行的区别
    - run 是普通的方法调用,是顺序执行的
    - start 用来启动线程,实现多线程运行
    - 参考: https://blog.csdn.net/tornado886/article/details/4524346

### 常用方法
1. `Thread.sleep()` 暂停执行
    - 等待时间依赖于操作系统的时间
    - 可能抛出 InterruptedException 异常
2. `join()`进程合并: 将指定 线程/进程/线程池 加入到当前线程/进程中, 使当前线程必须等待其他线程的完成
    - `t.join()`方法阻塞调用此方法的线程(calling thread,即当前线程), 直到线程t完, 此线程再继续; 通常用于在`main()`主线程内, 等待其它线程完成再结束`main()`主线程
    - `join()` 允许程序员指定一个等待周期,与 sleep 一样, 等待时间依赖于操作系统的时间, 同时不能假设 join 等待时间是精确的. 
    - 通过 InterruptedException 响应中断
3. 中断: 线程调用 `Thread.interrupt` 设置可以中断标志, 也可以调用 `Thread.interrupted()` , 判断线程有没有被中断
    - 按照惯例, 任何方法因抛出一个 InterruptedException 而退出都会清除中断状态. 当然, 它可能因为另一个线程调用 interrupt 而让那个中断状态立即被重新设置回来. 
    - 很多方法都会抛出 InterruptedException, 如 sleep, 被设计成在收到中断时立即取消他们当前的操作并返回

### Runnable/Thread区别
> 参考: [Thread和Runnable的区别](http://www.cnblogs.com/soaringEveryday/p/4290725.html)
1. Runnable: Runnable 是Java 用来实现多线程的接口 
    - `new Thread(Runnable target,String name)`: 使用 Runnable 通过 Thread 类创建新的线程
        - 通过同一个Runnable对象创建的多个Thread共享变量
        - name 是新创建线程的名字
2. Thread: Thread是线程类, 继承Runnable接口, 可以实例化为执行程序中的一个线程
3. 在都满足项目需求时, 推荐优先使用Runnable接口(Java不支持多继承,所以继承接口更加灵活)

### 多线程示例
```Java
// worker
class ThreadRunnable implements Runnable{
    public int sum = 10;
    @Override
    public void run(){
        for(int i = 0;i<500;i++){
            if(sum>0){
                try {
                    System.out.println(Thread.currentThread().getName()+"干掉一个---->" + (this.sum--));
                    Thread.sleep(ThreadDemo.random.nextInt(10));
                }catch (InterruptedException e){
                    return;
                }
            }
        }
    }
}
// worker
class ThreadChild extends Thread{
    public int sum = 10;
    public void run(){
        for(int i = 0;i<500;i++){
            if(sum>0){
                try {
                    System.out.println(Thread.currentThread().getName()+"干掉一个---->" + (this.sum--));
                    int tt =ThreadDemo.random.nextInt(10);
                    Thread.sleep(ThreadDemo.random.nextInt(10));
                }catch (InterruptedException e){
                    return;
                }
            }
        }
    }
    public ThreadChild(String name){
        super.setName(name);
    }
}
public class ThreadDemo {
    public static Random random = new Random();
    public static void main(String[] arg){
        // ThreadRunnable
        ThreadRunnable tr = new ThreadRunnable();
        Thread tr1 = new Thread(tr,"task1");
        Thread tr2 = new Thread(tr,"task2");
        Thread tr3 = new Thread(tr,"task3");
        tr1.start();
        tr2.start();
        tr3.start();
        // ThreadChild
        ThreadChild tr11 = new ThreadChild("task11");
        ThreadChild tr22 = new ThreadChild("task22");
        ThreadChild tr33 = new ThreadChild("task33");
        tr11.start();
        tr22.start();
        tr33.start();
    }
}
```


## 线程池
1. 线程池,连接池, 池一种常用的编程思想
    - 频繁创建线程会大大降低系统的效率, 因为频繁创建线程和销毁线程需要时间和资源(CPU,存储), 所以使用线程池去复用线程,从而降低 创建线程和销毁线程 所造成的消耗
1. 线程池类: `java.uitl.concurrent.ThreadPoolExecutor`, 构造函数: `ThreadPoolExecutor(int corePoolSize,int maximumPoolSize,long keepAliveTime,TimeUnit unit,BlockingQueue<Runnable> workQueue,ThreadFactory threadFactory,RejectedExecutionHandler handler);`
    - `corePoolSize`: 核心池大小, 默认情况下, 线程池中并没有任何线程, 而是等待有任务到来才创建线程去执行任务.
        - `prestartAllCoreThreads(); prestartCoreThread()`: 预创建线程, 在没有任务到来之前就创建corePoolSize个线程或者一个线程
        - 当线程池中的线程数目达到corePoolSize后, 就会把到达的任务放到缓存队列当中
        - `setCorePoolSize()`: 重新设置核心池大小
    - `maximumPoolSize`: 线程池最大线程数.
        - 当线程池的任务缓存队列已满并且线程池中的线程数目达到maximumPoolSize, 如果还有任务到来就会采取任务拒绝策略(由handler选定策略)
        - `setMaximumPoolSize()`: 设置线程池最大能创建的线程数目大小
    - `keepAliveTime`: 线程空闲多久后自动释放线程, 默认情况下只有线程池中的线程数大于corePoolSize时才生效,直到线程池中的线程数不超过corePoolSize时终止.
        - `allowCoreThreadTimeOut(bool)`: 任何情况下都生效,直到线程池中线程数为0
    - `unit`: keepAliveTime的时间单位. 从 `TimeUnit.DAYS;` 到 `TimeUnit.NANOSECONDS;`
    - `workQueue`: 阻塞队列, 用来存储等待执行的任务. 主要分为: `ArrayBlockingQueue;LinkedBlockingQueue;SynchronousQueue;`
        - `ArrayBlockingQueue`: 基于数组的先进先出队列, 此队列创建时必须指定大小
        - `LinkedBlockingQueue`: 基于链表的先进先出队列, 如果创建时没有指定此队列大小, 则默认为Integer.MAX_VALUE
        - `synchronousQueue`: 不保存提交的任务, 而是将直接新建一个线程来执行新来的任务
        - 线程池的排队策略与BlockingQueue有关
    - `threadFactory`: 线程工厂, 主要用来创建线程
    - `handler`: 表示当拒绝处理任务时的策略, 有以下四种取值
        - `ThreadPoolExecutor.AbortPolicy`: 丢弃任务并抛出RejectedExecutionException异常.  
        - `ThreadPoolExecutor.DiscardPolicy`: 丢弃任务, 但是不抛出异常.  
        - `ThreadPoolExecutor.DiscardOldestPolicy`: 丢弃队列最前面的任务, 然后重新尝试执行任务(重复此过程)
        - `ThreadPoolExecutor.CallerRunsPolicy`: 由调用线程处理该任务
2. 线程池状态
    - RUNNING: 线程池创建并且初始化后
    - SHUTDOWN: 执行 `shutdown()` 方法后,线程池处于SHUTDOWN状态. 此时线程池不能够接受新的任务, 它会等待所有任务执行完毕(`kill`)
    - STOP: 执行 `shutdownNow()` 方法后,线程池处于STOP状态. 此时线程池不能接受新的任务, 并且会去尝试终止正在执行的任务(`kill -9`)
    - TERMINATED: 当线程池处于SHUTDOWN或STOP状态, 并且所有工作线程已经销毁, 任务缓存队列已经清空或执行结束后, 线程池被设置为TERMINATED状态. 
3. 重要方法
    - `execute()`: 向线程池提交一个任务, 交由线程池去执行. 在Executor中声明, 在ThreadPoolExecutor实现
    - `submit()`: 向线程池提交一个任务,并且返回任务执行的结果

### 线程池示例
```Java
public class Main {
    public static void main(String[] args){
        ThreadPoolExecutor executor = new ThreadPoolExecutor(5,10,200,
                TimeUnit.SECONDS,new ArrayBlockingQueue<>(5));
        for(int i =0;i<15;i++){
            executor.execute(new ThreadPoolDemo());
        }
        executor.shutdown();
    }
}
// worker
class ThreadPoolDemo implements Runnable{
    public int sum = 3;
    @Override
    public void run(){
        for(int i = 0;i<500;i++){
            if(sum>0){
                try {
                    System.out.println(Thread.currentThread().getName()+"干掉一个---->" + (this.sum--));
                    Thread.sleep(ThreadDemo.random.nextInt(10));
                }catch (InterruptedException e){
                    return;
                }
            }
        }
    }
}
```

## 多进程
> 参考: http://www.cnblogs.com/chanshuyi/p/5331094.html
### ProcessBuilder
ProcessBuilder: 提供启动和管理进程(也就是应用程序)的方法

1. 创建一个进程的步骤
    - 使用 ProcessBuilder 实例管理进程的属性集
    - 使用`ProcessBuilder.start()` 方法 根据ProcessBuilder的属性集创建一个 Process 实例
        - 同一个ProcessBuilder可以多次调用start(), 创建多个相同或相关的子进程
2. 进程的属性集
    - `command` 命令: 命令的字符串数组, 它表示要调用的外部程序文件及其参数(可以为空)(main函数里的 `String[] arg`).
        - 可以是一个,也可以是多个
    - `envp` 环境: 环境变量字符串数组, 如果子进程继承当前进程的环境,该参数设置为null.
    - `dir` 工作目录: 子进程的工作目录, 如果子进程继承当前进程的工作目录,该参数设置为null.
3. IO流: 子进程的 标准IO操作(`stdin,stdout stderr`) 通过三个流 (`getOutputStream() getInputStream() getErrorStream()`) 重定向到主进程
    - 子进程的 输出`STDOUT` 相当于主进程的的输入, 所以 `getInputStream()` 即可获取子进程的输出
    - 子进程的IO操作流程
        - 子进程启动后, 打开 `stdout/stderr`
        - 当`stdout`内容没有被读取时, 进程就算执行完毕也不会结束, `stderr` 也不关闭.
        - 子进程结束后, 关闭 `stdout/stderr`
    - 当从 `stderr` 中读取数据时, 会造成进程阻塞(`stdout`的数据没有读取,导致子进程无法结束). 解决方法:
        - 使用多线程读取
        - 设置`redirectErrorStream(true)`属性: 该属性将 `stderr` 合并到 `stdout`, 所以只需要 `getInputStream()` 即可
            - 设置方法: `pb.redirectErrorStream(true)`, 只有 `ProcessBuilder` 创建的进程才能使用
4. `Process.waitFor()`: 等待进程结束

### Runtime
Runtime: 当前进程所在的虚拟机实例, 所以Runtime采用了单例模式(因为任何进程只会运行于一个虚拟机实例), 即只会产生一个虚拟机实例

1. Runtime类的exec创建进程 底层 还是通过ProcessBuilder类的start方法来创建新进程的(查看源代码可知)
2. `Runtime.getRuntime()`: 获取当前的进程
3. exec方法不支持不定长参数, ProcessBuilder支持不定长参数
        - 可以查看 exec的源码, 发现 exec 的命令只能是字符串或者不传. 而构造 ProcessBuilder 类时可以传不定长参数

### 多进程示例
```Java
public class ProcessDemo {
    public static void main(String[] args) {
        try {
            // ProcessBuilder(): 管理 Process 的属性
            ProcessBuilder pb = new ProcessBuilder("/bin/sh", "-c","ls");
            // 合并 错误流 到 输出流
            pb.redirectErrorStream(true);
            // start(): 使用 ProcessBuilder 的属性创建一个 Process 实例
            Process process = pb.start();
            
            // Runtime.getRuntime(): 获取当前进程的属性;  exec(): 创建一个 Process 实例(内部依然使用start()创建Process 实例)
            // Process pb = Runtime.getRuntime().exec("ls");
            
            // pb.getInputStream(): 获取子进程的输出.(阻塞当前进程的执行,直到子进程执行完毕后子进程关闭输出流)
            Scanner scanner = new Scanner(pb.getInputStream());
            while (scanner.hasNextLine()) {
                System.out.println(scanner.nextLine());
            }
            scanner.close();
        }catch (Exception e){}
    }
}
```

## 练习题
1. 车辆轨迹模拟程序: 车有停止, 启动, 行驶,暂停 等情况(Java/Python/Go)
2. 实现一个简单的爬虫调度器: url下载, html解析, 文件存储(Python)

## 小结_TEMP
> 无用处,不必看,自己之前理解的不全 再此以自己的语言讲一遍而已

进程: 在Terminal中执行一条命令,就是创建了一个进程, 使用Javac运行一个Java包也是创建了一个进程. Javac 多次其实也是多进程. 在程序里使用Process创建多进程,只是代码化了而已,其实跟多执行几次单进程的程序没多大区别.

线程: 进程内又分的多任务. 进程是在OS级别的,线程实在应用程序/单进程级别的.同一类的思想.因为在一个进程内,所以共享同进程的数据(多进程还共享操作系统的数据呢,如环境变量)

Runnable: Runnable只是 Java 用来实现多线程的接口, 程序员实现此接口中的run()方法, run方法中是要执行的程序代码, 然后使用 Runnable对象 实例化 Thread类, 再调用Thread类的Start方法执行线程. 所以说, 我认为, Java 实现创建线程的逻辑还是在 Thread类 里的.

因为Java单继承的, 并且创建新的自定义线程必须实现`run()`方法(自定义逻辑在run里执行), 所以 Runnable 避免了自定义线程类必须继承Thread类,这就是 Runnable 明显的用处吧 

而线程池, 众所周知, 添加缓冲池 应该是一种很有效的设计模式, 避免了对象/连接等频繁的建立和销毁.类似的还有 单例模式, 避免对象被二次创建; 中间件(没有什么困难是加一个中间件解决不了的,如果有,那就加N个),其实程序处理的一系列函数不就是一系列中间件对数据的逻辑处理么.