## CAP定律
CAP定律是指, 在设计一个分布式系统时, 只能满足完全的 一致性, 可用性, 分区容忍性 中的两点. 但是因为网络分区是非人为控制的, 所以设计师要在一致性和可用性之间做出抉择. 即当你有个会丢消息的网络时, 你不能同时拥有完整的 可用性和一致性.
- 一致性(Consistence): 所有节点所有时间都有相同的数据副本. 如上所言, ACID的C,关注在一个事务内, 对数据可见性的约束; CAP的C,关注所有数据节点的一致性和正确性.
- 可用性(Availability): 每次请求都能在一定时间内得到响应结果.
- 分区容错性(Partition tolerance): 能容忍网络发生分区, 即集群中的机器被分成了两部分, 这两部分不能互相通信, 系统是否能继续正常工作

举例证明如下, 如有两个节点位于分区两侧, 允许至少一个节点更新状态会导致数据不一致, 即丧失了C性质. 如果为了保证数据一致性, 将分区一侧的节点设置为不可用, 那么又丧失了A性质. 除非两个节点可以互相通信, 才能既保证C又保证A, 这又会导致丧失P性质.

但是, 网络分区很少发生, 所以此时牺牲一致性或可用性没什么意义. 其次, 一致性/可用性/分区容错性 不是非黑即白的, 而是可以互相妥协, 互相取舍. 一致性有不同的级别, 可用性也可以分为不同的级别, 分区也可以细分为不同的含义, 所以, 设计一个分布式系统没有必要保证完美的 PA 或者 PC, 可以有一定的妥协, 设计自己需要的系统. 其中, BASE理论就是对CAP理论中一致性和可用性权衡的结果.

## BASE理论
BASE = Basically Available + Soft state + Eventually consistent, 即 基本可用性 + 软状态 + 最终一致性.

### 引用
- [浅谈数据一致性](http://www.importnew.com/20633.html)
- [CAP理论十二年回顾："规则"变了](http://www.infoq.com/cn/articles/cap-twelve-years-later-how-the-rules-have-changed)
- [CAP迷思：关于分区容忍性](https://zzyongx.github.io/blogs/cap-confusion-problems-with-partition-tolerance.html)
- [CAP 理论常被解释为一种“三选二”定律，这是否是一种误解](https://www.zhihu.com/question/64778723)
