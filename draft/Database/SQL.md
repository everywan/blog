<!-- TOC -->

- [传统SQL数据库](#%E4%BC%A0%E7%BB%9Fsql%E6%95%B0%E6%8D%AE%E5%BA%93)
  - [基础知识](#%E5%9F%BA%E7%A1%80%E7%9F%A5%E8%AF%86)
    - [Union/union all](#unionunion-all)
    - [distinct](#distinct)
    - [事务隔离级别](#%E4%BA%8B%E5%8A%A1%E9%9A%94%E7%A6%BB%E7%BA%A7%E5%88%AB)
    - [事务传播行为](#%E4%BA%8B%E5%8A%A1%E4%BC%A0%E6%92%AD%E8%A1%8C%E4%B8%BA)
    - [索引](#%E7%B4%A2%E5%BC%95)
    - [事件](#%E4%BA%8B%E4%BB%B6)
      - [定时规则](#%E5%AE%9A%E6%97%B6%E8%A7%84%E5%88%99)
  - [JDBC](#jdbc)
  - [规范](#%E8%A7%84%E8%8C%83)
  - [ETC](#etc)

<!-- /TOC -->

# 传统SQL数据库

## 基础知识
1. `DATEADD(HOUR,-4,GETDATE())` 根据 `GETDATE()` 时间调整（可调整  前/后  小时/分钟/等）
1. LEFT JOIN：从左表返回所有行, 即使右表中没有匹配行
    -  A LEFT JOIN B, 则会：A中列, B中符合Join要求的列
1. RANK()：排名函数
    - RANK()  OVER ( PARTITION BY CON1 ORDER BY CON2)AS ..
    - 执行顺序为：先PARTITION分区, 而后分区内ORDER排序, 排序后才RANK排名
2. `@` 自定义变量 `@@` 系统变量  `Cursor` 游标
    - 游标：`Cursor c is select .. from ..`
    - 游标和临时表对比：内存/硬盘, 数据量两方面考虑
2. 注意数据库字段, 表名的长度限制. Oracle是30个字符
2. Union/union all：[示例](#union)
2. COUNT(*), COUNT(PK), COUNT(1)都是用来统计列数的
    - *为所有行数, 包括null
2. distinct: 用于返回唯一不同的值. 即 相同值(单列/多列 相同)只保留1个
3. SQL SERVER 中单页长度为8kb, 且不允许一行数据存储在不同页上
    - `{(varchar(max)),nvarchar(max)),text,ntext,varbinary(max),image}` 类型除外
    - 可用字节数: 8060 = 8kb - 132(系统信息)
3. 外键必须是另一个表的主键
3. 架构（模式）：数据库下的一个逻辑命名空间, 是一个数据库对象
    - 作用：便于管理数据库对象, 即对数据库对象进行逻辑划分, 将解决同类问题的对象放置到一个架构中
3. 关系规范化：规范化的过程就是让每个关系模式概念单一化的过程
    - x-->y：y依赖于x, x是决定因子
    - 第一范式：不包含非原子项的属性
    - 第二范式：所有非主属性都完全依赖于主键
    - 第三范式：所有非主属性都不传递依赖于主键
    - BCNF：当且仅当每个函数以来的决定因子都是候选键时
    - 多值依赖：一组函数值的依赖
    - 链接依赖：R拆分成R1和R2后还能再连接得到R, 即无损联结
4. SQL Server中 `@@ROWCOUNT` 返回受上一语句影响的行数, 返回值类型为int, 如果行数大于20亿, 需要使用 `ROWCOUNT_BIG`. 
4. EXEC 执行存储过程
4. 分区表：将数据按某种标准划分成不同区域存储在不同文件组
4. 外键使用的键必须是主键或者unique约束的列
4. 触发器中可以使用inserted/deleted两个特殊的临时表. 并且只能用在触发器代码中, 与建立触发器的表的结构完全相同
    - inserted：insert中新插入的数据/update中更新后的数据
    - deleted：delete操作删除的数据/update更新前的数据
4. 所有create/alter数据库/数据库对象, drop语句都不允许在触发器中使用. 
4. 收缩数据库大小：创建完毕之后新增的才可以收缩. 初始大小固定不可收缩
5. [ODBC, OLEDB, ADO, ADO.Net的演化简史](http://www.cnblogs.com/liuzhendong/archive/2012/01/29/2331189.html)
    - 从刚开始直接操作DB的时代, 到ODBC标准搞定关系数据库, 到OLE DB搞定关系型+非关系型数据库, 到ADO, 一步步封装
    - ![ODBC, OLEDB, ADO, ADO.Net的演化简史](/attach/ADO.png)
7. `SET NOCOUNT ON`：不返回 ..行受到影响
8. mysql隐式类型转换: int 与 varchar 比较时, 会自动将 varchar 隐式转换为int, 所以varchar前的 0 会被丢掉. 隐式转换后不走索引, 要尽量避免
9. 在 sql 脚本中, 查询结果为结果集(多余1条)时, 不能直接赋值给变量. 可以使用游标或使用表变量, 或者使用 while 循环依次查询(还不如游标). sql的变量只是基础类型中的哪几种类型, 不能承载结果集. sql查询要确立面向集合的思想. 游标等只能在存储过程中使用. 存储过程和存储函数都会被mysql存储并且编译.
  - http://tool.oschina.net/apidocs/apidoc?api=mysql-5.1-zh

### Union/union all
1. Union All：对两个结果集进行并集操作, 包括重复行, 不进行排序
    - 示例:
    ````
    select top 5 OrderID,[EmployeeID] from dbo.Orders where EmployeeID=1
    union all
    select top 5 OrderID,[ProductID] from [Order Details] where ProductID=1
    ````
    - 结果
        - ![union all](/attach/sql_unionall.png)
2. Union：对两个结果集进行并集操作, 不包括重复行, 同时进行默认规则的排序
    - Union: 示例
    ````
    select top 5 OrderID,[EmployeeID] from dbo.Orders where EmployeeID=1
    union
    select top 5 OrderID,[ProductID] from [Order Details] where ProductID=1
    ````
    - 结果
        - ![union](/attach/sql_union.png)

### distinct

### 事务隔离级别
> https://www.jianshu.com/p/4e3edbedb9a8

### 事务传播行为


### 索引
> 参考: [SQL索引一步到位](http://www.cnblogs.com/AK2012/archive/2013/01/04/2844283.html)

1. 聚集索引/非聚集索引：是否是物理排序
    - 聚集索引(物理排序)：创建聚集索引后, 表内行顺序按照聚集索引列顺序排序, 所以聚集索引只能有一个
2. 非聚集索引行定位器是
    - 指向行的指针（文件标识符+页码+行序号生成）
    - 该行的聚集索引关键字的值. 
3. SQL SERVER 采用 B- 树结构, 非聚集索引是一个新实体（类似术语表）
4. 原则上where字句上出现的列都需要创建索引：不然还是会到表中查询
5. 避免在WHERE条件中, 在索引列上进行计算或使用函数：这将导致索引不被使用
6. 保证索引排序和Order By 字句顺序保持一致
7. 数据重复列高的字段不要创建索引：没有意义
8. text, varchar(max)不创建索引
9. 外键和用于做表连接的字段需要做单独的索引：如果外键列缺少索引, 从关联子表的查询就只能对子表选择全表扫描
10. 经常更改的列不创建索引：维护成本太高

### 事件
1. 示例: [事件](/Database/SQL.sql) 搜索: `事件 定时策略`
2. 配置文件开启事件支持: 
    ````
    [mysqld]
    event_scheduler=ON //这一行加入mysqld标签下
    ````
#### 定时规则
1. 周期执行: every, 单位 second,minute,hour,day,week,quarter,month,year
    - `on schedule every 1 second` 每秒执行1次
    - `on schedule every 2 minute` 每两分钟执行1次
    - `on schedule every 1 day starts timestamp(current_date,'00:00:00')` 每天零点执行, every 可以和 starts/ends 结合使用
2. 在具体的时间执行: at
    - `on schedule at current_timestamp()+interval 5 day` 5天后执行
    - `on schedule at '2016-10-01 21:50:00'` 在指定时间执行
3. 在某个时间段执行 starts/ends
    - `on schedule every 1 day starts current_timestamp()+interval 5 day ends current_timestamp()+interval 1 month` 5天后开始每天都执行执行到下个月底
    - `on schedule every 1 day ends current_timestamp()+interval 5 day` 从现在起每天执行, 执行5天
    - 

## JDBC
1. SQL 参数填充
    ````
    Connection conn = mapdutil.basicDataSource.getConnection();
    String sql = "select * from testdb where lon BETWEEN ? AND ? AND receive_time BETWEEN ? AND ?"
    ps = conn.prepareStatement(sql);
    // 从1开始
    ps.setDouble(1, Double.parseDouble(minlon));
    ps.setDouble(2, Double.parseDouble(maxlon));
    ps.setTimestamp(3, Timestamp.valueOf(startTime));
    ps.setTimestamp(4, Timestamp.valueOf(endTime));
    ps.executeQuery();
    ````

## 规范
1. 脚本头规范：参考别人写的就行了. 
    ````
    作者 / 创建时间 / 修改人 / 修改时间 / 对应系统模块 / 描述
    参数注释
    TRANSACTION事务注释
    ````
1. 存储过程规范：
    - `过程名称, 作者, 功能说明, 创建日期, 维护记录, 使用案例`
1. 脚本命名
    - `编号_数据库名_脚本功能`
    - 脚本数据库存在分库情况时, DBA会将其全库执行, 不需要开发处理
1. 存储过程命名：`架构名.模块名_功能语义`
2. 依赖条件命名时使用 `xxxBy+条件`
2. 最好有return信息. 没有的话可添加 `return 1`
5. 为什么必须有主键
　　- 主键不是必须的, 但是主键是必要的. 首先, 确保表的完整性（如数据的唯一性）当插入两行一模一样的数据时, 没有主键则不可区分. 其次, 提升效率（没有主键时, 是按照输入顺序进行插入的）
    - 有些数据库里主键时必须要有的. 
    - 如果没有业务列组合当主键, 可以生成自增id当主键
    - 业务列作为主键 / GUID主键 / 时间+机器号+自增ID主键
5. 业务逻辑是否封装到存储过程里
    - [在开发过程中为什么需要写存储过程](http://www.cnblogs.com/doudouxiaoye/p/5804467.html)
    - 是：执行速度快, 安全性（屏蔽开发人员权限）, 银行/电信等采用此种方案
    - 否：互联网企业一般采用此方案
        - 业务逻辑交给程序处理, 减少数据库资源消耗
        - 不利于分层规范和维护
        - 迁移方便（屏蔽具体sql的差异, 如sqlserver和mysql）

## ETC
1. [数据类型](/Program/Database/dataType.md)
    - 不同数据库类型有些许不同, 但是大体类似
