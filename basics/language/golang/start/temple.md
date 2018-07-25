## 项目结构

<!-- TOC -->

- [项目结构](#项目结构)
    - [GO项目位置](#go项目位置)
    - [项目架构](#项目架构)
    - [引用](#引用)
        - [控制层](#控制层)
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
// 通用基础结构
- view                      // 视图层, 前后端分离时不需要
- controllers               // [控制层](控制层), 一般情况下只负责 参数收集/验证, 以及返回结果的封装
- business                  // 业务逻辑层, 实现具体的业务逻辑. 当业务不复杂时, 可以合并到 controller 层
- services                  // 服务层, 对非原始数据的操作, 为 business 层提供服务. 比如用于插入数据前填充ID字段, 返回数据前隐藏Password字段.
- dao                       // 数据访问层, 封装数据操作, 连接池, 保活等. 如 封装数据库读写数据的方法. 使用 gorm 或其他插件时, 可以合并到 service 层

// 推荐结构 - GO: Go程序可以直接生成二进制文件, 使用可执行程序的方式修改项目结构
- cmd                       // 构建 CLI-APP 程序.
    - root.go
- entry                     // 载入点, 因为外层项目是用来构建 CLI-APP 的, 所以载入点不能放置到外层, 外层程序的包名应该是该项目的名称.
    - main.go
- user.go                   // 类似Model层, 定义数据库表的字段, 以及接口方法
- .demo.yml                 // 配置文件
- docker.sh                 // Docker构建脚本
- Dockerfile
- Makefile                  // 生成可执行程序, 为Docker提供载入点

// 可选层
- util                      // 工具包. 与helper区别: util通常被理解为只有静态方法并且是无状态的, 既你不会创建这样一个类的实例.
                            // helper 可以是实用程序类, 也可以是有状态的或需要创建实例.
- middlewares               // 中间件
- proto                     // grpc 远程调用组价
- doc                       // 文档
- script                    // 脚本
    - shell                 // Bash脚本
    - sql                   // sql脚本
````

1. 推荐第三方组件
    - [Cobra: 构建CLI-APP(命令行程序)](https://github.com/spf13/viper)
    - [GORM: 对象关系映射, 解决数据库访问的问题](https://github.com/jinzhu/gorm)
    - [GRPC: 远程调用](https://github.com/grpc/grpc)
    - [viper: 配置文件读取方案](https://github.com/spf13/viper)
3. 相关文件示例
    - [MakefileDemo](#makefiledemo)
    - [DockerfileDemo](#dockerfiledemo)
    - [DockerShellDemo](#dockershelldemo)

### 引用
#### 控制层
controller层只负责 搜集参数/验证参数 --> 交给business层,business返回业务处理结果 --> 封装返回结果, 返回给前端. 这么做的好处在于, 将前端控制与业务逻辑解耦, 好处是, 比如说某一业务同时提供给 前端页面/RPC, 但是两者提供的参数格式不同, 前者是从表单提取, 后者是从指定的消息格式中提取, 这时便可以复用business层, 对于每个服务,只需开发对应的controller层即可.
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