<!-- TOC -->

- [总结](#总结)
    - [知识点](#知识点)
    - [算法示例](#算法示例)
        - [单向链表](#单向链表)
        - [与或非思想](#与或非思想)
            - [简洁的swap函数](#简洁的swap函数)
        - [移位思想](#移位思想)
            - [判断二进制数字中1的个数](#判断二进制数字中1的个数)
        - [其他](#其他)
            - [求列表的所有子集](#求列表的所有子集)
            - [获取字符串中倒数第二个匹配的值](#获取字符串中倒数第二个匹配的值)
            - [Fast Inverse Square Root](#fast-inverse-square-root)

<!-- /TOC -->

# 总结
## 知识点
1. 哈夫曼编码：完全依据字符出现概率来构造异字头的平均长度最短的码字, 有时称之为最佳编码, 一般就叫做Huffman编码（有时也称为霍夫曼编码）. 
2. 斐波那契数列：被以递归的方法定义: `F（0）=0, F（1）=1, F（n）=F(n-1)+F(n-2)（n≥2, n∈N*）`  
    - ![通项公式](/attach/Fibonacci_formula.png)
3. 位对齐编码：Elias Gamma算法利用分解函数将待压缩数字分解为两个因子, 分别用一元编码和二进制编码表达这两个因子. 
	- 分解函数：x=2^e+d
    - x为待压缩数字, e和d为其因子, 分解出因子后, 对因子e+1 采用一元编码表示, 对因子d采用宽度为e的二进制编码表示
4. 循环优化
    - 倒序循环：与0比较比与其他比较效率高
    - Duff's Device：每k次进行一次比较
5. 条件测试优化: 尽可能的只做有效的操作
    - 代码顺序按照概率大小顺序
        - 现代CPU在执行到`if`时, 不会先判断条件然后选择执行那个分支, 而是直接进入一个分支执行, 如果猜错则回滚
        - 所以, 如果使概率大的条件为`if`, 会提高效率
    - 二分法等

## 算法示例
### 单向链表
> 原理: https://zhuanlan.zhihu.com/p/33663488
### 与或非思想
#### 简洁的swap函数
````
# '^' 异或运算
x=x^y
y=x^y
x=x^y
# 解释
x1 = x^y
x2 = x1^y = x
x3 = x1^x2=x^y^x=y
````

### 移位思想
#### 判断二进制数字中1的个数
1. 使用系统自带的bin函数可以将数字转换为二进制类型, 然后移位
2. 使用 `z & (z-1)` 消去末位1.
    ````
    z = x ^ y
    if z == 0:
        return 0
    t = 1
    while z > 0:
        z = (z & (z-1))
        if z:
            t = (t + 1)
    ````

### 其他
#### 求列表的所有子集
1. 思想: 每个元素有在与不在子集内两种选择, 因此含n个元素的集合的子集数为 2^n. 用一个标记数组表示该元素在与不在, 然后再递归剩余元素.
2. `combination(arr=数组,p=起始点, q=数组长度+1,flags=标记数组)`
    - `q=数组长度+1` 是为了保证每个元素的 在/不在 两种状态都被计算
```Python
def combination(arr,p,q,flags):
    result = []
    if(p==q):
        i = 0
        for e in arr:
            if(flags[i]):
                result.append(arr[i])
            i = i+1
        print result
        return
    flags[p]=False
    combination(arr,p+1,q,flags)
    flags[p]=True
    combination(arr,p+1,q,flags)

arr = [1,2,3,4]
flags = [False]*4
combination(arr,0,4,flags)
```
#### 获取字符串中倒数第二个匹配的值
使用两次 `lastIndexOf` 即可
- 示例: ` String a=str.substring(str.lastIndexOf("\\",str.lastIndexOf("\\")-1)); `

#### Fast Inverse Square Root
1. 神奇数字0x5f3759df
```C++
float InvSqrt(float x)
{
    float xhalf = 0.5f*x;
    int i = *(int*)&x;       // get bits for floating value
    i = 0x5f3759df - (i>>1); // gives initial guess y0
    x = *(float*)&i;         // convert bits back to float
    x = x*(1.5f-xhalf*x*x);  // Newton step, repeating increases accuracy
    return x;
}
```