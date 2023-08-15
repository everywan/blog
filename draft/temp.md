1. DDL: Data Definition Language, 数据库定义语言
2. DML: Data Manipulation Language, 数据库操作语言
3. DCL:Data Control Language, 数据库控制语言
4. TCL: Transaction Control Language, 事务控制语言


BI: Business Intelligence, 商业智能, 指用现代数据仓库技术, 线上分析处理技术, 数据挖掘和数据展现技术 进行商业分析以实现商业价值.


Mysql Binlog: 以事件形式记录所有的DDL和DML (不包括数据查询语句) 语句, 包含语句所执行的消耗的时间. MySQL的二进制日志是事务安全型的.
- 参考: https://dev.mysql.com/doc/refman/8.0/en/mysqlbinlog.html
- 一般来说开启二进制日志大概会有1%的性能损耗

mysqldumpslow: 查看 mysql 的慢查询 sql

1. 有监督学习: 给定的数据样本中, 包含真值判断. 如建模判断照片是否是猫, 每张图片标注真值.
2. 无监督学习: 无监督的任务中没有设置真值. 人们希望从中发现数据潜在的规律和模式.
  - 聚类: 给定数据集, 发现其中样本之间的相似性, 将样本聚类为组, 如根据 单车停放点 的位置聚类获取热点.
  - 关联: 给定数据集, 关联任务发现样本属性之间隐藏的关联模式. 如推荐系统中, 发现大多数喜欢A的人喜欢B, 则A B之间存在关联

常用模型
1. 分类模型: 多用于离散数据, 是为了寻找边界条件. 如根据图片判断是否是猫适用于分类模型.
2. 回归模型: 多用于连续数据, 是为了寻找最有拟合. 如根据面积等条件判断价格适用于回归模型.

模型是否成功的重要指标之一为 泛化, 常会有如下问题
1. 过拟合: 模型过度拟合测试数据, 而不能反映客观情况.
2. 欠拟合: 模型不能很好的拟合数据, 没有发掘出数据的规律.

FP: Functional Programming
OOP: Object-oriented Programming

软件工程 => 人件 => 模块化代码, 使每个人都是可被替代, 每块代码都是可替换的, 就像机器发展

Erlang: Joe Armstrong, `<Who OO Sucks>`
1. OO 四大问题
  - 数据结构和函数不应绑定在一起(Data structure and functions shold not be bound together)
  - 所有事物都必须是对象(Everything has to be an object)
  - 在面向对象语言中, 数据类型定义散播在各处(In an OOPL data type definitions are spread out all over the place)
  - 对象有私有状态(Object have private state)
