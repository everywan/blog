# web project
go web project template

规则如下

---
项目命名

项目命名 `organization-project-language`, 即 `组织名称-项目名称-使用的语言`.
- 参考java包的名称, 基本都是 `com.organization.project`

---
README

README 中要有如下介绍
1. 项目的目的, 用途. 如果是某前端的后端项目, 需要声明
2. 项目的简单用法, 使用命令介绍.

---
构建规则

根据不同的构建方案, 项目下有如下文件
1. Makefile: 必须有. 必须包含 build 命令(基础命令). 
  一般还包含 docker 命令, 用于部署. 以及其他项目所需的构建命令.
  - 类似于 mvn/gradle 中的命令(`mvn build`), 告诉别人如何正确的构建你的项目, 而不用看代码.
2. docker. docker 构建方法写到 Makefile 中.
  - Dockerfile
  - docker-entrypoint
3. api 描述
  - web 服务可以使用 swagger 定义 API
  - grpc 服务直接使用 proto 文件定义 API

---
项目规范

````
- entry/main.go 入口文件
- internal
  - cmd
  - controllers
  - services
  - codes             错误码定义
  - middlewares       中间件
  - models            内部类, 项目内使用的
- model.go            对外公布的类, 每个类一个文件
// grpc 所需
- client              client, 供其他库使用, 创建 Client
- pb                  proto生成的代码
````

---
单元测试

参考 [单元测试 go](/language/golang/tools/utilTest.md)

## 相关技术介绍
1. [grpc 使用](/language/golang/tools/grpc.md)
2. [docker 使用](https://github.com/everywan/soft/tree/master/doc/docker)
