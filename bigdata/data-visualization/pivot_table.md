# 透视表
百科上, 透视表定义是 是用来汇总其它表的数据的表. 首先把源表分组(grouping), 然后对各组内数据做汇总操作如排序/平均/累加/计数或字符串连接等.

对于程序员, 更容易理解的是透视表是: 对于数据表df, 按照多列分组聚合的方式处理数据, 然后以矩阵的方式展示.

假设存在数据集如下
```Python
df = pd.DataFrame({"A": ["foo", "foo", "foo", "foo", "foo", "bar", "bar", "bar", "bar"],
  "B": ["one", "one", "one", "two", "two", "one", "one", "two", "two"],
  "C": ["small", "large", "large", "small", "small", "large", "small", "small", "large"],
  "D": [1, 2, 2, 3, 3, 4, 5, 6, 7],
  "E": [2, 4, 5, 5, 6, 6, 8, 9, 9]})
```

对 A/B/C 三列分组, 对D列求sum, 得出的透视表如下
````
# python 求透视表代码
table = pd.pivot_table(df, values='D', index=['A', 'B'], columns=['C'], aggfunc=np.sum, fill_value=0)

C        large  small
A   B
bar one      4      5
    two      7      6
foo one      4      1
    two      0      6
````

可以看到, 透视表数据是先按照 列A分组, 然后按照B/C分组, 对D求和. 类似与 `A,B,C,sum(D) ... group by A,B,C`,
