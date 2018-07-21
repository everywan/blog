## 项目结构
### 安全
1. 不要直接明文传输私密信息, 如密码.

### 接口风格
[RESTFUL](/application/standard/rest/)

### 添加docker构建
添加 docker.sh, Dockerfile, Makefile.

docker.sh 用于启动 docker镜像的构建, Makefile 用于构建可执行程序, 作为 docker镜像 的挂载点.

Go项目添加docker构建示例如下: [Go项目-docker构建](/basics/language/golang/start/temple.md)

