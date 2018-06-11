# centos最小化安装配置
> 本文总结了作者使用centos最小化安装时, 碰到的问题和解决方案(主要是在没有图形界面的情况下配置)

1. 网络问题： 使用虚拟机安装时, 网卡默认没有激活
    ````
    cd /etc/sysconfig/network-script
    vi 要编辑的网卡
    更改 onboot = yes
    # 重启network
    systemctl restart network
    ````
2. 使用 `ip address` 命令查看IP地址
3. 导入GPG文件: `rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CENTOS-7`
    - GPG是RH官方发布的签名机制, 分为公钥和私钥, 用于判断软件是否是RH官方认证的
4. 安装net-tools工具, 安装gcc
5. 添加自启动
    ````
    # 在rc.local中添加自启脚本
    vi /etc/rc.d/rc.local
    # 格式： 程序名  程序路径
    a.sh  /home/a.sh

    # 脚本中添加命令即可. 注意给脚本提权
    systemctl restart sshd

    # 使用systemctl enable命令可以直接将服务设置为开机自启
    systemctl enable sshd
    # 具体更多的用法可以看附录, 包括systemctl和service启动服务的流程
    ````
6. 修改PS1： 在 `etc/profile` 中添加 `export PS1="[\u@AWS \W]\$ "` 然后 `source /etc/profile`
7. JAVA配置
    ````
    # 解压文件, 然后复制到/usr/local目录下
    mv jdk1.8.0_14 /usr/local/jdk1.8

    # 添加环境变量,添加到/etc/profile文件中, 永久生效, 对于all user
    vi /etc/profile
        export JAVA_HOME=/usr/local/jdk1.8
        export PATH=$JAVA_HOME/bin:$PATH
        export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

    # 更新环境变量
    source /etc/profile
    # 测试是否添加成功：
    echo $JAVA_HOME
    ````
8. 安装pip/scrapy
    ````
    # 根据[官方文档](https://pip.pypa.io/en/stable/installing/)安装pip
    # 安装扩展元EPEL
    yum -y install epel-release
    # 更换pip源
    cd ~|mkdir .pip|cd .pip
    echo "[global]  
    timeout = 6000  
    index-url = https://pypi.doubanio.com/simple/  
    [install]  
    use-mirrors = true  
    mirrors = https://pypi.doubanio.com/simple/" >> ~/.pip/.pip
    # 更新pip
    pip install --upgrade pip
    # 安装Scrapy时需要的依赖
    yum install libxslt-devel libffi libffi-devel python-devel gcc openssl openssl-devel
    # 安装scrapy
    pip install scrapy
    ````
9. docker: 默认使用阿里云的加速器
    ````
    # 安装docker
    curl -sSL http://acs-public-mirror.oss-cn-hangzhou.aliyuncs.com/docker-engine/internet | sh -
    # 加速器
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json <<-'EOF'
    {
    "registry-mirrors": ["https://pfonbmyi.mirror.aliyuncs.com"]
    }
    EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    ````