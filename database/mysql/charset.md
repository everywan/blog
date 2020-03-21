# 字符集和字符序
学习mysql的字符集和字符序之前, 我们先简单回顾下字符集相关知识

> 字符集是一个文字系统所支持的所有抽象字符的集合.
> 编码集是将字符集转换为计算机可接受的形式的信息

具体参考 [字符集与编码集](/skill/encode/encode_1.md)

mysql 中的 charset 其实是编码集的意思, 规定了数据和元数据是 如何存储,如何传输和如何输出.
总之, mysql中关于字符存储的方方面面都与编码集有关,

而字符序是指mysql是按照指定的规则给字符排序. 如按字符的编码值, 或者其他规则.

为方便叙述和理解, 以下简称 mysql 中的 charset 为字符集.

如下按照四部分进行介绍
1. mysql中常用的字符集
2. 字符集相关知识: mysql中都有那些字符集设置, 如何生效, 以及需要注意什么.
3. 字符序相关知识
4. 使用示例

## 常用字符集
如下介绍一些mysql常用的字符集

### utf8/utf8mb4
mysql默认的utf8最多支持3字节内容的字符, 并且只包含 基本多语言面
(Base Multilingual Plane, BMP) 字符.

mysql5.5.3后, mysql引入了 utf8mb4 字符集, 最多支持4字节内容的插入.

对于BMP字符, utf8和utf8mb4具有相同的存储特性: 相同的代码值, 相同的编码, 相同的长度.

很多 emoji 都是采用4字节保存的, 所以需要使用 utf8mb4 字符集保存.

## 字符集
mysql 通过设置mysql的环境变量改变字符集的默认设置, 通过显式设置列/表的字符集更改列/表
的字符集. 当不设置时, mysql默认采用上一级的配置(默认顺序: 列/表/库/server)

具体设置方式参考 [使用示例](#使用示例)

与字符集相关的环境变量如下

客户端相关的字符集
- `character_set_client` 当前客户端使用的字符集.
- `character_set_connection` 当前连接使用的字符集
- `character_set_results` 用于将查询结果返回给客户端的字符集. 包括结果数据(如列值),
  结果元数据(如列名)和错误消息

服务端相关的字符集
- `character_set_database` 当前数据库默认使用的字符集和排序方式
- `character_set_filesystem` 文件系统字符集, 用于解释引用文件名的字符串文字.
  - 如当使用 `LOAD data` 或 `select ... into outfile` 等语句/函数时, 在打开文件之前,
    将文件名从 `character_set_client` 字符集转换为 `character_set_filesystem`.
  - 默认值 binary, 表示不做更改
- `character_set_server` 服务器默认字符集
- `character_set_system` 服务器用于存储标识符的字符集. 该值始终是 utf8
- `character_sets_dir` 字符集的安装目录

参考 [mysql 服务器系统变量](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html)

### 注意点
尽量使用合适的字符集, 以减少mysql占用的空间.

在mysql中, mysql会为列保留最长字节数的空间.
如mysql会为使用utf8的列保留3字节的空间, 因为最大字节是3字节, 如mysql会为 `varchar(10)`,
则mysql会保留30字节的空间.

如果没有预留足够空间, 如只有20字节, 当后续更改导致字节数超过20时, 就需要整体迁移数据,
以存储新数据. 但是, mysql 存储是磁盘操作, 且迁移操作损耗太大, 所以需要预留空间.
这也是 mysql 的 utf8 只支持BMP字符的原因, 减少空间占用, 使用较小的成本支持更多常见的场景.

## 字符序
字符序是mysql对字符的排序/比较规则, 一般每种字符集对应多种字符序.

字符序命名一般分为三段, 如 utf8mb4_unicode_ci
1. 地一段 utf8mb4 表示字符集
2. 第二段 unicode 表示语言, 其他还有chinese/swedish/general等
3. 第三段 ci 表示是否敏感, 见后续介绍

第三段常用值如下
- `_ai` Accent insensitive 音调不敏感
- `_as` Accent sensitive 音调敏感
- `_ci` Case insensitive 大小写不敏感
- `_cs` case-sensitive 大小写敏感
- `_bin` Binary 二进制排序

Accent sensitive 音调敏感, 当sensitive, 比较时 `a!=á`; 当 insensitive, 比较时 `a==á`.
Case insensitive 大小写不敏感, case-sensitive为大小写敏感.

## 使用示例
链接字符串中设置字符集
`root:root@tcp(localhost:3306)/test?timeout=3s&charset=utf8mb4,utf8&parseTime=True&loc=Local`

如下只介绍了临时更改系统字符集/字符序的方法, 通过配置文件修改的方法后续用到再加.

查看以及设置字符集/字符序
```SQL
-- 检查当前mysql的字符集环境变量
show variables like 'char%';
-- 查看单个
SELECT @@character_set_database, @@collation_database;
-- 或者 通过information_schema 查询数据库的字符集/字符序
SELECT SCHEMA_NAME, DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME
  FROM information_schema.SCHEMATA WHERE schema_name="test_schema";

-- 设置mysql字符集变量. 假设使用字符集 utf8mb4.
SET NAMES 'utf8mb4' COLLATE 'utf8mb4';
-- 等效于
SET CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4';
-- 等效于
SET character_set_client = 'utf8mb4';
SET character_set_results = 'utf8mb4';
SET collation_connection = @@collation_database;
```

建表/修改表SQL
```SQL
-- 语法
CREATE TABLE tbl_name (column_list)
    [[DEFAULT] CHARACTER SET charset_name]
    [COLLATE collation_name]]

ALTER TABLE tbl_name
    [[DEFAULT] CHARACTER SET charset_name]
    [COLLATE collation_name]

col_name {CHAR | VARCHAR | TEXT} (col_length)
    [CHARACTER SET charset_name]
    [COLLATE collation_name]
-- 示例
CREATE TABLE `demo` (
  ...
  -- 设置列的字符集
  `name` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'name',
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4; -- 设置表的字符集, 不推荐

ALTER TABLE `demo` ADD COLUMN char_column VARCHAR(25) CHARACTER SET utf8;
```

查看系统支持的字符集/字符序
```SQL
-- 查看mysql支持的字符集
SHOW CHARACTER SET;
-- 等效于
use information_schema;
select * from CHARACTER_SETS;

-- 查看字符序
SHOW collation;
-- 查看支持utf8的字符序
SHOW COLLATION WHERE Charset = 'utf8';
-- 等效于
USE information_schema;
SELECT * FROM COLLATIONS WHERE CHARACTER_SET_NAME="utf8";
```
