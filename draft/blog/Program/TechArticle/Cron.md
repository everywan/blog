# CRON

<!-- TOC -->

- [CRON](#cron)
    - [介绍](#介绍)
    - [安装](#安装)
    - [使用](#使用)
        - [CRON表达式正常用法](#cron表达式正常用法)
        - [在Linux中使用CRON](#在linux中使用cron)
        - [检错](#检错)
        - [注意](#注意)
    - [示例](#示例)
    - [ETC](#etc)

<!-- /TOC -->

## 介绍
1. CRON表达式常用于计划任务.   
2. 在**Linux**中, cron表达式的精度通常为**一分钟**, 但是在其他环境中可能不一样(比如说, 之前作者在.NET中用到第三方工具的精度为秒)  
3. cron表达式就是一个字符串, 以5或6个空格隔开, 分为6或7个域, 每一个域代表一个含义, 

## 安装
1. centos 中, 安装 `yum install cronie.x86_64` 即可
2. ubuntu 自带cron服务
    - 与其他系统不同的是, ubuntu 可以直接输入 `crontab -e` 进入cron任务编写(部分centos版本也安装了crond)
3. 安装完成之后, 开启 crond 服务(ubuntu不需要)
4. 编写 xx.corn 脚本, 然后crontab xx.cron 即可加到cron任务中去

## 使用
### CRON表达式正常用法
1. `*` 任意值
    - 每小时 : `0 0 * * * * ?`
2. `?`: 可以匹配域的任意值, 但实际不会. 因为DayofMonth和 DayofWeek会相互影响
    - 每月的20日触发调度, 不管20日到底是星期几, 则只能使用如下写法 : `13 13 15 20 * ?`, 其中最后一位只能用`?`
    - week 从周末开始, 值从1开始
3. `-` : 表示范围
4. `/`: 表示起始时间开始触发, 然后每隔固定时间触发一次
5. `,` :表示列出枚举值值
6. L : 表示最后, 只能出现在DayofWeek和DayofMonth域 **没弄清楚的点**
    - DayofWeek域使用5L: 在最后的一个星期四触发.  
7. W: 表示有效工作日(周一到周五),只能出现在DayofMonth域, 系统将在离指定日期的最近的有效工作日触发事件
    - 在 DayofMonth使用5W
        - 如果5日是星期六, 则将在最近的工作日：星期五, 即4日触发
        - 如果5日是星期天, 则在6日(周一)触发
        - 如果5日在星期一 到星期五中的一天, 则就在5日触发
        - 注意：W的最近寻找不会跨过月份
8. LW : 这两个字符可以连用, 表示在某个月最后一个工作日, 即最后一个星期五.  
9. `#` : 用于确定每个月第几个星期几, 只能出现在DayofMonth域
    - 某月的第二个星期三：4#2
10. 星期（1~7 1=SUN 或 SUN, MON, TUE, WED, THU, FRI, SAT）

### 在Linux中使用CRON
- cron表达式为: `m h m n w`, 最小单位是分钟, 同时也兼容 `s m h m n w` 格式
- 常用命令：
    - `crontab xx.cron` 添加到当前用户的时程表
    - `crontab -l` 查看时程表
    - `crontab -r` 清除当前用户的时程表

### 检错
- 通过 `/var/spool/mail/$user` 或 `/var/log/cron.log` 查看cron的运行日志
    - ubuntu 需要到 `/etc/rsyslog.d/50-default.conf` 中开启 `cron.*   /var/log/cron.log` 才能记录日志
    - centos 会在运行命令时提示mail有更新

### 注意
- 使用`crontab -e`添加定时任务时, 必须退出vim, 改动的cron表达式才会生效, `:w`保存更改时, cron表达式不会生效
- Ubuntu 默认的 crontab 计划任务 的shell是 `/bin/sh` ,而 `/bin/sh` 是一个链接文件, 实质指向的是 `/bin/dash`, 所以在cron中执行脚本时, 如果不指定 `/bin/bash`, 有可能会出错
- 环境变量的读取: 系统自动执行调度任务时,是不会加载任何环境变量的(可以加载一些全局变量)
    - 指定路径执行: `/bin/bash aa.sh`
    - 初始化环境变量: `cron source /etc/profile; cmd` (source作用与`.`相同)
    - 声明环境变量: `declare -x JAVA_HOME="/usr/lib/jvm/jdk1.8.0_40"`

## 示例
- cron
    - 每隔5秒执行一次：*/5 * * * * ?
    - 每天23点执行一次：0 0 23 * * ?
    - 每天的0点、13点、18点、21点都执行一次：0 0 0,13,18,21 * * ?
    - 每周星期天凌晨1点实行一次：0 0 1 ? * L
    - 2020-2030年的每个月的最后一个星期五上午10:15执行作 : `0 15 10 ? * 6L 2020-2030` 
- Linux中
    - 整点执行, 且将执行脚本的 STDOUT 重定向到 test.log 中`0 1-23 * * * ? source /etc/profile;/root/Desktop/test.sh 1> /root/Desktop/test.log`
    - 最近在ubuntu系统上跑定时, 发现格式有所不同 `41 2 * * * /tmp/test.sh > /usr/tmp/test.log`, 其中时没有年的, 格式为 `M h d m w` 
    - 使用cron整点启动scrapy爬虫
    ````
    # timer.cron
    # 在centos中, 不需要加/bin/bash也可以正常运行. 原因 使用-注意
    0 0-23 * * * ? source /etc/profile;/bin/bash /root/script/startSpider.sh 2> /root/script/timer_cron.log
    # startSpider.sh
    set -x
    cd /mnt/PM25Spider/PM25Spider
    /usr/local/bin/scrapy crawl rankSpider
    set +x
    ````

## ETC
- [测试/自动生成网站](http://www.pdtools.net/tools/becron.jsp)
- [调试](/OS/Linux/useful.md): 配合 `set-x ... set+x` + 错误重定向 调试定时任务更简单清楚
- [cron 参考网站](http://www.cnblogs.com/junrong624/p/4239517.html)
- [linux_cron 参考网站](http://dgd2010.blog.51cto.com/1539422/1677211)
