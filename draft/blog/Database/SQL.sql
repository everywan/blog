-- SQL 使用指南(以MYSQL为准)

-- -------------------命令行操作mysql样例----------------------

-- 链接Mysql
-- mysql -h 127.0.0.1 --user root -pwzsPasswd --database test

-- 帮助  \h

-- 显示表的 字段+注释
show full columns from kh_user_info;

-- 显示test库的所有表的字段和所有字段介绍
SELECT t.TABLE_NAME,t.TABLE_COMMENT FROM information_schema.TABLES t,INFORMATION_SCHEMA.Columns c WHERE c.TABLE_NAME=t.TABLE_NAME AND t.`TABLE_SCHEMA`='test'

-- 显示所有表的介绍
SELECT t.TABLE_NAME,t.TABLE_COMMENT FROM information_schema.TABLES t WHERE t.`TABLE_SCHEMA`='test';

-- 修改字段注释
UPDATE COLUMNS t  SET t.column_comment  = '证件编号'  WHERE t.TABLE_SCHEMA='zebra' AND t.table_name='kh_user_info'  AND t.COLUMN_NAME='idCardNum'; 

-- 修改密码
grant all on xxx.* to 'root'@'%' identified by 'password' with grant option; 

-- 创建用户, host: 指定该用户在哪个主机上可以登陆. % 表示任意远程主机
CREATE USER 'username'@'host' IDENTIFIED BY 'passwd';

-- 授权, privileges: 用户的操作权限,如 all,select; 如SELECT,INSERT,UPDATE. all标示所有权限
GRANT privileges ON databasename.tablename TO 'username'@'host'

-- 创建表
create table if not exists order(
    `id` varchar(50) NOT NULL,
    orderNum varchar(50) NOT NULL COMMENT '订单编号',
    assetId varchar(50) NOT NULL COMMENT '资产ID',
    price DECIMAL(10,4) NOT NULL COMMENT '资产价格',
    orderStatu TINYINT NOT NULL COMMENT '订单状态, 0:无效订单, 1:未支付订单, 2:已支付订单',
    createdAt datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updatedAt datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
    createBy varchar(50) NOT NULL COMMENT '创建用户',
    updateBy varchar(50) COMMENT '更新用户',
    PRIMARY KEY (`orderNum`),
    CONSTRAINT `FK_FK_msgType` FOREIGN KEY (`assetId`) REFERENCES `asset` (`id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='订单表';

-- 存储过程
-- 参考: https://www.cnblogs.com/pengzijun/p/6929949.html
-- 创建存储过程: 添加事务: 处理事务时,使用SQLException捕获SQL错误,然后判断是回滚(ROLLBACK)还是提交(COMMIT)
DROP PROCEDURE IF EXISTS  select_students_by_name  
CREATE PROCEDURE `select_students_by_name`(
   in _name varchar(225),   -- 输入参数
   out _city varchar(225),  -- 输出参数
   inout _age int(11)       -- 输入输出参数
)
BEGIN
    DECLARE t_error INTEGER DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;
    
    START TRANSACTION;
    INSERT INTO students VALUES(...);

    IF t_error = 1 THEN
            ROLLBACK;
        ELSE
            COMMIT;
        END IF;
    -- into _city: 将数据插入到变量
   SELECT city from students where name = _name and age = _age into _city;
END;

-- 执行存储过程
set @_age = 20;
set @_name = 'jack';
call select_students_by_name(@_name, @_city, @_age);
select @_city as city, @_age as age;

-- mysql 备份与恢复
mysqldump -h 192.168.1.2 -uroot -ptest  test > /data/test_db.sql -- 备份
mysqldump -h 192.168.1.2 -uroot -ptest  test < /data/test_db.sql -- 恢复

-- SQL SERVER 计算时间差. DIFF(): 计算两个时间的时间差, 第一个参数标示在日期的那一部分计算(year,quarter,month,dayofyear,week,hour,minute,second,mllisecond)
select DIFF(day,createTime,lastTime) from test

-- 修改sql_mode(mysql version>5.7)
set sql_mode=(select replace(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
select @@sql_mode

-- 多列合并成一列
select concat(lon,",",lat) as lonlat from pos

-- 事件 定时策略
    -- 查看/修改 定时策略是否开启
    show variables like '%event_sche%';
    set global event_scheduler=1;
    -- 创建定时任务
    DROP EVENT IF EXISTS day_event; 
    create event day_event
    on schedule every 1 day starts timestamp(current_date,'00:00:00')
    on completion preserve disable      -- 创建后并不开始生效. enable 立即生效
    do call test_proce();               -- do: 该事件的执行内容
    -- 查看 事件
    SELECT event_name,event_definition,interval_value,interval_field,status FROM information_schema.EVENTS;
    -- 修改 事件
    alter event day_event on completion preserve enable;

-- 联查 tb1 tb2, 组合显示结果.(笛卡尔乘积形式,即 tb1的每行都会和tb2的每行联合显示一次)
select tb1.*, tb2.* from tb2,tb1;

-- mysql 查询结果添加序号: 
-- 思路: 事先定义一个变量, 通过变量的递加以及虚拟表的联查生成序列号
-- `(select @i:=0) as se` 用于给 @i 赋值
select (@i:=@i+1) as 序号, todos.* from todos, (select @i:=0) as se;