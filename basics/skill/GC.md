# 浅析GC原理

> 摘抄自 [浅析GC原理_cnblog](http://www.cnblogs.com/xiarifeixue/articles/GC.html)  
> [C# GC类](https://msdn.microsoft.com/zh-cn/library/system.gc(v=vs.110).aspx)

<!-- TOC -->

- [浅析GC原理](#浅析gc原理)
    - [GC](#gc)
    - [相关算法](#相关算法)
        - [Reference Counting](#reference-counting)
        - [Mark Sweep](#mark-sweep)
        - [Generation](#generation)
    - [相关数据结构 (参考[内存分配](/Algorithm/memory_allocation.md))](#相关数据结构-参考内存分配algorithmmemory_allocationmd)
        - [Managed Heap](#managed-heap)
        - [Finalization Queue/Freachable Queue](#finalization-queuefreachable-queue)

<!-- /TOC -->

## GC
GC : 控制系统垃圾回收器(一种自动回收未使用内存的服务)

## 相关算法
### Reference Counting
- Reference Counting：引用计数, 当一个新的引用指向对象时, 引用计数器就递增, 当去掉一个引用时, 引用计数就递减. 当引用计数到零时, 该对象就将释放占有的资源. 
- C++的智能指针, 应该就是根据Reference Counting算法的编写的(个人猜测, 没有查源码)

### Mark Sweep
- 用处：在程序运行的过程中, 不断的把Heap的分配空间给对象, 当Heap的空间被占用到不足Mark Sweep算法被激活, 将垃圾内存进行回收并将其返回到free list中
- 定义：运行的过程中分为Mark阶段和Sweep阶段
    - Mark阶段：从root出发, 利用相互的引用关系遍历整个Heap, 将被root和其它对象所引用的对象标记起来. 没有被标记的对象就是**垃圾**
    - Sweep阶段：回收所有的垃圾
- 缺点
    1. 需要遍历Heap中所有的对象, 所以速度不太理想
        - 引入 Generation 的思想
    2. 会造成大量的内存碎片
        - 加入Compact阶段：先标记存活的对象, 再移动这些对象使之在内存中连续, 最后更新和对象相关的地址和free list

### Generation
Generational garbage collector(又称ephemeral garbage collector) 基于以下假设：
- 对象越年轻则它的生命周期越短
- 对象越老则它的生命周期越长
- 年轻的对象和其它对象的关系比较强, 被访问的频率也比较高
- 对Heap一部分的回收压缩比对整个Heap的回收压缩要快

Generation的概念就是对Heap中的对象进行分代(分成几块, 每一块中的对象生存期不同)管理. 
- 当对象刚被分配时位于Generation 0中, 当Generation 0的空间将被耗尽时, Mark Compact算法被启动
- 经过几次GC后如果这个对象仍然存活则会将其移动到Generation 1中
- 如果经过几次GC后这对象还是存活的, 则会被移动到Generation 2中, 直到被移动到最高级中最后被回收或者是同程序一同死亡

优点：
1. 少安排GC的次数, 这样做就使得GC的速度得到了一定程度的提高
2. 细化场景以提高效率, 是一种常用的优化思想

缺点：需要测试/设置以下值
1. 应该设置几个Generation, 每个Generation应该设置成多大
2. 每个对象升级时它应该是已被GC了多少次而仍然存活

## 相关数据结构 (参考[内存分配](/Algorithm/memory_allocation.md))
### Managed Heap
- 在 堆区 分配和释放
- 在Managed Heap上有一个称为NextObjPtr的指针, 这个指针用于指示堆上最后一个对象的地址
- 当NextObjPtr的值超出了Managed Heap边界的时候说明堆已经满了, **GC将被启动**

### Finalization Queue/Freachable Queue
- 在 栈区 分配和释放
- 与.net对象所提供的Finalize方法有关
- 并不用于存储真正的对象, 而是存储一组指向对象的指针

流程  
1. 当程序中使用了new操作符在Managed Heap上分配空间时, GC会对其进行分析, 如果该对象含有Finalize方法, 则在Finalization Queue中添加一个指向该对象的指针
2. **对象的复生**(Resurrection)
    - 在GC被启动后, 经过Mark阶段分辨出哪些是垃圾, 
    - 再在垃圾中搜索, 如果发现垃圾中有被Finalization Queue中的指针所指向的对象, 则将这个对象从垃圾中分离出来, 并将指向它的指针移动到Freachable Queue中
3. Freachable Queue 在被添加指针之后, 会触发所指对象的 Finalize 方法执行, 之后将这个指针从队列中剔除, 标记对象死亡
    - .NET 的 System.GC类 提供了控制Finalize的两个方法：
    - SuppressFinalize: 请求系统不要完成对象的Finalize方法
    - ReRegisterForFinalize: 请求系统完成对象的Finalize方法
        - 该方法其实就是将指向对象的指针重新添加到 Finalization Queue 中
4. 如果在对象的 Finalize 方法中调用 ReRegisterForFinalize 方法
    - 首先, 将对象重新添加到Finalization Queue 中
    - 因为在Finalization Queue 中的对象可以复生, 所以又回到Freachable Queue 中
    - 如此, 则形成了一个在堆上永远不会死去的对象
