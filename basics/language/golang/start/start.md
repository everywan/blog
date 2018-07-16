<!-- TOC -->

- [Go环境的搭建](#go环境的搭建)
    - [go安装](#go安装)
    - [GOROOT/GOPATH](#gorootgopath)
- [包管理器](#包管理器)
    - [go get](#go-get)
    - [dep](#dep)
        - [使用](#使用)
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
1. 参考了解: [Go包管理的前世今生](http://www.infoq.com/cn/articles/history-go-package-management). 
2. 但是现在推荐使用 [dep](https://github.com/golang/dep), go官方的依赖工具.

### go get
1. `go get`: 下载依赖包
2. 下载指定版本依赖包流程, 以`github.com/kataras/iris`示例
    1. 下载依赖: `go get github.com/kataras/iris`
    2. 切换到依赖包目录: `cd $GOPATH/src/github.com/kataras/iris`
    3. 查看 tags 版本: `git show-ref`
    4. 切换到指定版本: `git checkout tags/v10.0.0`

### dep
> [dep教程](https://tonybai.com/2017/06/08/first-glimpse-of-dep/)
1. 安装: `go get -u github.com/golang/dep/cmd/dep`
#### 使用
1. `dep init`: 使用 dep 初始化项目, 并且将所有依赖下载到 vendor. 流程如下
    - 分析依赖关系
    - 将直接依赖包写入 Gopkg.toml 文件(直接依赖指main中显示import的包)
    - 将所有的第三方包的最新 `version/branch/revision 信息` 写入 Gopkg.lock
    - 创建`root/vendor`目录, 并且以Gopkg.lock为输入, 将其中的包(精确checkout/revision)下载到项目`root/vendor`下
2. `dep init -gopath -v`: 优先从本地寻找依赖包


## 引用
### 环境变量
> [环境变量_en](https://en.wikipedia.org/wiki/Environment_variable)
1. 环境变量: 环境变量是一些键值对. OS预先设置一些变量, 然后在 进程创建/运行 时读取 OS 的这些设置, 以保证进程的执行环境正常. 如 编译器路径,程序执行目录 等. 
    - 如 jar进程运行时, 会根据 JAVA_HOME 寻找 jdk 位置, 根据 CLASS_HOME 寻找 java 类库.
    - 可以对比理解: 在程序启动时 初始化一些值如 日志级别,日志文件位置 等. 这些初始值对于程序的作用类似与环境变量对于进程的作用.
1. 在Unix/类Unix系统中, 每个进程都有自己的环境变量, 默认情况下继承父进程的环境变量, 除非父进程在创建子进程时进行显式更改.