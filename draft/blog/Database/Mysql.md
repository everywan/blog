<!-- TOC -->

- [Mysql](#mysql)
    - [docker-mysql](#docker-mysql)
    - [修改密码](#修改密码)
    - [通用查询](#通用查询)
        - [查询各分组前N个值](#查询各分组前n个值)
    - [空间查询](#空间查询)
        - [空间查询_数据格式](#空间查询_数据格式)
        - [空间查询_数据插入](#空间查询_数据插入)
        - [空间查询_创建索引](#空间查询_创建索引)
        - [空间查询_使用方法](#空间查询_使用方法)
        - [空间查询_注意](#空间查询_注意)

<!-- /TOC -->

# Mysql

- [传统SQL数据库](/Database/SQL.md)
- [常用SQL语句](/Database/SQL.sql)

## docker-mysql
1. 拉取镜像: `docker pull mysql:5.7`
2. 创建容器: `docker run --name mysql -p 3306:3306 -v $PWD/config:/etc/mysql/conf.d -v $PWD/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=*** -d mysql:5.7`
    - 映射外网IP: `-p 3306:3306`
    - 挂载配置文件: `-v $PWD/config:/etc/mysql/conf.d`
    - 挂载数据: `-v $PWD/data:/var/lib/mysql`
    - 设置密码: `-e MYSQL_ROOT_PASSWORD=***`
3. 链接数据库: 需要在一台有mysql-client的服务器上链接. 无法直接进入容器
    - 示例: `mysql -h 192.168.1.2 -uroot -p***`

## 修改密码
```bash
# 关闭数据库
service mysqld stop
# 修改配置文件, 在添加 mysqld 节点下添加: `skip-grant-tables`
# 命令+参数 配置运行时, 有些情况下不生效
vim /etc/my.cnf
service mysqld start
# 进入数据库
mysql
# 更改密码
>mysql update user set password=password("root") where user="root";
```

## 通用查询
### 查询各分组前N个值
> 参考: http://blog.51cto.com/huanghualiang/1252630

1. `select * from t2 a where exists(select count(*) from t2 b where b.gid=a.gid and a.col2<b.col2 having(count(*))<3) order by a.gid,a.col2 desc;`
    - having: having是用来筛选的, 与where类似. 但是where不可用于聚合函数(即 count() 等), 原因为: 
    - exists: 判断查询是否返回了结果集. exists不关注返回内容, 只关注是否返回结果.
2. having 详解: 之所以有having, 是因为 WHERE 关键字无法与统计函数(即聚合/分组函数)一起使用
    - `where, 查询 having, group by` 执行顺序: `where -> 返回查询结果 -> 聚合函数/group by -> having`
    - where 作用于对查询结果返回之前, 将不符合where条件的行过滤. 所以where中不能包含聚合函数.
    - having 作用于 聚合/分组 之后, 所以having可以筛选 聚合/分组 后的数据.

## 空间查询
### 空间查询_数据格式
1. `Point`: 点
    - 示例: `Point(116 40)`
2. `MultiPoint`: 点集合
    - 示例: `MultiPoint(116 40,116 41,117 41)`
3. `LineString`: 线
    - 示例: `LineString(116 40,116 41,117 41)`
4. `MultiLineString`: 线集合, 不区分方向
    - 示例: `MultiLineString((116 40,116 41,117 41),(117 41,116 41,116 40))`
5. `Polygon`: 面, 首位点必须重合
    - 示例: `Polygon((116 40,116 41,117 41,117 40,116 40))`
6. `MultiPolygon`: 面集合
    - 示例: `MultiPolygon((116 40,116 41,117 41,117 40,116 40),(116 40,116 41,117 41,117 40,116 40))`
### 空间查询_数据插入
1. 使用`ST_GeomFromText('gis_type_format')` 将文本转换为空间数据的格式
    - `GeomFromText()` 方法也可以做到, 区别再议
2. 示例
    ```SQL
    -- 模板
    INSERT into table(field) VALUES(ST_GeomFromText('gis_type_format'))
    -- 示例 插入一个点
    INSERT into test(point) VALUES(ST_GeomFromText('Point(5 5)'))
    ```
### 空间查询_创建索引
> 参考: [官方文档](https://dev.mysql.com/doc/refman/5.7/en/creating-spatial-indexes.html)
### 空间查询_使用方法
1. 包含
    - A包含B: `MBRContains(A,B)`
    - A在B中: `MBRWithin(A,B)`
2. 覆盖
    - A被B覆盖: `MBRCoveredBy(A,B)`
    - A覆盖B: `MBRCovered(A,B)`
3. 相交
    - A B不相交: `MBRDisjoint(A,B)`
    - A B相交: `MBRIntersects(A,B)`
4. A B接触(相切): `MBRTouches(A,B)`
5. A B重叠: `MBROverlaps(A,B)`
6. A B相同: `MBREquals(A,B)`
7. 以文本形式返回: `ST_AsText(field)`
8. 以二进制形式返回: `ST_AsBinary(field)`
9. 获取点的x/y: `ST_X(field)/ST_Y(field)`
10. 示例
    ```SQL
    select * from test where MBRContains(ST_GeomFromText('Polygon((0 0,0 5,5 5,5 0,0 0))'),point)
    SELECT ST_X(point) FROM test
    ```
### 空间查询_注意
1. 在mysql5.7.6之后，不带MBR的方法将逐渐被去除
