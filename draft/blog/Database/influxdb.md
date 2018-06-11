# Influxdb 时间序列数据库
> 参考1: [阿里云-时间序列数据的存储和计算 - 概述](https://yq.aliyun.com/articles/104243)   
> 参考2: [一些实践](https://github.com/GuoZhenghao/note/blob/master/DataBase/InfluxDB/Use/Use.md)  

<!-- TOC -->

- [Influxdb 时间序列数据库](#influxdb-时间序列数据库)
    - [时序数据库](#时序数据库)
    - [特点](#特点)
        - [名词解释](#名词解释)
        - [Point](#point)
    - [CRUD](#crud)

<!-- /TOC -->

## 时序数据库
> 摘抄自 [阿里云-时间序列数据的存储和计算 - 概述](https://yq.aliyun.com/articles/104243), 略有删改

1. 时间序列数据(Time Series): 一串按时间维度索引的数据. 描述某个被测量的主体在一个时间范围内的每个时间点上的测量值
1. 时序数据库的模型包含三个重要部分: 主体, 时间点和测量值
    - 主体: 被测量的主体, 一个主体会拥有多个维度的属性. 以服务器状态监控场景举例, 测量的主体是服务器, 其拥有的属性可能包括集群名,Hostname等. 
    - 测量值: 一个主体可能有一个或多个测量值, 每个测量值对应一个具体的指标. 还是拿服务器状态监控场景举例, 测量的指标可能会有CPU使用率, IOPS等, CPU使用率对应的值可能是一个百分比, 而IOPS对应的值是测量周期内发生的IO次数. 
    - 时间戳: 每次测量值的汇报, 都会有一个时间戳属性来表示其时间. 
2. 时序数据库: 一种专门针对时间序列数据来做优化的数据库系统
    - 随着物联网,大数据和人工智能技术的发展, 时序数据也呈一个爆发式的增长. 而为了更好的支持这类数据的存储和分析, 在市场上衍生出了多种多样的新兴的数据库产品. 这类数据库产品的发明都是为了解决传统关系型数据库在时序数据存储和分析上的不足和缺陷, 这类产品被统一归类为时序数据库.
3. 数据写入特点
    - 写入平稳,持续,高并发高吞吐
    - 写多读少
    - 实时写入最近生成的数据, 无更新: 除非人为更订, 否则每次插入的都应当是新数据
3. 数据读取的特点
    - 按时间范围读取
    - 最近的数据被读取的概率高
    - 多精度查询
    - 多维度查询
    - 数据挖掘
3. 数据存储的特点
    - 数据量大：拿监控数据来举例, 如果我们采集的监控数据的时间间隔是1s, 那一个监控项每天会产生86400个数据点, 若有10000个监控项, 则一天就会产生864000000个数据点. 在物联网场景下, 这个数字会更大. 整个数据的规模, 是TB甚至是PB级的. 
    - 冷热分明：时序数据有非常典型的冷热特征, 越是历史的数据, 被查询和分析的概率越低. 
    - 具有时效性：时序数据具有时效性, 数据通常会有一个保存周期, 超过这个保存周期的数据  可以认为是失效的, 可以被回收. 一方面是因为越是历史的数据, 可利用的价值越低；另一方 面是为了节省存储成本, 低价值的数据可以被清理. 
    - 多精度数据存储：在查询的特点里提到时序数据出于存储成本和查询效率的考虑, 会需要一个多精度的查询, 同样也需要一个多精度数据的存储. 
4. 时序数据库基本要求
    - 能够支撑高并发,高吞吐的写入：如上所说, 时序数据具有典型的写多读少特征, 其中95%-99%的操作都是写. 在读和写上, 首要权衡的是写的能力. 由于其场景的特点, 对于数据库的高并发,高吞吐写入能力有很高的要求. 
    - 交互级的聚合查询：交互级的查询延迟, 并且是在数据基数(TB级)较大的情况下, 也能够达到很低的查询延迟. 
    - 能够支撑海量数据存储：场景的特点决定了数据的量级, 至少是TB的量级, 甚至是PB级数据. 
    - 高可用：在线服务的场景下, 对可用性要求也会很高. 
    - 分布式架构：写入和存储量的要求, 底层若不是分布式架构基本达不到目标. 
4. 目前时序数据库使用的技术分析:
    - 结合时序数据的特点和时序数据库的基本要求的分析, 使用基于LSM树存储引擎的NoSQL数据库(例如HBase,Cassandra或阿里云表格存储等)相比使用B+树的RDBMS, 具有显著的优势. LSM树的基本原理不在这里赘述, 它是为优化写性能而设计的, 写性能相比B+树能提高一个数量级. 但是读性能会比B+树差很多, 所以极其适合写多读少的场景. 目前开源的几个比较著名的时序数据库中, OpenTSDB底层使用HBase,BlueFlood和KairosDB底层使用Cassandra, InfluxDB底层是自研的与LSM类似的TSM存储引擎, Prometheus是直接基于LevelDB存储引擎. 所以可以看到, 主流的时序数据库的实现, 底层存储基本都会采用LSM树加上分布式架构, 只不过有的是直接使用已有的成熟数据库, 有的是自研或者基于LevelDB自己实现. 
    - LSM树加分布式架构能够很好的满足时序数据写入能力的要求, 但是在查询上有很大的弱势. 如果是少量数据的聚合和多维度查询, 勉强能够应付, 但是若需要在海量数据上进行多维和聚合查询, 在缺乏索引的情况下会显得比较无力. 所以在开源界, 也有其他的一些产品, 会侧重于解决查询和分析的问题, 例如Druid主要侧重解决时序数据的OLAP需求, 不需要预聚合也能够提供在海量数据中的快速的查询分析, 以及支持任意维度的drill down. 同样的侧重分析的场景下, 社区也有基于Elastic Search的解决方案. 
4. 时间序列数据的处理
    - 对时序数据的处理可以简单归纳为Filter(过滤), Aggregation(聚合),GroupBy和Downsampling(降精度). 为了更好的支持GroupBy查询, 某些时序数据库会对数据做pre-aggregation(预聚合). Downsampling对应的操作是Rollup(汇总), 而为了支持更快更实时的Rollup, 通常时序数据库都会提供auto-rollup(自动汇总). 

## 特点
1. [名词解释](#名词解释): influxdb与传统数据库对表/一列数据的叫法不同
2. [Point](#Point): 表示表里的一行数据,由时间戳(time),数据(field),标签(tags)组成
3. [series](#series): ??表示表里面的数据, 可以在图表上画成几条线：通过tags排列组合算出来. 
4. 和Mapd相同,功能上只能增加, 不能更新和删除特定记录.(可以滚动删除)

### 名词解释
|influxDB中的名词|传统数据库中的概念
|:-------------|:-------------|
|database	|   数据库
|measurement|   数据库中的表
|points	    |   表里面的一行数据
### Point
Point属性	|传统数据库中的概念
|:-------------|:-------------|
time	    |   每个数据记录时间, 是数据库中的主索引(会自动生成)(RFC3339格式)
fields	    |   各种记录值(没有索引的属性)也就是记录的值：温度,  湿度(field不能被索引,所以查询会慢一些)
tags	    |   各种有索引的属性：地区, 海拔(可选,不一定有tags)

## CRUD
1. 显示帮助 `help`
2. 常规格式: 
    - `show databases/measurements/series ...`
    - `use/create/drop database/measurements ..`
3. 增加数据-SQL: `insert testTable,name=gzh,sex=male value=4,count=2 1435362189575692182`
    - query模式为: `table,tags fields`
    - fields 不支持字符串, 只能是 number/boolean
    - 1435362189575692182 是自己设置时间戳
3. 增加数据-HTTP: `curl http://localhost:8086/write?db=test --data-binary "testTable,name=gzh,sex=male value=4,count=2"`
    - 如果有密码 `u=用户名&p=密码`
    - `--data-binary`: 以二进制的方式post数据
3. 查询数据: 
    - SQL: `select * from qqq order by time desc limit 3`
    - HTTP: `curl http://localhost:8086/query?db=test --data-urlencode "q=select * from testTable"`
        - `--data-urlencode`: 自动转义特殊字符
4. 数据保存策略
    - 查看策略: `show retention policies on dbName`
    - 创建策略: `create retention policy 策略名 on 库名 duration 3w replication 1 default`
        - 3w：保存3周, 3周之前的数据将被删除, h(小时), d(天), w(星期)
        - replication 1：副本个数, 一般为1就可以了
        - default：设置为默认策略
    - 修改策略: `alter retention policy 策略名 on 库名 duration 30d default`
    - 删除策略: `drop retention policy 策略名`
5. 用户管理
    - 创建docker容器时: `docker run -d -p 8083:8083 -p 8086:8086 -p 2015:2015 -e INFLUXDB_ADMIN_USER="用户名" -e INFLUXDB_ADMIN_PASSWORD="密码" -e INFLUXDB_HTTP_AUTH_ENABLED="true" --name 容器名 镜像id`
    - 创建docker容器后
        ````
        //创建
        CREATE USER admin WITH PASSWORD 'password'
        //赋权
        GRANT ALL PRIVILEGES TO admin
        //打开认证
        vi /etc/influxdb/influxdb.conf
        [http]标签下auth-enables改为true
        ````
    - 修改密码: `SET PASSWORD FOR user = 'newpasswd'`
6. 连续查询: 当数据超过保存策略里指定的时间之后就会被删除, 但是这时候可能并不想数据被完全删掉, influxdb提供了连续查询, 可以做数据统计. 数据库中自动定时启动的一组语句, 语句中必须包含 SELECT 关键词和 GROUP BY time() 关键词采样
    - 查看策略: `show continuous queries`
    - 创建策略: `create continuous query 连续查询的名字 on 数据库名 begin select count(*) into 新的表名 from 当前表名 group by time(30m) end`
        - 30m：时间间隔为30分钟
        - 如果是不同的database的话, 写成库名.表名
    - 删除策略: `drop continous query 连续查询名字 on 库名`