#!/bin/bash

mkdir -p /tmp/install_aaa && cd /tmp/install_aaa
sudo rm -rf /tmp/install_aaa/*

sudo apt update
sudo apt install git -y
sudo apt install tree -y
sudo apt install nmap -y
sudo apt install wget -y
sudo apt install curl -y

# ------------------------------------- 编程环境 ---------------------------------------------
echo "安装pip && 配置豆瓣源"
install_pip

echo "安装Go"
wget -c https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz
tar -xzf go1.10.3.linux-amd64.tar.gz && mv go /usr/local/Cellar/ && ln -s /usr/local/Cellar/go/bin/go /usr/local/bin/go

echo "安装mysql-client"
sudo apt install mysql-client -y

# ------------------------------------- 缺少异常处理,最后安装 ---------------------------------------------
echo "docker 安装"
install_docker

# ------------------------------------- 函数封装 ---------------------------------------------
function install_pip(){
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    sudo python get-pip.py
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
    # curl -sSL http://acs-public-mirror.oss-cn-hangzhou.aliyuncs.com/docker-engine/internet | sh -
    # 如果安装不成功可以尝试手动安装
    # wget -c http://mirrors.aliyun.com/docker-engine/apt/repo/pool/main/d/docker-engine/docker-engine_17.03.1~ce-0~debian-jessie_amd64.deb -O docker_e.deb && sudo dpkg -i docker_e.deb
    echo "配置docker加速器"
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": ["https://pfonbmyi.mirror.aliyuncs.com"]
}
EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    echo "配置docker免sudo"
    sudo gpasswd -a ${USER} docker
    sudo systemctl  restart docker
}
