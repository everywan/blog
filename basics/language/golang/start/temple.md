<!-- TOC -->

- [GO工作目录](#go工作目录)
    - [项目结构示例](#项目结构示例)
- [引用](#引用)
    - [MakefileDemo](#makefiledemo)
    - [DockerfileDemo](#dockerfiledemo)
    - [DockerShellDemo](#dockershelldemo)

<!-- /TOC -->

## GO工作目录
由于Go语言项目都需要在Gopath中, 所以Go常用的项目管理方式有两种: 

1. 每个项目单独创建一个Gopath.
    - 因为需要手动创建/切换Gopath, 所以除非在使用 IDE, 其他情况不推荐使用.
2. 所有的项目都在一个Gopath中
    - 根据项目地址分目录存放, 编辑时只打开指定项目文件夹即可.
    - 使用 dep 等包管理工具将依赖打包到vendor中
    - 每个项目的依赖使用包管理工具放到自身项目的 vendor 下, 公用包放到 Gopath, 基础包放到 Goroot.
    - 建议使用 dep 包管理工具 + vscode 编辑器

### 项目结构示例
````
- $GOPATH
    - bin                       // 编译后的可执行文件
    - pkg                       // 编译后的包文件
    - src                       // 源代码
        - github.com
            - everywan
                - IOT_Server    // A: 存放 个人/第三方 在github上的项目. 引用的第三方组件直接 `go get` 即可, 要开发的项目使用 `git clone`(为了可以上传代码, goget 的项目没有办法使用git上传代码)
                    - Makefile  // B: 用于构建go项目.
                    - Dockerfile// 可选, 用于构建docker镜像
                    - docker.sh // 可选, 用于构建docker镜像
        - golang.com
        - wzs                   // C: 存放本地的开发项目, 如 demo
````
1. 建议每个项目下都添加 Makefile 文件, 用于构建项目.
2. 建议线上使用 docker 部署项目. 添加 Dockerfile 和 docker.sh, 用于自动化构建项目
3. 相关文件
    - [MakefileDemo](#makefiledemo)
    - [DockerfileDemo](#dockerfiledemo)
    - [DockerShellDemo](#dockershelldemo)

## 引用
### MakefileDemo
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

### DockerfileDemo
```Dockerfile
FROM golang:latest

LABEL maintainer="** **@**.com"

WORKDIR $GOPATH/src/github.com/everywan/test
ADD . $GOPATH/src/github.com/everywan/test
RUN make dist

EXPOSE 50000

ENTRYPOINT ["./bin/main"]
```

### DockerShellDemo
```Bash
# 显示git项目版本
version=`git symbolic-ref --short -q HEAD`

image=`basename $PWD`:$version

xgxwImage=xiagaoxiawan.com/everywan/$image

docker rmi --force xgxwImage 2> /dev/null

docker build -t $xgxwImage .

docker push $xgxwImage
```