# Pandas
官方API文档 [API DOC](https://pandas.pydata.org/pandas-docs/stable/reference/index.html)

Pandas 的核心类是 DataFrame 和 Series.

## 术语
- scalar: 标量, 即常量

## 基本使用
### 创建数据
pandas 直接使用相关类的构造函数创建. pyspark 使用函数创建 DataFrame

Series
- 构造函数: `pandas.Series(data=None, index=None, dtype=None, name=None, copy=False, fastpath=False)`
  - data: array-like, Iterable, dict, or scalar value

Index 索引
- 时间索引: `date_range()`, 按照时间生成序列.
  - 签名: `date_range(start=None, end=None, periods=None, freq=None, tz=None, normalize=False, name=None, closed=None, **kwargs)`
    - start/end 开始/结束时间
    - periods 要生成的时间长度
    - freq 时间单位. D天 S秒 H小时 等等. 参考 [Date Offset aliases](https://pandas.pydata.org/pandas-docs/stable/user_guide/timeseries.html#timeseries-offset-aliases)

DataFrame
- 构造函数: `DataFrame(data=None, index=None, columns=None, dtype=None, copy=False)`
  - data: ndarray (structured or homogeneous), Iterable, dict, or DataFrame
  - 创建 a b c 三列, `pd.DataFrame({'a':[1,2,3], 'b':[1,2,3], 'c':[1,2,3]})`
  - 通过 numpy 创建: `df = pd.DataFrame(np.arange(16).reshape((4,4)),index=["a","b","c","d"],columns=["a","b","c","d"])`
- 从文件中读取
  - 从 csv 读取: `pd.read_csv(path,sep=',')`. [API](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.read_csv.html#pandas.read_csv)

### 处理
- `df.apply()`, 对轴上的每个数据进行自定义处理
  - 签名: `df.apply(self, func, axis=0, broadcast=None, raw=False, reduce=None, result_type=None, args=(), **kwds)`
    - func: apply to each column or row. 处理 指定轴的每一行数据. 
    - axis: index(0) or column(1), default 0
  - 示例:
    ```Python
    df = pd.DataFrame([[4, 9]] * 3, columns=['A', 'B'])`
       A  B
    0  4  9
    1  4  9
    2  4  9
    # 对每一列进行 sum, 使用脚标取值
    def sum(nums):
      result = 0
      for num in nums:
        result+=num
      return result
    df.apply(sum)
    A    12
    B    27

    # 对每一列的每个值+1, 返回也是 row, 所以有两行
    df.apply(lambda x: x+1)
       A   B
    0  5  10
    1  5  10
    2  5  10
    ```
- `df.applymap()`, 对 dataframe 的每个元素进行处理. 与 apply 不同的是, applymap 每次传入函数的是每个元素, apply 每次传入函数的是每行数据.
  - 签名: `df.applymap(self, func)`
- `df.shift()`, dataframe 移位操作
  - 签名: `df.shift(self, periods=1, freq=None, axis=0, fill_value=None)`
    - periods: 移位位数.
    - axis: 移位方向. 惯例, index(0) or column(1)
    - freq: 当行索引为时间序列时使用, freq 决定时间索引 移位的频率, `freq*periods` 决定时间索引的偏移值

### 筛选行/列
行筛选方法如下
- `df.loc[]` : 按照 key 值筛选, 即 location, 可以使用掩码形式, 如"2014-06"可以代表六月所有行(需要该列为date类型). 示例如下
  - `df.loc['20130101',..]` 只选 `key==20130101` 的行(一行)
  - `df.loc['20130101':'20130102',..]` 选则 `20130101<= key <=20130102` 的行, 包括两端
  - `df.loc[:,..]` 选择全部行
- `df.iloc[]`: 按照 索引 值筛选. iloc 即 index location
  - `df.iloc[0,..]` 与正常的切片方式相同, 选择 `index==0` 行
  - `df.iloc[0:1,..]` 与正常的切片方式相同, 选择 `[0,1)`. (左闭右开)
  - `df.iloc[[0,1,3],..]` 选择 index 为 0,1,3 的行
- 布尔值筛选, 对每一列筛选
  - `df[df.A > 0]` 选择列A 值大于0的行
  - `df[df>0]=-df` 将df中所有值大于0的元素取负
    - `-df` 全部值取负.
  - `df[df['A'].isin(['two','four'])]` 列A值为 two 或 four 的行
- 其他
  - `pd.isna(df)`: 返回df是否有值的 布尔掩码

列筛选与行筛选类似, 只是使用 loc 的第二个参数. 如 `df.iloc[0:1, 1:2]`: 0:1 表示筛选的行, 1:2 表示取的列. 其他不再详述

pyspark 中取行列与pandas不同, pyspark 主要用sql方式取. 示例如下
- 注册临时表, 执行sql. `df.registerTempTable('tmp_df')`, 而后执行相应sql `df2=spark.sql('sql')` 即可
- 使用pyspark api: `df.select('field1', 'field2').orderBy(df.field3.asc).limit()`
- 导出dataframe然后处理. 如 `df.toPandas()`

### 填充值
- `df.fillna()`, 填充所有缺失的数据, 可以指定值, 或者使用周围值
  - 签名: `df.fillna(self, value=None, method=None, axis=None, inplace=False, limit=None, downcast=None, **kwargs`
    - value: scalar, dict, Series, or DataFrame
    - method: default None. ffill/bfill: 根据指定的 axis, 将缺失值的前/后一个数据填入. 如 axis=index, 则是按列, 取列的 前/后 一个值.
    - inplace: 是否原地替换. default False. 原地替换是指在原 df 操作.
  - 示例: `df.fillna({"attacker_size":1.0,"defender_size":1.0}, inplace=True)`
- `df.dropna()`, 删除有缺失值的数据
  - 签名: `df.dropna(self, axis=0, how='any', thresh=None, subset=None, inplace=False)`
    - how: any: 只要有缺失值, 就删除 该行/该列(由axis决定). all: 只有所有元素都是缺失值, 才删除该行/该列.
    - thresh: 当有 thresh 个缺失值时, 删除该行/该列
    - subset: 只判断 subset 指定的 行/列
  - 示例: `df.dropna(subset=['name', 'born', 'sex'], thresh=2)` 当 subset 中最少有两列为 NaN, 则删除该行.

### 转换
- `to_datetime()` 将列转换为时间类型: `pd.to_datetime(arg,unit=ns,errors=raise,format='%d/%m/%Y')`, 可以将 时间tuple, int/float/string 等值, list|Series 等转换为时间类型
  - [API](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.to_datetime.html)
  - 转换时间戳: `pd.to_datetime(12312)`, 默认单位 纳秒
  - 转换索引: `pd.to_datetime(df.index)`. 如原来的index: [0,1,2,..], 转换过后index: ['1970-01-01','1970-01-02',...]
  - 转换多列组合: `df=pd.DataFrame({'year': [2015, 2016],'month': [2, 3],'day': [4, 5]}),  pd.to_datetime(df)` 会将每行的值转换为 datetime 类型
- 两个Series运算, 只要有一个相应位置为NaN则结果为NaN

#### 索引
- 将索引转换转换为时间格式: `df.index = pd.to_datetime(df.index)`
- `df.reindex(new_index)`, 重建索引, 传入 array-like 的数据即可
  - new_index 有如下定义方式
    - 自定义数组 `index = ['c1','c2','c3']`
    - 时间索引 `date_index = pd.date_range('1/1/2010', periods=6, freq='D')`

### 绘图
- `pd.DataFrame.plot()`: 使用 matplotlib/pylab 绘制图像.
  - plot 与 df 的映射规则(坐标轴) 默认索引为x轴

### ipython
- `%timeit func()`: 测算函数的运行时间
  - 单元格前加 `%%timeit`: 测算整个单元格的运行时间
- `%matplotlib inline`: 将matplotlib设置为交互方式工作
- `%config InlineBackend.figure_format = 'retina'`: 设置 matplotlib 以呈现高分辨率图像

## 进阶
### 重建数据
- 对于时间索引, 重新对dataframe采样
  - 签名: `resample(self, rule, how=None, axis=0, fill_method=None, closed=None, label=None, convention='start', kind=None, loffset=None, limit=None, base=0, on=None, level=None)`
  - [API DOC](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.resample.html#pandas.DataFrame.resample)

### 数据可视化
- 透视表, pivot table [介绍与定义](/bigdata/data-visualization/pivot_table.md)
  - 签名: `pivot_table(data, values=None, index=None, columns=None, aggfunc='mean', fill_value=None, margins=False, dropna=True, margins_name='All', observed=False)`
    - data: dataframe
    - aggfunc: 聚合函数, 如 np.sum/np.mean 等
  - 示例: `pd.pivot_table(df, values='D', index=['A', 'B'], columns=['C'])`, 以df为数据源, 以 A/B 为行(y轴,index,会自动展开), 以C为列, 以 D 中元素为值.
  - [API DOC](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.pivot_table.html#pandas.pivot_table)

## 例子
1. 查询df每一列有多少缺失值.
