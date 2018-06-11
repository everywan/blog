# Linux系统守护进程
> 参考: http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html

<!-- TOC -->

- [Linux系统守护进程](#linux系统守护进程)
    - [Systemd](#systemd)
    - [systemctl](#systemctl)
    - [Service](#service)
        - [添加到系统服务](#添加到系统服务)
    - [服务状态解释](#服务状态解释)

<!-- /TOC -->

## Systemd
- 介绍: Linux 系统工具，用来启动守护进程，为系统的启动和管理提供一套完整的解决方案.
- 功能: 是用于集中管理和配置类UNIX系统.

## systemctl
- Systemctl是一个systemd工具，主要负责控制systemd系统和服务管理器。
```Bash
systemctl is-enabled iptables.service
systemctl is-enabled servicename.service    # 查询服务是否开机启动
systemctl enable *.service  # 开机运行服务
systemctl disable *.service # 取消开机运行
systemctl start *.service   # 启动服务
systemctl stop *.service    # 停止服务
systemctl restart *.service # 重启服务
systemctl reload *.service  # 重新加载服务配置文件
systemctl status *.service  # 查询服务运行状态
systemctl --failed  # 显示启动失败的服务
```
- 举例: `systemctl restart network`
    - systemctl 会去寻找 `/etc/init.d` 下的network脚本, restart是network脚本里的一个参数(可以查看network这个脚本支持的参数), 然后告诉系统运行network这个脚本, 剩下的事情就交给network脚本去做. 
- 编写属于自己的service：编写一个脚本, 然后把它放在 `/etc/init.d` 这个目录下, 然后就可以用 `service start script` 运行. 
- 简单例子： http://blog.chinaunix.net/uid-11582448-id-745416.html

## Service
### 添加到系统服务
1. `cp /安装目录下/apache/bin/apachectl /etc/rc.d/init.d/httpd`
2. `chkconfig --add httpd`
3. `chkconfig --level 345 httpd on`

## 服务状态解释
> 摘自 鸟哥的linux教程 书籍

- `active (running)`： 正有一隻或多隻程序正在系統中執行的意思, 舉例來說, 正在執行中的 vsftpd 就是這種模式. 
- `active (exited)`： 僅執行一次就正常結束的服務, 目前並沒有任何程序在系統中執行.  舉例來說, 開機或者是掛載時才會進行一次的 quotaon 功能, 就是這種模式！ quotaon 不須一直執行～只須執行一次之後, 就交給檔案系統去自行處理囉！通常用 bash shell 寫的小型服務, 大多是屬於這種類型 (無須常駐記憶體). 
- `active (waiting)`： 正在執行當中, 不過還再等待其他的事件才能繼續處理. 舉例來說, 列印的佇列相關服務就是這種狀態！ 雖然正在啟動中, 不過, 也需要真的有佇列進來 (列印工作) 這樣他才會繼續喚醒印表機服務來進行下一步列印的功能. 
- `inactive`： 這個服務目前沒有運作的意思
