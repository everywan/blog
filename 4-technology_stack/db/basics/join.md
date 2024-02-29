# join
此处主要讲 spark sql 下的全链接. 参考: [Spark SQL 之 Join 实现](https://www.cnblogs.com/suanec/p/7560399.html)

## full-join
假设 `table_a full join table_b on a.key=b.key`, joinRow 为此次插入到新表中的列

- 当 a.key 在 b 中找到相符合的键且只有一个时, 将这两行合并, 插入到新表中. `joinRow = a.columns,b.columns`
- 当 a.key 在 b 中找到相符合的键且不止一个时, 将所有符合条件的排列都插入到新表中. `joinRow = [a.columns, ...b.columns]`. (未验证, 大概是这个样子)
- 当 a.key 在 b 中未找到符合的键时, `joinRow = a.columns,null`. 同理, 当 b.key 在 a 中未找到符合的键时, `joinRow = null,b.columns`
