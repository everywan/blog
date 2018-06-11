<!-- TOC -->

- [C++编程语言](#c编程语言)
    - [知识技能](#知识技能)
        - [delete](#delete)
        - [类型](#类型)

<!-- /TOC -->

# C++编程语言
> 推荐C++ Primer.很强的一本书, 可以反复学好几遍. 

## 知识技能
1. break：跳出当前最近的循环
1. auto类型
    - auto 让编译器通过初始值来推算变量类型. 而内置类型和组合类型的对象的值是未初始化的, 所以不能使用auto
    - 忽略顶层类型const. 当 `const auto f = ci` , 时, 类型才为const型
    - `Auto &g =ci, const auto &g = 42`, 引用必须绑定值. 常量引用必须赋值
    - 底层 顶层 变量 = 值
1. 初始化
    - `int pi=*pia;`隐式初始化（explicit函数抑制隐式转换）
        - `*`：解引用操作符
    - const值必须进行初始化
    - `int *pia=new int;` 未初始化. int没有默认的构造函数
    - `string *pia=new string;` 初始化为空, String 是引用类型
    - `int *pia=new int(n,0);` 初始化为n个0 **好像不对啊**
    - `int *pia=new int{1,2,2,3}; `初始化为{}列表的元素值  **好像不对啊**
1. typedef: 定义别名
1. `Decltype (f()) sum = x` , sum 类型为f()返回的类型
2. `system()`函数: 执行 win/linux 系统命令
2. `a.size()`：`.` 表示访问成员, `()` 表示被调用
2. `int main(int argc, char *argv[]){}`
    - argc： 表示数据中字符串的数量
    - argv： 数组, 元素指向C风格字符串的指针
    - 举例
        - `prog -d -o ofile data0` ; prog 为可执行文件（必须包含main函数）
        - `argc=5, argv[0]="prog", [1]="-d", … [4]="data0", [5]=0;`
2. initializer_list 形参：传递可变数量的实参. （全部实参类型应相同）, 适用于无法提前预知应向函数传递几个参数
    - 例如error_msg函数: `void error_msg(ErrCode e, initializer_list<string> il) {};`
    - initalizer_list 类似 vector；含有begin(), end, size 成员
    - `lst2(lst);  lst2=lst;` 拷贝或复制 initalizer_list 对象, 
3. 尾置返回类型：`auto func(int i) -> int (*) [10] {}`
4. 不能拷贝或对 IO 对象赋值

### delete
- delete 只负责释放指针指向的那块内存, 而不对指针本身的值(存的地址)做任何修改. delete 后的指针叫dangling pointer, 不是野指针, 是空悬指针, 相对于野指针, 它属于家养的, 至少你知道它曾经指向哪. 
- 如果delete之后你不再打算使用这个指针变量, 那随他去吧, 让作用域结束它就可以了. 
- 如果你想继续使用该指针, 那就置为null

### 类型
1. unsigned：无符号类型