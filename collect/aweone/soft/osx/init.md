## OSX 初始化安装
<!-- TOC -->

- [OSX 初始化安装](#osx-初始化安装)
    - [下载安装](#下载安装)
        - [搜狗输入法](#搜狗输入法)
        - [vscode](#vscode)
        - [chrome](#chrome)
        - [vmware](#vmware)
        - [vanilla](#vanilla)
        - [Instant Translate](#instant-translate)
    - [商店安装](#商店安装)
    - [终端安装](#终端安装)
        - [iTerm2](#iterm2)
    - [iCloud备份恢复](#icloud备份恢复)
        - [备份到iCloud](#备份到icloud)
        - [从iCloud恢复](#从icloud恢复)
    - [其他](#其他)
        - [虚拟机配置](#虚拟机配置)
            - [配置privoxy](#配置privoxy)

<!-- /TOC -->
### 下载安装
----
#### 搜狗输入法
- [搜狗输入法-下载地址](https://pinyin.sogou.com/mac/)
#### vscode
- [vscode-下载地址](https://code.visualstudio.com/)
#### chrome
- [chrome-下载地址](https://www.google.com/chrome/)
#### vmware
- [vmware-下载地址](https://www.vmware.com/go/getfusion)
- [虚拟机配置](#虚拟机配置)

#### vanilla
- [vanilla-下载地址](https://matthewpalmer.net/vanilla/)
    - vanilla 用来隐藏状态栏图标
#### Instant Translate
- [Instant Translate-下载地址](http://xclient.info/s/instant-translate.html?t=74822879aecdaf236a2c9ddc58f7a7dcc36d5758)
    - 状态栏翻译插件

### 商店安装
---
- wechat
- qq
- 网易云音乐
- irvue: 壁纸自动切换

### 终端安装
- [终端安装参见脚本](./install-init.sh)
    - `curl -sSL xx.sh | sh -` 可以下载并执行脚本, 也可以先 wget 下来 然后执行.

#### iTerm2
[iTerm2配置-参考文章](:http://huang-jerryc.com/2016/08/11/%E6%89%93%E9%80%A0%E9%AB%98%E6%95%88%E4%B8%AA%E6%80%A7Terminal%EF%BC%88%E4%B8%80%EF%BC%89%E4%B9%8B%20iTerm/)

[iTerm2配置文件地址](./iterm2.json)

修改如下: 
- 增加 hotkey window: 下拉终端, 快捷键 cmd+f2. 类似 linux-guake
- 修改透明度
- 添加 option+左右键 以单词为单位移动
- 自动操作-快捷键自动脚本:
    ```Bash
    open /Applications/iTerm.app/
    exit 0
    ```
### iCloud备份恢复
---
- 使用 `~/.bashrc` 作为自定义别名等配置. [样例参考](./bashrc). 功能如下
    - 常用别名
    - GOPATH/GOROOT 设置
    - shadowsocks / vscode 命令行启动

#### 备份到iCloud
- 第一次备份时使用. 若使用此恢复方式恢复, 则后续不再需要执行备份脚本.
```Bash
# bashrc
mkdir -p ~/Documents/backup
ln ~/.bashrc ~/Documents/backup/bashrc
# ssh
mkdir -p ~/Documents/backup/ssh
ln ~/.ssh/id_rsa ~/Documents/backup/ssh/
ln ~/.ssh/id_rsa.pub ~/Documents/backup/ssh/
# shadowsocks
mkdir -p ~/Documents/backup/shadowsocks
ln /etc/shadowsocks/shadowsocks.json ~/Documents/backup/shadowsocks/
```
#### 从iCloud恢复
- 只有按照备份脚本备份, 才能按此方式恢复. 使用此方式恢复后不再需要使用备份脚本
- 需要等待 iCloud 文稿部分下载完毕才能执行, 此处不再加入程序判断, 使用者自行判断吧.
```Bash
# 恢复 bashrc
ln ~/Documents/backup/bashrc ~/.bashrc
# 恢复 ssh 公钥私钥
mkdir -p ~/.ssh
ln ~/Documents/backup/ssh/id_rsa ~/.ssh/id_rsa
ln ~/Documents/backup/ssh/id_rsa.pub  ~/.ssh/id_rsa.pub
# 恢复 shadowsocks 配置
sudo mkdir -p /etc/shadowsocks
sudo chown $USER /etc/shadowsocks
ln ~/Documents/backup/shadowsocks/shadowsocks.json /etc/shadowsocks/shadowsocks.json
# ETC
# 添加 ~/.bashrc 到 /etc/bashrc 启动
addBashrc
function addBashrc(){
    sudo chmod +w /etc/bashrc
    sudo tee -a /etc/bashrc <<-'EOF'

source /Users/wzs/.bashrc
EOF
    sudo chmod -w /etc/bashrc
}
```

### 其他
- [科学上网-教程](/collect/aweone/soft/shadowsocks.md)

- 关于 Alfred: OSX 下常用的, 替代聚焦搜索的软件. 在聚焦搜索之上, 添加 `[直接执行Bash命令, workflow, 直接google等搜索引擎搜索]`, 可能还有其他的, 我没有体验到. 但是对于我而言, 更习惯 shell+chrome+vscode 三件套. (对于程序员, 命令行才是真的为所欲为啊...)
    - 常年 shell+chrome+vscode 挂载后台, 第二屏shell, 第一屏vscode+chrome, 偶尔切其他软件.
    - 直接执行Bash命令: iTerm2 下拉终端搞定
    - workflow: 别名+脚本, 好用还好写
    - 直接google等搜索引擎搜索: chrome都没关过..切过去搜索没多大差别吧..

- [Navicat Premium](http://xclient.info/s/navicat-premium.html?t=c0321e621d18b21e2ba8791a627b3f9bc45dd6a9): 数据库管理软件. (想支持正版的, 但是价格 3999...)
    - 下载完打开时, 会报错, 执行以下命令 `xattr -cr /Applications/Navicat\ Premium.app/`, 然后就可以正常打开了.

#### 虚拟机配置
1. 下载镜像: centos-Minimal.iso
    ```Bash
    wget -c https://mirrors.aliyun.com/centos/7.5.1804/isos/x86_64/CentOS-7-x86_64-Minimal-1804.iso
    ```
2. ssh 链接虚拟机特别慢: 在 `/etc/ssh/sshd_config` 中启用 `UseDNS:no`
3. 拷贝公钥, 免密访问: `ssh-copy-id wzs@192.168.165.100`
4. [初始化安装脚本](./centos-install-init.sh)
5. 配置静态IP
    ```Bash
    sudo vim /etc/sysconfig/network-scripts/ifcfg-ens33
    // 修改
    BOOTPROTO="static"
    // 添加, 可以 通过 ifconfig/`ip addr` 查看自己现在的ip
    IPADDR=192.168.165.129  // 想要的静态地址, 192.168.165 是我的虚拟机的网段, 根据自身要求修改.
    NETMASK=192.168.165.255
    GATEWAY=192.168.165.1
    DNS1=...
    DNS2=8.8.8.8
    ```
6. 修改vmware网卡配置:
    - `vim /Library/Preferences/VMware\ Fusion/networking`
    - 修改 `answer VNET_8_HOSTONLY_SUBNET 172.16.120.0` 为与宿主机同网段 `192.168.165.0`
    - 注意, 如果修改 VMnetworking, VNET_8 的网关地址可能已经更改. 所以在虚拟机中设置静态IP时, 应该重新设置网关为 `192.168.165.2`
    - vmnet8配置文件位置 `/Library/Preferences/VMware Fusion/vmnet8/nat.conf`

##### 配置privoxy
下载源码-安装教程参见 [centos-install-init.sh - install_privoxy](./centos-install-init.sh)

[privoxy 配置教程](/collect/aweone/soft/shadowsocks.md#搭建HTTP代理服务)

添加到 systemd, 使用 systemctl 管理服务
1. 添加到 systemd:
    - 编写脚本: [privoxy.service-脚本参考](./privoxy.service)
    - 添加服务脚本到 `/etc/systemd/system/multi-user.target.wants/` 下
    - 重启systemd守护进程: `sudo systemctl daemon-reload`
2. 使用以下命令检测是否成功
    ```Bash
    sudo systemctl start privoxy.service
    sudo systemctl status privoxy.service
    ```
