<!-- TOC -->

- [Everywan.Study](#everywanstudy)
    - [编程](#编程)
        - [编程语言](#编程语言)
            - [Python](#python)
            - [Golang](#golang)
            - [Java](#java)
            - [MarkDown](#markdown)
            - [前端](#前端)
            - [其他语言](#其他语言)
        - [数据库](#数据库)
        - [技术文章](#技术文章)
            - [底层](#底层)
            - [应用层](#应用层)
        - [算法](#算法)
        - [实践](#实践)
    - [OS](#os)
        - [LINUX](#linux)
        - [docker](#docker)
        - [network](#network)
        - [Install](#install)
    - [收集](#收集)

<!-- /TOC -->

# Everywan.Study

- [摘抄本目录](摘抄本/SUMMARY.md)  
- [问题列表](Question.md)

## 编程
---
### 编程语言
- [总结](Program/Language/summary.md)
- [通用知识](Program/Language/common.md)
#### Python
- [Sec1-基础](Program/Language/Python/Sec1_basis.md)
- [Sec2-模块](Program/Language/Python/Sec2_module.md)
- [Sec3-网络编程](Program/Language/Python/sec3_network.md)
- [Sec4-单元测试&&异常](Program/Language/Python/sec4_unitTest.md)
- [协程](Program/Language/Python/Coroutines.md)
- [Tornado](Program/Language/Python/Tornado.md)
- [多线程和多进程](Program/Language/Python/ThreadAndProcess.md)
#### Golang
- [Go简介](Program/Language/Golang/summary.md)
- [Go基础](Program/Language/Golang/Base.md)
    - [单元测试](Program/Language/Golang/UtilTest.md)
- [Go进阶](Program/Language/Golang/Advanced.md)
- [Go数组/切片](Program/Language/Golang/Array.md)
- [Go结构体](Program/Language/Golang/Struct.md)
#### Java
- [Java](Program/Language/Java/summary.md)
    - [数据库连接池](Program/Language/Java/summary.md#数据库连接池)
    - [Maven](Program/Language/Java/summary.md#Maven)
- [Spring Boot及其相关](Program/Language/Java/SpringBoot.md)
    - [Swagger](Program/Language/Java/SpringBoot.md#swagger)
    - [Mybatis](Program/Language/Java/SpringBoot.md#mybatis)
    - [分布式事务](Program/Language/Java/SpringBoot.md#分布式事务)
- [Spark](Program/Language/Java/Spark.md)
- [NIO](Program/Language/Java/NIO.md)
#### MarkDown
- [Markdown](Program/Language/Markdown/Markdown.md)
#### 前端
- [前端技能学习](Program/Language/FrontEnd/summary.md)
#### 其他语言
- [C++](Program/Language/OtherProgram/summary_C++.md)
    - 有空重新看下C++ Primer, 已经忘的差不多了
- [Bash](Program/Language/OtherProgram/summary_Bash.md)
- [HTML](Program/Language/OtherProgram/summary_HTML.md)

### 数据库
- [基本知识](Database/summary.md)
- [传统SQL数据库](Database/SQL.md)
- [常用SQL语句](Database/SQL.sql)
- [Mysql](Database/Mysql.md)
- [Mongo](Database/Mongo.md)
- [Mapd](Database/Mapd.md)
- [Influxdb](Database/influxdb.md)
- [其他](Database/Others.md)

### 技术文章
#### 底层
- [基础技能](Program/TechArticle/common.md)
- [内存分配](Program/TechArticle/memory_allocation.md)
- 基础类型
    - [Array](Program/TechArticle/Array.md)
    - [HashMap](Program/TechArticle/Hashmap.md)
- [求值策略](Program/TechArticle/Evaluation.md)
- [编码](Program/TechArticle/Encode.md)
- [浅析GC原理](Program/TechArticle/GC.md)
- [缓存相关](Program/TechArticle/Cache.md)
#### 应用层
- [反射](Program/TechArticle/Reflect.md)
    - [注解](Program/TechArticle/Annotation.md)
- [正则表达式](Program/TechArticle/Regex.md)
- [线程和进程](Program/TechArticle/ThreadAndProcess.md)
- [RESTful](Program/TechArticle/RESTful.md)
- [Cron表达式](Program/TechArticle/Cron.md)
- 留坑
    - [作用域和闭包](Program/TechArticle/Closure.md)
    - [匿名函数&Lambda](Program/TechArticle/Lambda.md)

### 算法
- [总结](Program/Algorithm/SUMMARY.md)
- [浮点数精确度缺失思考](Program/Algorithm/Precision_deletion.md)

### 实践
- [性能计数器_C#](Lib/CodeTimer_NET.md)
- [打包第N层目录_Bash](Lib/ZipNLevelFile_Bash.md)
- [数学函数收集](Lib/MathFun.md)
- [推特SnowFlake算法](Lib/SnowFlake.md)
- [查询地点信息_高德](Lib/GeoCode.md)

## OS
---
### LINUX
- [基础命令](OS/Linux/summary.md)
- [目录结构](OS/Linux/FHS.md)       `# 未完成`
- [日志系统](OS/Linux/LinuxLog.md)  `# 未完成`
- [系统守护进程](OS/Linux/systemd.md)
- [版本控制](OS/Linux/RevisionControl.md)
- [VIM/GDB](OS/Linux/VIM.md)
- [make命令](OS/Linux/Make&Install.md)
- [文件/字符串查找](OS/Linux/Find.md)
- [硬盘分区/格式化/挂载](OS/Linux/Mount.md)
### docker
- [须知](OS/docker/README.md)
- [常用命令](OS/docker/summary.md)
- [容器启动流程](OS/docker/workflow.md)
- [使用 Dockerfile 定制镜像](OS/docker/dockerfile.md)
### network
- [基础概念](OS/NETWORK/summary.md)
- [NMAP](OS/NETWORK/nmap.md)
- [防火墙](OS/NETWORK/firewall.md)
- [保留IP地址的分配](OS/NETWORK/KeepIP.md)
- [代理服务搭建](OS/NETWORK/shadowsocks.md)
- [网络问题排查](OS/NETWORK/WebError.md)
- [域名注册/备案文档](OS/NETWORK/DomainRecord.md)
### Install
- [centos最小化安装配置](OS/Install/setcentos.md)
- [推荐软件安装脚本](OS/Linux/CoolSoft.sh)
- [Install Mapd](OS/Install/InstallMapd.md)
- [搭建基于docker的Hadoop分布式系统](OS/Install/docker+hadoop.md)

## 收集
---
- [摘抄文章](ETC/collectArticle.md)
- [编程习惯](ETC/Words.md)
- [有意思的网站](ETC/WebSite.md)
- [VMware各文件详解](ETC/VMware.md)
- [微软开发技术发展过程](ETC/Microsoft.md)
