<!-- TOC -->

- [MongoDB](#mongodb)
    - [基础](#基础)
        - [复制集](#复制集)
    - [CRUD](#crud)
    - [Mongo_Python](#mongo_python)
    - [ETC](#etc)

<!-- /TOC -->

# MongoDB

Mongo数据库不同于传统的关系型数据库
1. 数据以JSON格式存储
2. 也可以将JSON格式插入数据库, 且不同项列是可以不同的
3. 查询语句也更类似JSON格式
4. 插入时可以自动创建库和表, 不必先建好

## 基础
1. Mongo URI 格式: `mongodb://[username:password@]host1[:port1][,host2[:port2],...[,hostN[:portN]]][/[database][?options]]`
    - 如果要链接复制集, 需要指定多个host.
    - options 设置, 参考 http://www.runoob.com/mongodb/mongodb-connections.html
        - `replicaSet=name`: 验证replica set的名称

### 复制集
> 参考: [MongoDB复制集原理](http://www.mongoing.com/archives/2155)
1. 复制集(Replica Set): 由一组拥有相同数据集的mongod实例做组成的集群, 主从结构
2. 复制集包含如下节点(参考zookeeper理解)
    - 活跃节点(Primary 1个): 即 master节点, 所有数据写入master节点, 然后同步到备份节点
    - 备份节点(Secondary 不少于1个): 用于备份, 且主节点挂掉后 由备份节点推选出新的主节点
    - 仲裁节点(不多于1个, 可以没有): 即投票节点,只参与投票, 不参与选举. 可以部署在其他节点上(即不需要硬件设备). 用于保证复制集中有奇数个投票成员
3. 主从结构/复制集 区别: 副本集没有固定的主节点. 当节点故障时, 能选举新的主节点, 大大的提升了整个系统中数据存储的稳定性
4. 数据同步
    - Primary与Secondary之间通过oplog来同步数据, Primary上的写操作完成后, 会向特殊集合 `local.oplog.rs` 写入一条oplog, Secondary不断的从Primary取新的oplog并应用.
    - oplog 具有幂等性, 即重复应用也会得到相同的结果
    - Secondary 初次全量同步, 之后通过oplog同步

## CRUD
> CRUD: Create, Read, Update, Delete

在 shell 中操作 mongoDB
1. 命令行链接: `mongo [ip]:[port]/[db] --authenticationDatabase [auth_db] -u [root] -p[xskj@032]` (`[]`内为必填内容,当数据库有密码时需添加`authenticationDatabase`,认证数据)
1. `use dbName`
    - 当存在该 dbName 时, 切换到该数据库
    - 当不存在该数据库时, 创建该数据库
2. `list dbs`
    - 对于新建的数据库, 只有插入数据后, 才会显示该库
2. `find({条件},{显示列})`
    ````
    # lt/gt: less/greater than
    db.coll.find(
        {"dimHour":{"$lt":"20","$gt":"18"}},
        {"dimHour":1}
    )
    ````
2. `update({},{},boolean,boolean)`
    - 参考： http://www.jianshu.com/p/8972bca12b95
    - 第一个参数是条件, 第二个参数是符合条件时插入的新记录, 第三个参数是: 如果没有符合条件的值则插入,第四个参数是是否更改多个匹配的记录
2. `remove({})` 删除记录(只删除文档，不删除表和索引)
    - `deleteOne()/deleteMany()` 删除所有, 包括索引
2. [聚合查询](/Program/Database/aggregate_search_Mongo.md)
3. mongo导出数据: mongoexport/mongodump
    - `mongoexport -d test -c shipxy --type=csv --fields mmsi -u "root" -p "test" -h 127.0.0.1:27017 --authenticationDatabase "admin" --out shipxy.csv`
    - `mongodump -u "root" -p "test" --host 127.0.0.1 --port 27017 -o /tmp/test/`
    - [官方帮助文档](https://docs.mongodb.com/manual/reference/program/mongoexport/)
5. ObjectId: 12-bytes
    - 4-byte: Unix时间戳, 精确到秒
    - 3-byte: 机器ID: 一般为主机名称的散列值
    - 2-byte: 进程ID
    - 3-byte: 计数器, 从一个随机值开始的递增器
5. 查询数据元素:  `db.getCollection('cityInfo').find({},{"alias[0]":1,"_id":0})`

## Mongo_Python
1. 数据库的连接和操作
    ````
    from pymongo import MongoClient
    from urllib import quote_plus
    // 连接数据库
    uri = "mongodb://%s:%s@%s" % (quote_plus('user'), quote_plus('pass'), 'ip:port')
    dbClient  = MongoClient(uri)
    dbClient = MongoClient("ip",port)
    dbname = "dbname"
    db_ccode = dbClient[dbname]
    // 选取表
    ccode_coll = db_ccode["collname"]
    // 操作, 第一个{}里是查询条件, 第二个{}里是决定显示哪些列
    // 返回 JSON 文件
    jsonfile = ccode_coll.find_one({"name":{"$regex":City + ".*"}},{"code" : 1,"_id":0})
    // 同上, 只不过 `find()` 函数返回迭代器
    iter = ccode_coll.find({"name":{"$regex":City + ".*"}},{"code" : 1,"_id":0})
    // 插入item项
    iter = ccode_coll.insert(coll_item)
    // 同上, 不过如果表中有对应ID, 则更新该值而不插入
    iter = ccode_coll.save({"name":{"$regex":City + ".*"}},{"code" : 1,"_id":0})
    ````
2. 注意
    - 使用Scrapy插入数据时, 出现 `_id` 字段不存在
        - 在插入的item中添加 `_id` 字段
    - 使用Scrapy插入数据时, 出现 `_id` 重复 错误
        - 目前不清楚pymongo中**ObjectId**的生成策略, 按照 ObjectId 特性而言, 在并发/并行条件下当是唯一的
        - 问题: ObjectId 是在pymongo中生成, 还是在MongoDB中生成(item中无_id字段时)
9. [PyMongo_API](http://api.mongodb.com/python/current/tutorial.html)

## ETC
- [Mongo CRUD](https://docs.mongodb.com/manual/crud/)
- [增删改查 How](http://www.cnblogs.com/qwj-sysu/p/4428434.html)
- [mongodump原理](http://www.mongoing.com/archives/2605)
