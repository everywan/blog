<!-- TOC -->

- [Go环境的搭建](#go环境的搭建)
    - [go安装](#go安装)
    - [GOROOT/GOPATH](#gorootgopath)
- [包管理器](#包管理器)
    - [go get](#go-get)
    - [dep](#dep)
        - [文件介绍](#文件介绍)
        - [命令介绍](#命令介绍)
            - [DEP-INIT](#dep-init)
            - [DEP-ENSURE](#dep-ensure)
        - [问题](#问题)
- [引用](#引用)
    - [环境变量](#环境变量)

<!-- /TOC -->

## Go环境的搭建
### go安装
1. 自行百度. 这里推荐一个思路, 就是 从github下载源码, 然后 checkout 到 1.4.x 版本, 然后安装(那天重装系统了, 补充上脚本)
2. github 地址: https://github.com/golang/go
    ```Bash
    git clone https://github.com/golang/go.git && pushd go
    git checkout release-branch.go1.4
    cd ./src && ./all.bash
    if [ -d $HOME/go ];then 
        mv $HOME/go $HOME/go_bk
    fi
    popd && cp -R ./go $HOME/go
    pushd go
    git checkout master
    git clean -xdf
    cd ./src && ./all.bash
    popd && mv go $GOROOT
    if [ -d $HOME/go_bk ];then 
        mv $HOME/go_bk $HOME/go
    fi
    ```
### GOROOT/GOPATH
1. GOROOT/GOPATH 是 go 的[环境变量](#环境变量), 类似于 JAVA/CLASS_HOME , 用于告诉go程序去哪里找go编译器,go的类库.
2. GOROOT: 通常是 go语言编译, 工具, 标准库等的安装路径. 一般安装在 `/usr/go` 或 `/usr/local/go`
3. GOPATH: 通常是 go的工作目录, 存放我们自己的程序, 也用于存放第三方组件.
4. go1.6 之后的版本中, 如果项目下有 vendor 文件夹, 则go编译器会认为 `vendor/` 是一个GOPATH(实际上环境变量里并没有这个值),　然后在vendor下寻找依赖包.
5. go编译器支持链接 (`$GOPATH/src/`下package的源码 | 从pkg下寻找package的.a文件); 并且src源码优先

## 包管理器
参考了解: [Go包管理的前世今生](http://www.infoq.com/cn/articles/history-go-package-management). 

自 Go1.11 之后, Go 官方提供了 Go Module 机制, 不再使用第三方工具.

[Go Modules Wiki](https://github.com/golang/go/wiki/Modules)

升级到 Go1.11 版本后, 可以使用 `go help mod` 查看相关帮助文档.

常用命令如下
```Bash
// 设置 go Module 为开启状态
export GO111MODULE=on

// 添加 go.mod, 用于标示项目由 mod 管理
go mod init

// 下载依赖到本地缓存. ($GOPATH/pkg/mod 目录下)
go mod download

// 将依赖打包到当前目录下的 vendor 目录(优先从本地缓存中取)
go mod vendor

// 添加缺少的依赖, 删除无用的依赖
go mod tidy
```

项目添加依赖的方式有三种: 
1. 使用 `go get` 拉取依赖时会自动将其添加到 go.mod 中.
2. 直接修改 go.mod 文件
3. 使用 `go mod test/build/edit` 时会自动添加项目中使用但 go.mod 没有的依赖

当熟悉 go mod 后, 可能还会遇到一些依赖的问题, 可以使用如下方法排查

----

添加 `-v`: 在 Linux Cli 风格中, 添加 `-v` 可以显示debug信息. 对于部分命令, 最多支持 `-vvv` 三个v输出更详细的 debug 信息. go mod 不支持.

示例: 拉取并更新包和所有依赖包, 并且打印日志: `go get -v -u github.com/everywan/x-go`. 

----

使用 `go list` 查看项目具体的依赖信息.

示例: 以json格式查看当前项目所有的依赖 `go list -json -m all`

----

使用 `go mod graph` 查看项目依赖关系图

示例: 查看项目中与 `github.com/golang/lint` 相关的依赖项: `go mod graph|grep github.com/golang/lint`

输出格式为 `github.com/everywan/a-go github.com/everywan/b-go`, 指的是 项目A 中引用了 项目B.

### go get
1. `go get`: 下载依赖包
2. 下载指定版本依赖包流程, 以`github.com/kataras/iris`示例
    1. 下载依赖: `go get github.com/kataras/iris`
    2. 切换到依赖包目录: `cd $GOPATH/src/github.com/kataras/iris`
    3. 查看 tags 版本: `git show-ref`
    4. 切换到指定版本: `git checkout tags/v10.0.0`

### dep
> 废弃, Go1.11 之后统一使用 go mod

> [dep教程](https://tonybai.com/2017/06/08/first-glimpse-of-dep/)   
> [dep官方文档](https://golang.github.io/dep/docs/introduction.html)

1. 安装: `go get -u github.com/golang/dep/cmd/dep`

#### 文件介绍
1. Dep主要使用两个配置文件: toml格式的清单文件, lock格式的锁定文件. 清单描述用户意图, 锁定描述dep输出.
    - 另一方面讲就是 清单文件具有一定的灵活性, 比如版本闲置可以设置为范围; 锁定文件没有灵活性.
2. How does dep decide what version of a dependency to use?(dep是如何确定依赖版本的)
    - [参考: dep-faq](https://github.com/golang/dep/blob/master/docs/FAQ.md)
    - dep 使用 Gopkg.toml 中的 `[[constraint]]` 节点确定版本; 在 constraint 节点下, 只能从 `branch/version/revision` 中选一个表示版本约束条件.
    - 为什么只能有一个呢? 是因为三个值是互相冲突的, 之所以有这个问题是对三个条件不够理解, 请往下看.
        - 当限制为branch时, 依赖为该分支下最新的代码.
        - 当限制为version时, 根据闲置条件确定适合版本.(优先高版本/正式版本)
        - 当限制为revision时, 选择指定修订版本.
    - `git概念-branch/version/revision` 介绍
        - branch: 分支.
        - version: tags, 关联 `git tags ..` 命令; 通常是重大更改后发布的新版本, release版本. [参考: 基础-打标签](https://git-scm.com/book/zh/v1/Git-基础-打标签)
        - revision: 修订版本, 关联 `git commit ..`; 既你每次commit, 都会生成一个修订版本号. [参考: 工具-Revision](https://git-scm.com/book/zh/v1/Git-工具-修订版本（Revision）选择)
    
#### 命令介绍
##### DEP-INIT
1. `dep init`: 使用 dep 初始化项目, 并且将所有依赖下载到 vendor. 流程如下
    - 分析依赖关系
    - 将直接依赖包写入 Gopkg.toml 文件(直接依赖指main中显示import的包)
    - 将所有的第三方包的最新 `version/branch/revision 信息` 写入 Gopkg.lock
    - 创建`root/vendor`目录, 并且以Gopkg.lock为输入, 将其中的包(精确checkout/revision)下载到项目`root/vendor`下
2. `dep init -gopath -v`: 优先从本地寻找依赖包
    - `-v` 表示调试, 显示更详细的信息. 加`-v`显示更详细的debug信息, 这是Linux/Unix系统常用的标准之一.
##### DEP-ENSURE
1. `dep ensure -v`: 恢复项目依赖
2. `dep ensure -update`

#### 问题
> 优先查阅 [https://github.com/golang/dep/blob/master/docs/FAQ.md](https://github.com/golang/dep/blob/master/docs/FAQ.md) 有没有收录所遇到的问题

1. dep直接依赖版本和依赖项目的依赖版本冲突, 导致报错. 示例: 项目直接依赖 project-A/B, 同时项目A也依赖项目B. 该项目中指定B版本约束为 `branch:master`, 项目A中指定项目B版本约束为 `version:1.2.5`.
    - 报错为: `Could not introduce project-A@1.3.1, as it has a dependency on project-B with constraint ^1.0.0, which has no overlap with existing constraint master from (root)`
    - 报错就是因为 直接依赖的项目B的版本 和 引用依赖中的项目的B版本 没有交集, 导致找不到该依赖, 所以报错.
    - [参考](https://github.com/golang/dep/blob/master/docs/FAQ.md#how-do-i-constrain-a-transitive-dependency-s-version)


## 引用
### 环境变量
> [环境变量_en](https://en.wikipedia.org/wiki/Environment_variable)
1. 环境变量: 环境变量是一些键值对. OS预先设置一些变量, 然后在 进程创建/运行 时读取 OS 的这些设置, 以保证进程的执行环境正常. 如 编译器路径,程序执行目录 等. 
    - 如 jar进程运行时, 会根据 JAVA_HOME 寻找 jdk 位置, 根据 CLASS_HOME 寻找 java 类库.
    - 可以对比理解: 在程序启动时 初始化一些值如 日志级别,日志文件位置 等. 这些初始值对于程序的作用类似与环境变量对于进程的作用.
1. 在Unix/类Unix系统中, 每个进程都有自己的环境变量, 默认情况下继承父进程的环境变量, 除非父进程在创建子进程时进行显式更改.
