# 推荐软件

function install_docker(){
    curl -sSL http://acs-public-mirror.oss-cn-hangzhou.aliyuncs.com/docker-engine/internet | sh -
    # 如果安装不成功可以尝试手动安装
    wget -c docker-engine_17.03.1~ce-0~debian-jessie_amd64.deb && sudo dpkg -i docker-engine_17.03.1_ce-0_debian-jessie_amd64.deb
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

echo "开启色温自适应"
redshift &

mkdir -p /tmp/install_aaa && cd /tmp/install_aaa
sudo rm -rf /tmp/install_aaa/*

sudo apt update
sudo apt install git -y
sudo apt install sshpass -y
sudo apt install tree -y
sudo apt install nmap -y
sudo apt install subversion -y

echo "下载github项目"
mkdir ~/git && git clone https://github.com/everywan/blog.git ~/git/blog

echo "docker 安装"
install_docker

echo "docker 常用容器"
docker pull zookeeper
# docker run -it --name zookeeper -P -p 2181:2181 zookeeper

echo "安装终端翻译程序"
sudo pip install dict-cli

echo "安装ss"

echo "安装autojump"
