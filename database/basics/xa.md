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
