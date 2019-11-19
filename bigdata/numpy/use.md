# numpy
官方文档: [API DOC](https://www.numpy.org.cn/user/setting-up.html)

numpy 的核心是 ndarray 对象(同构多维数组)

## 基础使用
- ndarray 数组上的算术运算符会应用到 元素 级别. ndarray 相乘也不是矩阵乘法, 而是对应元素相乘. 矩阵乘法使用 `@` 或 `dot()` 实现.

### 新建
ndarray 每次扩建都是新建数组然后删除原数组(c, 扩建需要重新申请内存)

## 术语
- 同构/异构: 同构指数组内元素都是统一构造函数生成.
