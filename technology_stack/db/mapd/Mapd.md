<!-- TOC -->

- [Mapd](#mapd)
  - [前言](#%E5%89%8D%E8%A8%80)
  - [Mapd 简介](#mapd-%E7%AE%80%E4%BB%8B)
  - [Mapd安装](#mapd%E5%AE%89%E8%A3%85)
  - [Mapd使用](#mapd%E4%BD%BF%E7%94%A8)
    - [CURD](#curd)
    - [服务启动](#%E6%9C%8D%E5%8A%A1%E5%90%AF%E5%8A%A8)
    - [根据时间查询](#%E6%A0%B9%E6%8D%AE%E6%97%B6%E9%97%B4%E6%9F%A5%E8%AF%A2)
    - [可视化](#%E5%8F%AF%E8%A7%86%E5%8C%96)
    - [配置](#%E9%85%8D%E7%BD%AE)
  - [现有问题](#%E7%8E%B0%E6%9C%89%E9%97%AE%E9%A2%98)
  - [参考](#%E5%8F%82%E8%80%83)
  - [总结](#%E6%80%BB%E7%BB%93)

<!-- /TOC -->

# Mapd

## 前言
- [CPU&&GPU 简介](/computer_org/alu/cpu-gpu.md)

## Mapd 简介
1. Mapd 分为两部分, 分别是 Mapd Core(数据库) 和 MapD Immerse(渲染引擎).
    - Mapd Core: 基于内存/显存, 列式存储, 且根据GPU特性设计, 运行在GPU/CPU上的的关系型数据库
        - [列式存储](/Program/Database/summary.md#行列数据库区别)
    - Mapd Immerse: 渲染引擎, 基于 Mapd Core + GPU 实现渲染
        - 可以在JS中使用 vega json 表达式定义渲染结构, 也可以在web页面直接创建
2. Mapd 版本更新很频繁, 有需要的同学应该多逛 github/官方文档. 
3. Mapd有三个版本：开源版本, 社区版和企业版
    - 开源版和社区版都不支持分布式, 开源版不支持渲染引擎.
4. Mapd性能因子: `GPU>GPU显存>CPU>内存`
    - GPU性能与GPU架构, CUDA核心数有关
    - Mapd 目前只支持 Navida

## Mapd安装
[Mapd安装教程](InstallMapd.md)

## Mapd使用
1. Mapd 管理方式
    - Madpql_shell: `$MAPD_PATH/bin/mapdql --db mapd -u mapd -p HyperInteractive`
    - web: `http://127.0.0.1:9092`
2. 查询数据库相关信息: 使用 `\+cmd` 执行命令, 举例：
    - `\h`： List all available backslash commands
    - `\memory_summary`： Print memory usage summary
3. [mapd 数据格式](https://www.mapd.com/docs/latest/mapd-core-guide/tables/)
    - TEXT: 字符串类型
4. [批量插入表数据](https://www.mapd.com/docs/latest/mapd-core-guide/loading-data/)
    - 插入数据之前必须保证表已经建好, 并且与数据的格式,排列相同. 这里讲下StreamInsert. 
    - StreamInsert: 以数据流的形式插入数据
    - 格式: 
        ````
        <data stream> | StreamInsert <table name> <database name> \
        {-u|--user} <user> {-p|--passwd} <password> [{--host} <hostname>] \
        [--port <port number>][--delim <delimiter>][--null <null string>] \
        [--line <line delimiter>][--batch <batch size>][{-t|--transform} \
        transformation ...][--retry_count <num_of_retries>] \
        [--retry_wait <wait in secs>][--print_error][--print_transform]
        ````
    - 示例: `cat test.csv | /opt/mapd/SampleCode/StreamInsert testdb test --host 127.0.0.1 --port 9091 -u test -p test  --delim ',' --batch 100000`
        - 批次不一定和实际的一样, 大一些也没关系


### CURD
1. 建db/user
    ````
    create user test (password = 'test',is_super = 'false');    # 创建用户
    create database db1 (owner = 'test');   # 创建数据库
    ````
2. 建Table/View 的两种方法
    - `CREATE TABLE IF NOT EXISTS tweets (...)`
    - 浏览器连接数据库后,可以直接导入数据,并且选择filed名和值类型
    
### 服务启动
1. 构建数据文件夹：`$MAPD_PATH/bin/initdb --data $MAPD_STORAGE`
2. 启动服务：`$MAPD_PATH/bin/mapd_server --data $MAPD_STORAGE &`
    - 默认gpu模式启动
    - 如果是通过脚本安装的mapd, 那么也可以使用 systemctl 启动/关闭 服务
3. 启动web服务：`$MAPD_PATH/bin/mapd_web_server &`

### 根据时间查询

- `EXTRACT(date_part FROM timestamp)`：从timestamp列返回制定值
- `EXTRACT(MONTH from "31-Oct-13 23:49:01")`; return: Oct
- `DATE_TRUNC(date_part, timestamp)`：使用制定的date格式截断timestamp
- `DATE_TRUNC(HOUR ,"31-Oct-13 23:49:01")`; return: `31-Oct-13 23`
````
select count(mmsi),EXTRACT(MONTH from receive_time),EXTRACT(DAY from receive_time)
from stellitedb
group by EXTRACT(MONTH from receive_time),EXTRACT(DAY from receive_time)
order by count(mmsi) desc
````

### 可视化
> [Vega官方文档](https://www.mapd.com/docs/latest/mapd-core-guide/vegaAtaGlance/)   
> [mapd/connector API文档](https://mapd.github.io/mapd-connector/docs/)   
> Mapd官方更新比较频繁, 这部分还是多看官方文档吧

1. Vega: Mapd使用 JSON Vega规范描述数据源和数据的可视化属性
    - 使用`connector.js`， `renderVega()` API发送 Vega文档 到后端，然后mapd返回一个PNG图像
    - [Vega html 示例](https://github.com/everywan/mapd_vega_demo/mapd.html). 由于官网更新比较频繁, 这里贴出官方地址[官方 Vega](https://www.mapd.com/docs/latest/mapd-core-guide/vegaAtaGlance/)
    - 渲染/前端 输出性能信息 `connector.logging(true)`
2. 可以在 浏览器界面直接生成图表

### 配置
> 配置文件在 `$MAPD_STORAGE/mapd.conf` 中

1. 关闭看门狗 `enable-watchdog = false`
    - mapd默认禁止执行一些比较费时间的查询. 比如默认禁止 `group by` float类型, 关闭看门狗后就可以了. 

## 现有问题
> 由于目前mapd还是比较新的技术,迭代很频繁.大家有空可以去github/官方文档看下最新的更新记录,这是我遇到的一些问题

1. join 当表2总数大于1000条后,连表查询失败
    - 社区版本, 当左表行数大于1000时，报错: `Hash join failed, reason: Could not build a 1-to-1 correspondence for columns involved in equijoin`.
    - 开源版本更新到新版本,问题消失. 社区版还没有解决问题.
    - 某些数据是可以的(社区版和开源版都行), [具体链接](https://github.com/mapd/mapd-core/issues/39) 
1. 开源版本不支持后端渲染
    - 官方回复称后续将会在开源版本支持
    - [参考](https://github.com/mapd/mapd-core/issues/8)
1. 社区版, 开源版本不支持分布式集群
    - 官方文档中的说明：  https://www.mapd.com/docs/latest/getting-started/distributed/#implementing-a-mapd-distributed-cluster 
    - Github讨论中的说明：  https://github.com/mapd/mapd-core/issues/26 
1. 不支持union
2. 查询最大限制为 一千万, 包括sql查询和渲染中的sql
    - 待验证: `mapd/mapd-core/blob/master/QueryEngine/Execute.h` 文件中的 `high_scan_limit` 变量设置了查询上限
    - 查询下限:(具体情境忘记了,大概是在一个很高的数量级时,若查询结果小于十条则会报错)
3. 以下两条sql语句, 当数据量大时,第二个会报错(超出GPU内存限制). 原因未知,估计跟mapd查询的某些机制有关
    ````
    SELECT * from test_a a join test_b b on a.mmsi=b.mmsi where a.mmsi=100000000 order by a.mmsi desc,a.time desc
    SELECT * from test_a a join test_b b on a.mmsi=b.mmsi where a.mmsi=100000000 order by a.time desc
    ````
4. TCP连接数 6 个, 
    - 新版貌似已经解决

## 参考
- [Mapd官方文档](https://www.mapd.com/docs/latest/mapd-core-guide/)  
- [Mapd官方社区](https://community.mapd.com/)   
- [Mapd_github](https://github.com/mapd/mapd-core)

## 总结
1. 遇到问题/bug, 不要瞎猜. 多去看**日志**, 多去**思考**, 用好**搜索引擎**
    - 这是一个合格程序员必须养成的习惯. 不论困难与否
2. 翻墙, 不然非常影响工作效率
    - 不翻墙, 很多事做起来会变得很麻烦, 比如说此次某些包的下载, 官方文档的查看, 源的更换. 因为墙的原因直接和简介浪费的时间都占一半了
    - google 搜出来的结果, 绝大多数都比百度/bing好太多了
3. 熟悉Linux
    - 类似 书到用时方恨少 的感觉吧. 不熟悉Linux时因为不会每一步操作都很有阻力.
4. 解决问题时, 如果是搜索引擎找不到的问题, 就去找文档, github 上的wiki,issues, 相关社区, 实在避不开就只能看源码了