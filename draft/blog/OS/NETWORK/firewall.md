# 防火墙

<!-- TOC -->

- [防火墙](#防火墙)
    - [iptables](#iptables)
    - [firewall](#firewall)
        - [iptables firewall区别](#iptables-firewall区别)
    - [ufw](#ufw)

<!-- /TOC -->

## iptables
> 参考 https://wiki.archlinux.org/index.php/Iptables_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)

- 查看端口信息： `iptables -L -n`
- 添加端口到INPUT： `iptables -I INPUT -p tcp -m tcp --dport 38634 -j ACCEPT`
- 更新防火墙规则： `iptables-save`

## firewall
> 目前centos7默认使用的防火墙为firewall

- 查看端口是否开启: `firewall-cmd --query-port=80/tcp`
- 查看防火墙的规则: `firewall-cmd –-list-all`
- 开通端口: `firewall-cmd --zone=public --add-port=80/tcp --permanent`
    - `--zone`: 作用域
    - `--add-port=80/tcp` : 添加端口, 格式为：端口/通讯协议
    - `--permanent` : 永久生效, 没有此参数重启后失效
- 更新防火墙规则 : `firewall-cmd --reload`
- 查看服务在防火墙中的状态: `firewall-cmd –query-service ssh`
- 查看版本: `firewall-cmd --version`

### iptables firewall区别
- **iptables** ：用于过滤数据包, 属于网络层防火墙
- **firewall** ：能够允许哪些服务可用, 哪些端口可用…. 属于更高一层的防火墙. firewall的底层是使用iptables进行数据过滤, 建立在iptables之上. 
- 日常使用 firewall 就行了, 没必要使用 iptables. 就像使用 systemctl 替代 service


## ufw
> 参考 http://wiki.ubuntu.org.cn/Ufw%E4%BD%BF%E7%94%A8%E6%8C%87%E5%8D%97

- iptables 的前端, iptables 的简易版.
