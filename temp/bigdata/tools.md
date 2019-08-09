# 工具

Google 三驾马车: GFS, MapReduce, BigTables.

Google 在 2003-06 年发布了相关论文, 但是未开源算法, 后与 2006 年 Yahoo 牵头开发了 Hadoop 套件系统.

GFS: Google File System, 分布式文件系统, 数据一致性, 节点容错, 

MapReduce: 并行计算, 分布式计算, 分为两阶段: Map 和 Reduce.

BigTables: 

RDD: 

hadoop: 
- 参考
  - [](https://hadoop.apache.org/docs/r1.0.4/cn/hdfs_design.html)
- 设计思想
  - 硬件错误是常态
  - 移动计算比移动数据更划算
  - ...

hdfs: Hadoop Distributed File System, hadoop 分布式文件系统

hbase: 

spark: 

hive
- 外表/内表: 内表的数据由hive管理, 删除表时会直接删除数据和元数据. 外表的数据由hdfs管理, 删除表时只删除表的元数据, 不删除数据.

prestodb: 交互式查询引擎, 用于替代hive. hive 使用 MapReduce 作为底层框架, 适合批处理, 离线计算, 比较耗时. 而 prestodb 是 facebook 用于替代 hive, 进行交互查询的工具.
- 参考:
  - [Presto docs](http://prestodb.github.io/docs/current/)
  - [Presto实现原理和美团的使用实践](https://tech.meituan.com/2014/06/16/presto.html)

hue

erm

quix


