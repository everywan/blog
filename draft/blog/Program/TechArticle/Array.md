# Array
> 非特殊声明情况下, 以JAVA为准
> 
> 参考 [Java 数组在内存中的结构](https://blog.csdn.net/renfufei/article/details/15503469)

## 数组-内存结构
1. 一维数组
    - 在内存中开辟指定大小的内存(所以数组创建需要指定大小), 通常返回该内存地址的起始位置作为数组的引用.
    - 图解: ![一维数组](/attach/OneDimenArray.jpg)
    - 例外: Go语言中, 数组是值引用, 切片才是引用类型
2. 二维数组
    - 二维数组 底层也是一维数组, 只是 二维数组的每一个元素都指向了另一个一维数组.
    - 图解: ![二维数组](/attach/TwoDimenArray.jpg)

## 数组-内存位置
1. 同其他引用类型一样, 数组的引用值存在栈中, 数组的值存在堆中
    - 参考 [内存分配](/Program/TechArticle/memory_allocation.md)
    - 图解: ![内存分配](/attach/MemoAlloc.jpg)
