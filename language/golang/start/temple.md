## 项目结构

<!-- TOC -->

- [项目结构](#%E9%A1%B9%E7%9B%AE%E7%BB%93%E6%9E%84)
  - [GO项目位置`](#go%E9%A1%B9%E7%9B%AE%E4%BD%8D%E7%BD%AE)
  - [项目架构`](#%E9%A1%B9%E7%9B%AE%E6%9E%B6%E6%9E%84)
  - [引用](#%E5%BC%95%E7%94%A8)
    - [控制层](#%E6%8E%A7%E5%88%B6%E5%B1%82)
    - [MakefileDemo](#makefiledemo)
    - [DockerfileDemo](#dockerfiledemo)
    - [DockerShellDemo](#dockershelldemo)

<!-- /TOC -->

由于Go语言项目都需要在Gopath中, 所以Go常用的项目管理方式有两种: 

1. 每个项目单独创建一个Gopath.
    - 因为需要手动创建/切换Gopath, 所以除非在使用 IDE, 其他情况不推荐使用.
2. 所有的项目都在一个Gopath中
    - 根据项目地址分目录存放, 编辑时只打开指定项目文件夹即可.
    - 使用 dep 等包管理工具将依赖打包到vendor中
    - 每个项目的依赖使用包管理工具放到自身项目的 vendor 下, 公用包放到 Gopath, 基础包放到 Goroot.
    - 建议使用 dep 包管理工具 + vscode 编辑器

### GO项目位置
````
- $GOPATH
    - bin                       // 编译后的可执行文件
    - pkg                       // 编译后的包文件
    - src                       // 源代码
        - github.com
            - everywan
                - IOT_Server    // A: 存放 个人/第三方 在github上的项目. 引用的第三方组件直接 `go get` 即可, 要开发的项目使用 `git clone`(为了可以上传代码, goget 的项目没有办法使用git上传代码)
        - golang.com
        - wzs                   // C: 存放本地的开发项目, 如 demo
````

### 项目架构
````
- entry                     // 载入点, 因为外层项目是用来构建 CLI-APP 的, 所以载入点不能放置到外层, 外层程序的包名应该是该项目的名称.
- internal                  // 声明为 Go 内部包, 被外界引用时会报错. 编译器标准用来维护一些私有库和局部状态. 只需暴露外层 user.go 接口即可, 无需暴露内部实现.
    // 通用基础结构
    - view                      // 视图层, 前后端分离时不需要
    - controllers               // 一般情况下只负责 参数收集/验证, 以及返回结果的封装
    - business                  // 业务逻辑层, 实现具体的业务逻辑. 当业务不复杂时, 可以合并到 controller 层
    - services                  // 服务层, 对非原始数据的操作, 为 business 层提供服务. 比如用于插入数据前填充ID字段, 返回数据前隐藏Password字段.
    - dao                       // 数据访问层, 封装数据操作, 连接池, 保活等. 如 封装数据库读写数据的方法. 使用 gorm 或其他插件时, 可以合并到 service 层
    // 推荐结构 - GO: Go程序可以直接生成二进制文件, 使用可执行程序的方式修改项目结构
    - cmd                       // 构建 CLI-APP 程序.
        - root.go
        - main.go
    - util                      // 工具包. 与helper区别: util通常被理解为只有静态方法并且是无状态的, 既你不会创建这样一个类的实例. helper 可以是实用程序类, 也可以是有状态的或需要创建实例.
    - middlewares               // 中间件
- user.go                   // 类似Model层, 定义数据库表的字段, 以及接口方法
- proto                     // grpc 远程调用组件
- .demo.yaml                 // 配置文件
- docker.sh                 // Docker构建脚本
- Dockerfile
- Makefile                  // 生成可执行程序, 为Docker提供载入点
- doc                       // 文档
- script                    // 脚本
    - shell                 // Bash脚本
    - sql                   // sql脚本
````

1. 命名规范
    - 文件/go源码使用下划线链接. 如 `go_test.go` 而不是 `goTest.go`
    - 包名可以不和 项目名/文件名 一致. 包名中不能有 下划线/连字符
2. 推荐第三方组件
    - [Cobra: 构建CLI-APP(命令行程序)](https://github.com/spf13/viper)
    - [GORM: 对象关系映射, 解决数据库访问的问题](https://github.com/jinzhu/gorm)
    - [GRPC: 远程调用](https://github.com/grpc/grpc)
    - [viper: 配置文件读取方案](https://github.com/spf13/viper)
3. 相关文件示例
    - [MakefileDemo](#makefiledemo)
    - [DockerfileDemo](#dockerfiledemo)
    - [DockerShellDemo](#dockershelldemo)

一般而言, 在程序中由 controller 负责 参数收集/参数校验, business/service 负责业务逻辑, dao/orm 负责数据持久化, 在Web开发中常见的项目结构与分层如上.

但有一种普遍存在的情况也, 即 Service之间互相依赖, 即一个业务逻辑调用到了多个services. 如创建订单时, 需要 更新库存(goodsService), 更新订单(orderService), 这种情况下有两种解决方案
1. 将 更新库存+更新订单 都放到controller层.
2. 将 goodsService 注入到 orderService 中, 创建订单的逻辑依旧在 service层.

我刚开始学习Web开发时, 考虑到保持解耦(当时还不了解依赖注入), 采用的方法1, 即都放到controller层. 大家可以考虑下这么做会在开发过程中遇到那些问题.

我遇到的问题如下
1. 数据库事务: 因为业务逻辑在 controller层, 显然 controller 无法直接操作数据库, 所以无法提交事务, 不能进行回滚. 所以当更新订单失败时, 无法使用mysql自身的机制回滚库存表的更新.
2. 业务逻辑复用: 假设现在增加了另一个路由, 如原先是调用http服务下单, 现在时通过grpc调用下单, 由于两者参数不同, 自然不能映射到一个controller方法, 此时就需要将同样的逻辑复制两份. 如此代码不能复用. 也没有很好的整合.
3. 业务分层混乱: 在其他业务逻辑中, 由service负责业务逻辑, 但是在此处由controller负责业务逻辑, 不够整洁.

当改用_依赖注入_后, 虽然服务间增加了耦合, 但是避免了上述问题, 且由于服务是在最上层注入的, orderService 只调用相关的方法, goodsService 只要不更改接口, 则不影响orderService使用, 侵入比较小. 因为服务间的依赖是无法避免的, 相比之下, 我还是认为依赖注入的方式能使代码更为健壮.

其实, 在开发/分层时还有一个需要注意的点就是远程调用, 服务分布式部署的问题. 这是还要考虑分布式事务的问题.

另, 附上一句听来的话, 用来验证 controller 是否符合规范: controller 要返回的数据应当时稳定的, 不随时间变化而变化.

其他规范
1. 永远不要再最外层调用 internal 中的结构体. 即不要再 外层的user.go调用internal中的结构体/方法. 这样会破坏门面模式, 破坏接口的独立性
2. models 层定义 Request/Response 结构体. Request 用于 controller 与 service 通信, Response 用于controller处理service返回的数据, 转换为合适的格式返回给前端. models 是为了补充外层结构体. models 定义只在该项目内部使用的结构体, 最外层定义了对外开放的结构体
3. 传入数据是否符合业务逻辑交由service层判断, controller只负责收集该数据, 以及非业务上的判断. 如业务创建时必须包含 id/name 字段, 此参数断言不放在controller中, 而放到service中. controller只负责参数收集/校验参数格式正确, 不应负责业务上对参数的校验, 业务上的校验交给service才能保证所有使用该业务逻辑的方法都有此校验.

### 引用
#### MakefileDemo
```Shell
PREFIX?=$(shell pwd)

.PHONY: clean all fmt vet lint build test
.DEFAULT: all

all: clean fmt vet lint build test
dist: clean build

APP_NAME := main

GOLINT := $(shell which golint || echo '')

PKGS := $(shell go list ./... | grep -v ^github.com/everywan/****/vendor/)

clean:
	@echo "+ $@"
	@rm -rf "${PREFIX}/bin/"

fmt:
	@echo "+ $@"
	@test -z "$$(gofmt -s -l . 2>&1 | grep -v ^vendor/ | tee /dev/stderr)" || \
		(echo >&2 "+ please format Go code with 'gofmt -s'" && false)

vet:
	@echo "+ $@"
	@go vet $(PKGS)

lint:
	@echo "+ $@"
	$(if $(GOLINT), , \
		$(error Please install golint: `go get -u github.com/golang/lint/golint 需翻墙！`))
	@test -z "$$($(GOLINT) ./... 2>&1 | grep -v ^vendor/ | tee /dev/stderr)"

test:
	@echo "+ $@"
	@go test -test.short $(PKGS)

build:
	@echo "+ $@"
	@mkdir "bin"
	@go build -v -o ${APP_NAME}
	@mv ${APP_NAME} "${PREFIX}/bin/"

```

#### DockerfileDemo
满足两项
1. 构建可执行程序
2. 修改时区
    ```Dockerfile
    RUN apk add --no-cache --virtual .build-deps \
            tzdata \
            && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
            && echo "Asia/Shanghai" > /etc/timezone \
            && apk del .build-deps

    ENV TZ "Asia/Shanghai"
    ```
```Dockerfile
FROM golang:latest

LABEL maintainer="** **@**.com"

WORKDIR $GOPATH/src/github.com/everywan/test
ADD . $GOPATH/src/github.com/everywan/test
RUN make dist

EXPOSE 50000

ENTRYPOINT ["./bin/main"]
```

#### DockerShellDemo
```Bash
# 显示git项目版本
version=`git symbolic-ref --short -q HEAD`

image=`basename $PWD`:$version

xgxwImage=xiagaoxiawan.com/everywan/$image

docker rmi --force xgxwImage 2> /dev/null

docker build -t $xgxwImage .

docker push $xgxwImage
```
