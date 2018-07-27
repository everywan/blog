## 构建高可用系统

- 良好的项目结构. [参考: GO项目结构](/basics/language/golang/start/temple.md)
    - 良好的分层和功能划分
    - (建议) 使用Docker部署项目
    - (可选) 服务降级/熔断设置
- [RESTFUL接口风格](/application/standard/rest/)
- 设计配置文件方案: 对于复杂项目, 良好的配置文件方案方便项目的管理, 测试, 部署.
- 构建微服务系统
    - 按照领域模型拆分业务
    - 按照功能拆分业务
- 构建缓存系统: 减少数据库压力, 提升查询速度
    - redis/memorycache
- 使用消息队列: 解耦业务 等
- 使用RPC框架: 拆分业务 等
    - Java/Dubbo, Go/GRPC, Thrift

### 建议规范
1. 不要直接明文传输私密信息, 如密码.