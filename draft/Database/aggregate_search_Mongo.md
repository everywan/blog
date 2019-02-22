# Mongo 聚合查询

<!-- TOC -->

- [Mongo 聚合查询](#mongo-聚合查询)
    - [样例&格式](#样例格式)
    - [用法](#用法)
        - [操作符](#操作符)
        - [管道命令](#管道命令)

<!-- /TOC -->

## 样例&格式
````
db.coll.aggregate([
    {
        $group : 
        {
            _id : "$city",
            sum_o3 : 
            {
                $sum : "$o3"
            } 
        }
    }
])
````
格式
````
db.coll.aggregate([
    // pipe_A, 输入是查询所在集合
    {
        $pipe_CMD: 
        {
            // _id: pipe_A 输出集合的id
            // "row_a": 输入集合 row_a列 作为 _id列 的值
            _id : "row_a",

            // pipe_A_row: 输出集合中的自定义列
            // {表达式}: 运算的结果作为 pipe_row_A列 的值
            pipe_row_A: 
            {
                // $operator:  $sum/max/last/push 等运算
                // "$row_b": 表达式的输入
                $operator: "$row_b"
            }
        }
    },
    // pipe_B, 输入为pipe_A输出的集合
    {
        $pipe_CMD: {}
    }
])
````

## 用法
### 操作符 
- `$sum, $avg, $min, $max, $first, $last`
    - `$sum`: 可以将 "$field" 改为权重, 此时默认列为 _id 列
- `$push`: 查询输入中的article列, 作为结果显示在 articles 列
- `$addToSet`: 查询输入中的article列, 然后push到set结构中(会去重), 然后作为结果显示在 articles 列

### 管道命令
````
db.coll.aggregate([
    {
        $match : { place : { $regex:"各乡镇|所有街道" } }
    },
    {
        $group: {_id: "$place", sum: { $sum: 1 } }
    },
    {
        $match : { sum : { $gt:0 } }
    }
])
````
- `$match, $limit, $skip, $group, $sort`
    ````
    # 跳过前五条记录开始处理
    db.coll.aggregate({ $skip : 5 });
    ````
- `$project`: 修改输入文档的结构
    ````
    // 修改结果为只有_id, tilte和author三个字段
    // _id:1 是任意一个查询的默认值
    db.coll.aggregate({ 
        $project : 
        {
            title : 1 ,
            author : 1
        }
    });
    ````
- 用到再看的两个
    - `$unwind`: 将文档中的某一个数组类型字段拆分成多条, 每条包含数组中的一个值
    - `$geoNear`: 输出接近某一地理位置的有序文档
