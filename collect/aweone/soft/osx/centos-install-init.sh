#!/bin/bash

# ------------------------------------- 函数封装 ---------------------------------------------
function install_pip(){
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    sudo python get-pip.py -i https://pypi.doubanio.com/simple/
    mkdir ~/.pip
    tee ~/.pip/pip.conf <<-'EOF'
[global]  
timeout = 6000  
index-url = https://pypi.doubanio.com/simple/  
[install]  
use-mirrors = true  
mirrors = https://pypi.doubanio.com/simple/ 
EOF
}

function install_docker(){
    # 使用阿里源安装, 现已发现更好的, 既官方源, 替换到阿里源
    # curl -sSL http://acs-public-mirror.oss-cn-hangzhou.aliyuncs.com/docker-engine/internet | sh -
    echo "配置docker免sudo"
    # sudo gpasswd -a ${USER} docker
    # sudo systemctl  restart docker
    
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
    echo "配置docker免sudo"
    sudo usermod -aG docker ${USER}
    echo "需要重新登入终端, user 才可以使用docekr组的权限"
    
    echo "配置docker加速器"
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": ["https://pfonbmyi.mirror.aliyuncs.com"]
}
EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker
}

function install_privoxy(){
    wget -c http://www.silvester.org.uk/privoxy/source/3.0.26%20%28stable%29/privoxy-3.0.26-stable-src.tar.gz -O privoxy.tar.gz
    # 安装依赖命令
    sudo yum install autoconf -y
    sudo yum install gcc -y
    
    tar -xzf privoxy.tar.gz
    pushd privoxy-3.0.26-stable
    # 不要直接使用make命令, 不然生成只有可执行文件. 按照官方另一个教程一步步走, 直接make坑死.
    sudo useradd -g privoxy -s /sbin/nologin -M privoxy
    autoheader
    autoconf
    ./configure
    make
    make -n install
    sudo make -s install
    popd
}
# ------------------------------------- 函数结束 ---------------------------------------------


mkdir -p /tmp/install_aaa && cd /tmp/install_aaa
sudo rm -rf /tmp/install_aaa/*

sudo yum update
sudo yum install vim -y
sudo yum install git -y
sudo yum install tree -y
sudo yum install nmap -y
sudo yum install wget -y
sudo yum install curl -y

# ------------------------------------- 编程环境 ---------------------------------------------
echo "安装pip && 配置豆瓣源"
install_pip

echo "安装Go"
wget -c https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz
tar -xzf go1.10.3.linux-amd64.tar.gz && sudo mv go /usr/local/src/ && sudo ln -s /usr/local/src/go/bin/go /usr/local/bin/go

echo "安装mysql-client"
sudo yum install mariadb.x86_64 -y

# ------------------------------------- 缺少异常处理,最后安装 ----------------------------------
echo "docker 安装"
install_docker

# ------------------------------------- 其他 ------------------------------------------------
install_privoxy
