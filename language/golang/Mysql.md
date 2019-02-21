# Go-Mysql
> 示例代码参考 [GO-mysql示例](https://github.com/everywan/go-web/blob/master/dao/mysql_crud.go)   
> 参考: [golang sql连接池的实现解析](https://blog.csdn.net/pangudashu/article/details/54291558)

## database/sql
1. database/sql 定义了sql操作/连接池的接口, 有时间可以研究下, 接口设计很优秀
    - mysql 驱动的实现: github.com/go-sql-driver/mysql
2. `import _ "github.com/go-sql-driver/mysql"` 用于执行 init() 方法初始化
