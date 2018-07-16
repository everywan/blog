# 推荐软件
#!/bin/bash

echo "开启色温自适应"
redshift &

mkdir -p /tmp/install_aaa && cd /tmp/install_aaa
sudo rm -rf /tmp/install_aaa/*

sudo apt update
sudo apt install git -y
sudo apt install tree -y
sudo apt install nmap -y
sudo apt install wget -y
sudo apt install curl -y

echo "安装vscode"
sudo apt install vscode

echo "下载github项目"
mkdir ~/git && git clone https://github.com/everywan/blog.git ~/git/blog

echo "docker 安装"
install_docker

echo "安装终端翻译程序"
sudo pip install dict-cli

echo "安装ss"
install_shadowsock

echo "安装tlp(电池管理工具)"
sudo apt install tlp -y
# thinkpad 高级电池管理函数
sudo apt install acpi-call -y

# ------------------------------------- 编程环境 ---------------------------------------------
echo "安装Go"
wget -c https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz
tar -xzf go1.10.3.linux-amd64.tar.gz && mv go /opt/ && ln -s /opt/go/bin/go /usr/local/bin/go

echo "安装jdk"

echo "安装pip && 配置豆瓣源"
install_pip

sudo apt install mysql-client -y

# ------------------------------------- 安装函数 ------------------------------------------------

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

function install_shadowsock(){
    git clone https://github.com/shadowsocks/shadowsocks.git
    pushd shadowsocks
    git checkout origin/master -b master
    sudo python setup.py install
    popd
    alias sslst='sudo sslocal -c $1 -d $2'
}

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

    # rabbitmq 启动
    # docker pull rabbitmq:management
    # docker run -d --name rabbitmq --publish 5671:5671 --publish 5672:5672 --publish 4369:4369 --publish 25672:25672 --publish 15671:15671 --publish 15672:15672 rabbitmq:management
}
