#!/bin/bash

mkdir -p /tmp/install_aaa && cd /tmp/install_aaa
sudo rm -rf /tmp/install_aaa/*

# ------------------------------------- brew安装 ---------------------------------------------
# 安装 brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# 安装 iterm2, 后续导入 ./iterm2.json 配置文件即可还原配置
brew cask install iterm2

# 安装切换插件, cmd+tab 可以在多窗口间切换, [如何更改为 cmd+tab 切换](https://sspai.com/post/38838)
brew cask install hyperswitch

brew install git -y
brew install tree -y
brew install wget -y
brew install curl -y

# ------------------------------------- bash安装 ---------------------------------------------
echo "下载github项目"
mkdir ~/git && git clone https://github.com/everywan/note.git ~/git/note

echo "安装pip && 配置豆瓣源"
install_pip

echo "安装Shadowsocks"
install_shadowsock

# ------------------------------------- 编程环境 ---------------------------------------------
echo "安装Go"
wget -c https://dl.google.com/go/go1.10.3.darwin-amd64.tar.gz -O go.tar.gz
tar -xzf go.tar.gz && mv go /usr/local/Cellar/ && ln -s /usr/local/Cellar/go/bin/go /usr/local/bin/go

# ------------------------------------- 函数封装 ---------------------------------------------
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
}