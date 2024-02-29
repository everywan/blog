# Install Mapd in TX2/docker/ubuntu

<!-- TOC -->

- [Install Mapd in TX2/docker/ubuntu](#install-mapd-in-tx2dockerubuntu)
    - [x64平台安装](#x64平台安装)
    - [测试是否安装成功](#测试是否安装成功)
    - [docker安装](#docker安装)
        - [与centos/ubuntu安装差异部分](#与centosubuntu安装差异部分)
    - [ARM平台安装-编译安装](#arm平台安装-编译安装)
        - [注意](#注意)
        - [安装CUDA驱动](#安装cuda驱动)
        - [编译/安装相关依赖](#编译安装相关依赖)
        - [编译/安装Mapd](#编译安装mapd)

<!-- /TOC -->

## x64平台安装
> 根据官方编译好的Mapd文件进行安装, 很简单. 参照教程即可  
> [教程](https://www.mapd.com/docs/latest/getting-started)

1. 安装JDK
2. 更新系统：`yum update`
3. 安装CUDA驱动
    - 添加 nvidia 源(根据系统下载不同的包, 以centos举例)：
        - `curl -O -u mapd http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-<VERSION INFO>.rpm`
        - `rpm --install cuda-repo-rhel7-<VERSION INFO>.rpm`
    - 安装驱动：`yum install cuda-drivers`
4. 开启相应端口
    ````
    sudo firewall-cmd --zone=public --add-port=9092/tcp --permanent
    sudo firewall-cmd --reload
    ````

至此, 准备工作已经完成, 然后安装Mapd

1. 解压Mapd存档：`tar -xvf <file_name>.tar.gz`
2. 添加环境变量
    ````
    export MAPD_PATH=/opt/mapd  # 安装目录
    export MAPD_STORAGE=/var/lib/mapd   # 数据文件目录
    export MAPD_USER=mapd
    export MAPD_GROUP=mapd
    export LD_LIBRARY_PATH=/usr/lib/jvm/jre-1.8.0-openjdk/lib/amd64/server
    ````
3. 创建相应目录, 修改权限等准备工作
    ````
    mkdir -p $MAPD_STORAGE
    chown -R $MAPD_USER $MAPD_STORAGE
    ````
4. 初始化数据库, 并且指定数据文件夹：`$MAPD_PATH/bin/initdb $MAPD_STORAGE`
5. 安装Mapd：`$MAPD_PATH/systemd/install_mapd_systemd.sh`
6. 启动服务
    ````
    sudo systemctl start mapd_server
    sudo systemctl start mapd_web_server
    # 设置开机自启
    sudo systemctl enable mapd_server
    sudo systemctl enable mapd_web_server
    ````
    
## 测试是否安装成功
1. 通过命令行测试
    ````
    # 启动Mapd(默认 用户/数据库名称 都是'mapd', 密码 'HyperInteractive' )
    $MAPD_PATH/bin/mapdql
    # 查看显存分配
    \memory-summary
    ````
2. 直接访问 `http://127.0.0.1:9092` 检测是否成功

## docker安装
> 基本和ubuntu/centos相同

1. 完整的Dockerfile
    - 需要将 `cuda-repo-rhel7-8.0.61-1.x86_64.rpm` 和 `mapd-ce-latest-Linux-x86_64-render.tar.gz` 文件放到同一目录下
    - 安装路径/数据路径 参照上文, 都是一样的
    - 构建docker镜像命令：`docker build -t wzs/mapd:1.0 .`
    ````
    FROM docker.io/centos
    MAINTAINER wzs

    # install depend
    RUN yum install -y sudo
    RUN yum install -y java-1.8.0-openjdk-headless
    RUN yum install -y epel-release

    # install driver
    ADD cuda-repo-rhel7-8.0.61-1.x86_64.rpm /root
    RUN rpm --install /root/cuda-repo-rhel7-8.0.61-1.x86_64.rpm
    RUN yum clean expire-cache
    RUN yum install -y cuda-drivers

    # copy mapd
    ADD mapd-ce-latest-Linux-x86_64-render.tar.gz /root
    RUN mv /root/mapd-ce-3.1.1-20170626-45a6fa8-Linux-x86_64-render /opt/mapd

    # set env
    ENV MAPD_PATH=/opt/mapd
    ENV MAPD_STORAGE=/var/lib/mapd
    ENV MAPD_USER=root
    ENV MAPD_GROUP=root
    ENV LD_LIBRARY_PATH=/usr/lib/jvm/jre-1.8.0-openjdk/lib/amd64/server
    RUN mkdir -p $MAPD_STORAGE
    RUN $MAPD_PATH/bin/initdb $MAPD_STORAGE

    # install mapd
    RUN cd /opt/mapd/systemd | ./install_mapd_systemd.sh

    # start mapd server
    RUN systemctl start mapd_server
    RUN systemctl start mapd_web_server
    ````
### 与centos/ubuntu安装差异部分
1. 需要端口映射, 否则只能通过内网访问
2. centos7之后的镜像需要修改载入点为 `/usr/sbin/init`, 否则不能使用systemd命令.
3. 需要挂载显卡 `--device /dev/nvidia-uvm:/dev/nvidia-uvm`
    - 否则也可以使用CPU模式, 测试可以, 但是影像性能（猜测, 没有测试）
    - 前提条件是添加 `--privileged=true` , 否则会挂载失败
4. 完整的启动命令： `docker run --name mapd --hostname mapd --privileged=true --device /dev/nvidia-uvm:/dev/nvidia-uvm -d -P -p 9091:9091 -p 9092:9092 -ti wzs/mapd /usr/sbin/init`

## ARM平台安装-编译安装
> 这个时最难的部分, 因为TX2的CPU是arm64架构的, 需要编译CUDA驱动, Mapd以及其依赖才能安装  
> 主要参考以下教程   
> [Mapd官方教程_github](https://github.com/mapd/mapd-core)：难度较第二个高, 但是比较及时(毕竟官方维护)  
> [网上公开教程](https://www.leiphone.com/news/201705/jPar4mkGAnXCgLQz.html)：一位大神写的, 很6

### 注意
1. 在安装过程中, 又很多地方需要翻墙或者替换源解决. 现提供以下方案
    - 翻墙：`apt-get -o Acquire::http::proxy="http://proxyIP:proxyPort/" update` 可以使 apt 命令走代理通道. 具体见 [设置代理](/OS/Linux/set_env.md)
    - 修改源
        - [arm平台下的apt-repo](/OS/Linux/repo.md)：没有测试, 可能某些包会找不到. 推荐使用代理
        - [Maven源](/OS/Linux/repo.md)
    - 建议了解下[.configure, make, make install 命令](/OS/Linux/Make&Install.md)
    - `$(nproc)` 是指操作系统级别对每个用户创建的进程数的限制

### 安装CUDA驱动
> TX2安装CUDA驱动的方式类似于安卓线刷, 需要在一台x86_64宿主机上编译好之后刷到TX2上  
> 参考 JETSON TX1 AND TX2 Developer Kits User Guider

1. 下载 JetPack：[下载地址](https://developer.nvidia.com/embedded/jetpack)
    - JetPack 是构建 TX2/TX1 上程序的一套解决方案, 其中包含 TX1/2 的CUDA驱动
2. 添加权限 'chmod +x jetpack-${VERSION}.run'
3. 执行 `.jetpack-${VERSION}.run`, 然后根据提示操作即可
    - 需要系统是 英文的ubuntu, 否则会直接报错
    - 这一步需要下载的组件, 部分需要翻墙, 自备翻墙工具
4. 根据提示, 调整机器到 recovery 模式(和安卓刷机很像)
    - 彻底断开电源
    - 摁住 rec 键, 然后 摁下 power 键, 然后摁下 reset 键, 两三秒秒后松开 rec键
5. 选择机器的连接方式, 执行完CUDA驱动就OK了
    - 这里推荐使用网线连接, TX2可以自动联网而不需要执行连接操作什么的. 否则 写入TX2的过程会报错(刷机过程需要联网)
    - 如果安装没有成功, 不推荐删除宿主机上下载的文件(失败时, 退出界面有个选项, 勾选则删除下载的文件),  否则还要重下
6. 如果时安装CUDA, 到此已经结束. 如果需要其他的AI示例什么的, 需要自己看文档接着操作. 

### 编译/安装相关依赖
> 自备翻墙工具

**可能出现的错误**
- 最重要的就是, 看错误提示, 去理解, 去搜索, 不要瞎猜瞎改.
- 编译时, 报错：llvm某些库找不到. 需要更新llvm到最新版本
- wget 根据提示看是否添加 `--no-check-certificate` 参数
- 编译时, 报`-msse4.2` 指令集相关错误：修改 Makefile文件, 将相关配置置空就可以正常 build 了. folly遇到了此错误
- 编译时报错：没有Clang++：查看系统有没有安装Clang++, 环境变量是否正确, 执行文件名称是否对应

1. 准备阶段：更新系统, 安装依赖包
    ````
    sudo apt -o Acquire::http::proxy="http://127.0.0.1:1080/" update
    sudo apt -o Acquire::http::proxy="http://127.0.0.1:1080/" install -y \
        build-essential cmake cmake-curses-gui git wget curl \
        clang clang-format llvm llvm-dev libboost-all-dev \
        libgoogle-glog-dev golang libssl-dev libevent-dev \
        default-jre default-jre-headless default-jdk \
        default-jdk-headless maven libncurses5-dev \
        binutils-dev google-perftools libdouble-conversion-dev \
        libevent-dev libgdal-dev libgflags-dev \
        libgoogle-perftools-dev libiberty-dev libjemalloc-dev \
        liblz4-dev liblzma-dev libsnappy-dev zlib1g-dev \
        autoconf autoconf-archive
    ````
2. 编译安装 thrift.
    - 此步需要从Maven下载包, 所以在此之前必须修改 Maven 源
    ````
    sudo apt build-dep -y thrift-compiler
    VERS=0.10.0
    wget http://apache.claz.org/thrift/$VERS/thrift-$VERS.tar.gz
    tar xvf thrift-$VERS.tar.gz
    pushd thrift-$VERS
    ./configure \
        --with-lua=no \
        --with-python=no \
        --with-php=no \
        --with-ruby=no \
        --prefix=/usr/local/mapd-deps
    make -j $(nproc)
    sudo make install
    popd
    ````
3. 编译安装 Blosc
    ````
    VERS=1.11.3
    wget --continue https://github.com/Blosc/c-blosc/archive/v$VERS.tar.gz
    tar xvf v$VERS.tar.gz
    BDIR="c-blosc-$VERS/build"
    rm -rf "$BDIR"
    mkdir -p "$BDIR"
    pushd "$BDIR"
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local/mapd-deps \
        -DBUILD_BENCHMARKS=off \
        -DBUILD_TESTS=off \
        -DPREFER_EXTERNAL_SNAPPY=off \
        -DPREFER_EXTERNAL_ZLIB=off \
        -DPREFER_EXTERNAL_ZSTD=off \
        ..
    make -j $(nproc)
    sudo make install
    popd
    ````
4. 编译安装 folly
    ````
    VERS=2017.04.10.00
    wget --continue https://github.com/facebook/folly/archive/v$VERS.tar.gz
    tar xvf v$VERS.tar.gz
    pushd folly-$VERS/folly
    /usr/bin/autoreconf -ivf
    ./configure --prefix=/usr/local/mapd-deps
    make -j $(nproc)
    sudo make install
    popd

    VERS=1.21-45
    wget --continue https://github.com/jarro2783/bisonpp/archive/$VERS.tar.gz
    tar xvf $VERS.tar.gz
    pushd bisonpp-$VERS
    ./configure --prefix=/usr/local/mapd-deps
    make -j $(nproc)
    sudo make install
    popd
    ````
5. 安装bisonpp
    ````
    VERS=1.21-45
    wget --continue https://github.com/jarro2783/bisonpp/archive/$VERS.tar.gz
    tar xvf $VERS.tar.gz
    pushd bisonpp-$VERS
    ./configure --prefix=/usr/local/mapd-deps
    make -j $(nproc)
    sudo make install
    popd
    ````
6. 安装arrow
    ````
    VERS=0.4.1
    wget --continue https://github.com/apache/arrow/archive/apache-arrow-$VERS.tar.gz
    tar -xf apache-arrow-$VERS.tar.gz
    mkdir -p arrow-apache-arrow-$VERS/cpp/build
    pushd arrow-apache-arrow-$VERS/cpp/build
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DARROW_BUILD_SHARED=off \
        -DARROW_BUILD_STATIC=on \
        -DCMAKE_INSTALL_PREFIX=/usr/local/mapd-deps \
        -DARROW_BOOST_USE_SHARED=off \
        -DARROW_JEMALLOC_USE_SHARED=off \
        ..
    make -j $(nproc)
    sudo make install
    popd
    ````


### 编译/安装Mapd
1. 配置环境变量：`vi /etc/profile.d/mapd-deps.sh`
    ````
    LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
    # 需要根据 jvm 的路径和版本修改
    LD_LIBRARY_PATH=/usr/lib/jvm/default-java/jre/lib/arrah64/server:$LD_LIBRARY_PATH
    LD_LIBRARY_PATH=/usr/local/mapd-deps/lib:$LD_LIBRARY_PATH
    LD_LIBRARY_PATH=/usr/local/mapd-deps/lib64:$LD_LIBRARY_PATH
    PATH=/usr/local/cuda/bin:$PATH
    PATH=/usr/local/mapd-deps/bin:$PATH
    # 配置 Mapd设置
    MAPD_PATH=/opt/mapd
    MAPD_STORAGE=/var/lib/mapd
    MAPD_USER=root
    MAPD_GROUP=root

    export LD_LIBRARY_PATH PATH
    export MAPD_PATH MAPD_STORAGE MAPD_USER MAPD_GROUP
    ````
    - 修改权限：`sudo chmod +x /etc/profile.d/mapd-deps.sh`
    - 使环境变量生效：`source /etc/profile.d/mapd-deps.sh`
2. 编译mapd
    - `cd /opt`
    - `git clone https://github.com/mapd/mapd-core.git`
    - `cd $MAPD_PATH/build`
    - 生成makefile文件：`cmake -DCMAKE_BUILD_TYPE=debug ..`
    - 编译：`make -j $(nproc)`
    - 添加服务
    ````
    cd systemd
    sudo ./install_mapd_systemd.sh
    ````
    - 根据需要修改`mapd_server`配置文件 `$MAPD_STORAGE/mapd.conf`
3. 运行Mapd
    - 构建数据文件夹：`$MAPD_PATH/bin/initdb --data $MAPD_STORAGE`
    - 启动服务：`$MAPD_PATH/bin/mapd_server --data $MAPD_STORAGE &`
    - 启动web服务：`$MAPD_PATH/bin/mapd_web_server &`
