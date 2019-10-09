# binlog
mysql 通过 binlog 记录数据库的更改操作, 以实现主从数据的复制.

启用 binlog 后, mysql 会将所有的数据库更改操作记录到binlog日志中, 可用于备份和复制.
- binlog 在事务最终提交后才会记录到binlog日志中, 且只有更改操作, 不包含 select 等查询操作.

binlog 多被用于主从复制. master 节点通过 binlog 生成日志, 从节点通过binlog复制数据.

复写有两种模式
1. sbr(statement based replication): 基于语句. master节点将sql语句写入binlog. 从节点通过执行sql复制数据.
2. rbr(row based replication): 基于行. master节点将 event 写入binlog, event 即对表/行的更改. 从节点通过binlog复制数据.
3. mixed: 混合模式. 同时使用两种模式. mix 模式下. 默认使用 row-based, 在特点情况下 切换为 statement-based
4. 参考: [Replication Formats](https://dev.mysql.com/doc/refman/5.7/en/replication-formats.html)

详细参见
- [mysql5.7_binlog](https://dev.mysql.com/doc/refman/5.7/en/replication-options-binary-log.html#option_mysqld_log-bin)

## 使用
启用配置binlog: [配置文件示例](https://github.com/everywan/soft/setup/server/docker/mysql/conf.d/binlog.cnf)

binlog 生成的是二进制文件, 可以根据需要使用如下方式打开
1. `vim+xxd` 插件: vim 可以打开二进制文件, xxd 可以以16进制解析二进制文件(将数字变为ascii字符). 方法如下
  - 打开文件 `vim -b 0001`
  - 执行 `:%!xxd` 以16进制方式查看
  - 注: xxd: make a hexdump or do the reverse. linux 自带工具.
2. 使用 mysqlbinlog 程序: 
  - statement-based: `mysqlbinlog mysql-bin.000025` 即可
  - row-based: `mysqlbinlog mysql-bin.000025 -vv --base64-output=decode-rows`. row-based 必须加如上参数, 才能正确的解析出 event 的sql语句
3. 使用 sql 查询. 具体见下文中的 常用sql语句

需要注意的是, 对于 row-based 模式, 二进制/sql 均不能看到 insert/delete 语句, 必须通过 mysqlbinlog 转义并查看. (有可能有其他方法, 但是我没查到)

Q&A
1. 开启 binlog 后, 之前的修改记录会有么? 或者可以重新生成么?

## 常用sql
```SQL
-- 查看binlog状态
show variables like '%log_bin%'
-- 查看当前的binlog信息
SHOW MASTER LOGS
-- 查看某个 binlog 文件的事件
show binlog events IN 'binfile'
-- 刷新logs, 同时会生成一个新的 binfile
flush logs
-- 清空binlog日志
reset master
```
