# XA事务

XA事务, 分布式事务, 实现思想参考PC二阶段提交算法, 主要用于分布式系统中的事务提交(一次事务涉及到多个网络节点中的服务)

流程如下
1. XA start 开始一个 XA 事务, 并设置为 active 状态
2. 执行事务内的sql
3. 对于 active 状态的XA事务, XA end 将该事务置为 IDLE 状态
4. 对于 IDLE 状态的XA事务
  - XA prepare 将事务置为 prepare 状态. XA recover 可以列出处于 prepare 状态的XA事务.
  - `XA commit xid one phase` 用于预备和提交事务. 此时 XA recover 不会列出该事务, 因为该事务已经终止.
5. 对于 prepare 状态的XA事务
  - XA commit 用于提交并终止事务
  - XA rollback 回滚并终止事务
```sql
XA start `xid`
--sql
xa end `xid`
xa prepare `xid`
xa commit `xid`
```
有如下注意点
1. xid 必须全局唯一
2. 启用xa事务时, 无法启用本地事务(transaction)

## 分布式事务的实现

分布式事务一般借助 消息队列 + 2PC/3PC(2/3阶段算法) 实现.

是否可以参考 TCP三次握手等保证 可靠性?.

----

假设在转账事务中, 账户A转账给账户B. 将主要操作抽象为两个服务: AddAction/MinusAction, 分别负责加钱/扣款.

MinusAction 先从账户A扣款, 成功后Publish消息到队列, MinusAction 只要保证当且仅当扣款成功后, 才推送消息到队列, 且必须保证消息推送到队列, 否则事务回滚.

AddAction 从消息队列读取消息, 然后扣款, 只要保证消费不成功时, 不丢弃消息即可.

消息队列的持久化由消息队列本身负责.

你应该有如下疑问
1. AddAction/MinusAction 之间不可以互相直接调用么? 为什么要分布式单个部署两个服务?
2. 如果在执行AddAction时, 发现账户B不存在怎么办? (假设账户B是在转账后注销的账户)
3. 如果需要多个操作怎么办, 如除了 加钱/扣款 外, 还需要创建转账记录(抽象为 RecordAction).

注意
1. 超时策略: 避免失效事务无限制占用资源.
