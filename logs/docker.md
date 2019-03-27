# docker 部署调试记录

使用 Docker 部署时, 编译后的二进制可执行程序在 docker 容器中运行失败, 报错为 `file: not found`
- 环境简述: 二进制程序为Go的程序, 此处指 microkit. docker基础镜像为 alpine.

首先, 验证文件是否存在. 阅读 `docker help run` 文档得知
1. `--rm`: 停止后自动删除, 方面调试
2. `--entrypoint`: 修改挂载点, 替代Dockerfile中默认的挂载点
3. `-ti`: 开启终端
4. 完整命令如下(调试时): `docker run --name microkit --rm --entrypoint="/bin/sh" -ti microkit`

进入容器后, 发现二进制文件是存在的, 是执行时报错 `file: not found`

然后怀疑时系统版本的问题, 验证 `cat /proc/version` 和 `uname -a` 发现和宿主机都是一样的.

这时已经达到我的知识范围之外了, 通过搜索引擎发现可能是编译器问题. [链接](https://yryz.net/post/golang-docker-alpine-start-panic.html)

依照文章修改后, 可以正常运行了.

原因/方法摘录如下
1. 原因: Go编译时默认使用动态链接, 使用 golang 的docker镜像编译时也是默认使用动态链接生成. 但是在 alpine 中不支持动态链接.
2. 两种方法可以指定Go使用静态编译
  1. `export CGO_ENABLED=0`
  2. `go build --ldflags '-extldflags "-static"' -o microkit entry/main.go` (我测试了下, 这种方法好像不行)

使用 `file microkit` 命令可查看二进制文件的属性
````
// 动态链接
microkit: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, Go BuildID=SsLaUCGezhNR5EAGcRrI/ckA224ct5b3y47ITyqah/cpkfFQyoc7c_1-2ao2ZB/TiXJF_pYe_dYDJZsV25V, not stripped
// 静态链接
microkit: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, Go BuildID=9ZLovKp6-bYMNZzWBkDv/seaG468s0cxI1Yw0xRua/pn79b3qUEicSBaxFEOKY/gPUm-NMp-82PF7lTFXhC, not stripped
````

所以, 还是要去了解编译器相关的知识.
