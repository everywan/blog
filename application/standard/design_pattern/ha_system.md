首先分析业务, 根据业务特点, 作出合适的业务模型
- 有无峰值
- 数据格式

代码版本管理
- [git flow](/application/os/git/use.md#git-flow)

部署/管理
- docker + k8s

配置
- 本地配置 yaml/ini/json等
- 统一配置中心

日志管理

环境
- 开发/测试/灰度/线上

消息中间件
- kafka
- rocketmq
- 参考: http://www.infoq.com/cn/articles/kafka-vs-rabbitmq
- 除非有明确的高吞吐量要求, 否则一般选取 支持amqp的消息中间件, 如rocketmq/rabbitmq.

存储
- mysql
- redis
- mongodb
    - nosql/sql 区别
- influxdb/mapd 等小众特殊数据库
    - 列数据库等
- hive 等大数据
- 除非mysql的性能不满足要求, 或者明确业务数据适合其他数据库, 否则一般选取mysql.
    - redis: 缓存数据库
    - infludb: 时序数据库
    - mapd: GPU数据库(并发超高, 实时大数据查询极快)

远程调用
- rpc协议
- dubbo(java), 其他语言应有实现
    - 服务发现
    - 服务注册
    - 负载均衡

数据访问层
- orm框架
- 单独实现dao层

web项目还需注意以下

restful 风格接口
- HTTP 返回码
- 返回数据格式

web框架
- services 提供基础服务
- 数据库链接/服务 使用单例模式, 保证该服务只被初始化一次.
    - 在程序入口处实例化 db/service(保证service的单例性), 然后传给 controller/middle等高分层结构以供使用


设计注意
1. 服务熔断
2. 服务降级
3. 高内聚, 低耦合
