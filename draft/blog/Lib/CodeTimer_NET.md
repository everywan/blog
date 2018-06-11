# 一个简单的性能计数器
> 摘抄自 [一个简单的性能计数器_赵劼](http://www.cnblogs.com/JeffreyZhao/archive/2009/03/10/codetimer.html)  
> [C# GC类](https://msdn.microsoft.com/zh-cn/library/system.gc(v=vs.110).aspx)

<!-- TOC -->

- [一个简单的性能计数器](#一个简单的性能计数器)
    - [代码](#代码)
    - [介绍](#介绍)
    - [ETC](#etc)
    - [引用](#引用)
        - [CPU时钟周期](#cpu时钟周期)

<!-- /TOC -->

## 代码
1. [查看代码](/Lib/CodeTimer.cs)

## 介绍
1. CodeTimer.Initialize 方法: 在测试前调用
    - 将当前进程及当前线程的优先级设为最高, 以减少减少操作系统在调度上造成的干扰
    - 调用一次Time方法进行 "预热", 让JIT将IL编译成本地代码, 让Time方法尽快 "进入状态"
2. Time方法: 真正用于性能计数
    1. 调整颜色输出
    2. 强制GC进行收集, 并记录目前各代已经收集的次数
        - `GC.MaxGeneration`: 系统当前支持的最大代数, 具体见 [浅析GC原理](/Program/GC.md)
    3. 执行代码, 记录下消耗的时间及[CPU时钟周期](#CPU时钟周期)
        - RDTSC指令：在Intel Pentium以上级别的CPU中, 时间戳(Time Stamp)部件以64位无符号整型数的格式, 记录了自CPU上电以来所经过的时钟周期数 (精度 t= 1/T)
        - GetCycleCount() 函数便是使用 RDTSC指令计时, 获取CPU时钟周期
    4. 恢复颜色输出, 并打印消耗时间及CPU时钟周期
    5. 印执行过程中各代垃圾收集回收次数

## ETC
- [计时函数比较](http://www.cnblogs.com/dwdxdy/p/3214905.html)
    - `gettimeofday()` 是Linux环境下的RDTSC指令计时函数
    - `GetCycleCount()` 是Win环境下的RDTSC指令计时函数

|函数 |类型 |精度级别   |时间|
|:---:|:---:|:--------:|:---:|
|time	|C系统调用	|低	|<1s
|clcok	|C系统调用	|低	|<10ms
|timeGetTime	|Windows API	|中	|<1ms
|QueryPerformanceCounter	|Windows API	|高	|<0.1ms
|GetTickCount	|Windows API	|中	|<1ms
|RDTSC	|指令	|高	|<0.1ms
 

## 引用
### CPU时钟周期
统计CPU时钟周期时使用P/Invoke访问 QueryThreadCycleTime 函数, 这是Vista和Server 2008中新的函数