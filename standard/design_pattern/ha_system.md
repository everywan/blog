首先分析业务, 根据业务特点, 作出合适的业务模型
- 有无峰值
- 数据格式

一般可以使用以下技术构建一个高性能易扩展的系统
- 代码管理工具: 参考 [git flow](/os/git/use.md#git-flow)
- 项目部署/集群管理工具: docker部署 + k8s集群化管理
- 配置系统
    - 本地配置文件 yaml/ini/json 等 + 配置管理工具
    - 统一配置中心
- 日志系统
- 环境: 开发/测试/灰度/线上
- 消息中间件
    - kafka
    - rocketmq
    - 参考: http://www.infoq.com/cn/articles/kafka-vs-rabbitmq
    - 除非有明确的高吞吐量要求, 否则一般选取 支持amqp的消息中间件, 如rocketmq/rabbitmq.
- 存储: 数据库的选择
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
- 远程调用
    - rpc协议
    - dubbo(java), 其他语言应有实现
        - 服务发现
        - 服务注册
        - 负载均衡
- 数据访问层
    - orm框架
    - 单独实现dao层

web项目可能还需要以下技术
- restful 风格接口
    - HTTP 返回码
    - 返回数据格式
- web框架
    - services 提供基础服务
    - 数据库链接/服务 使用单例模式, 保证该服务只被初始化一次.
        - 在程序入口处实例化 db/service(保证service的单例性), 然后传给 controller/middle等高分层结构以供使用


设计时可以注意以下技术
1. 服务熔断
2. 服务降级
3. 高内聚, 低耦合

设计规范
1. 不要直接明文传输私密信息, 如密码.


jwt/session:
````
session/jwt 不同点
session 在服务端保持用户状态(一般是认证状态), 获取认证信息, 各服务通过请求session服务/缓存判断用户状态.
jwt 是用户每次请求附带 jwt 字符串, 服务端根据jwt字符串获取用户状态与相关信息, 服务器不参与状态保存
session 可以保存多端同步的状态, 如阅读位置, 购物车. jwt多端则不行(因为jwt只保存在了一端上)

为什么需要session/jwt: 减少私密信息在网络上传输的次数从而更安全, 保存用户信息以避免重复读取.

但是 jwt 是无状态的, 存在jwt在有效期内但是认证身份失效的情况(如用户被删除), 所以需要验证用户存在(不需要再次验证私密信息的准确性).

jwt/jws 参考: https://www.jianshu.com/p/50ade6f2e4fd
注意, jwt/jws 中能放敏感信息, jwt/jws 只保证数据是服务端签发的且没有被修改, 不加密数据(jws只是将 HMACSHA256(base64enc(header)+base64enc(payload),secretKey) 的值赋值给sign, 并不将 header,payload 加密.(header/payload 只是base64转码)

需要考虑的一个问题就是, token存在cookie合适, 还是localstore合适.
````
