# 闭包
> 参考 [作用域链](http://www.cnblogs.com/dolphinX/p/3280876.html), 
> [闭包](http://kb.cnblogs.com/page/110782/)

<!-- TOC -->

- [闭包](#闭包)
    - [作用域链](#作用域链)
    - [闭包](#闭包-1)
    - [ETC](#etc)

<!-- /TOC -->

## 作用域链
- 在JS中, `function` 也是一种object的实例
- **作用域链**：用于标识符解析, 确定数据的存储位置以及数据作用域（数据访问）
- 函数执行时会创建“运行期上下文”的内部对象, 当函数执行完毕后被销毁（与闭包性能有关）
- C++等应该不存在这类问题
    - 因为：1, C++函数内不能定义函数（除了lambda外）
    - 因为：2, 函数调用则会在调用完后局部变量自动释放
    - 试下 **函数指针** 可不可以解决返回类型的问题从而可以使用闭包
- `scope chain` 代表引用链, 使用的function对象中内置的scope属性, 
- `scope chain` 采用倒排索引, 局部靠前, 且数据访问从索引链中依次访问（性能提升点！！）
- 所以, 局部变量会覆盖全局变量/外层变量, 由此可知原因. 
- 类比编译原理, 在汇编语言中, 子函数要访问外层变量, 使用的. . 方法也与此思想相似, 
- 猜测：数据的存储与访问是编程语言的共同问题, 而作用域链是解决这种问题的一种思想. 而且, 这也验证了一件事：程序逻辑和数据管理真的是编程语言的精髓！

## 闭包
- **概念**：要执行的代码块（包含自由变量） + 为自由变量提供绑定的计算环境（作用域）. 
- **表现**：function parent(){ var a; function child(){return ++a;} }
- 其实闭包就是调用function对象的funtion属性（只是这属性也是对象而已）的一种特殊情况
- 通常情况：如果 child不需要访问外层变量, 则函数执行完毕后被销毁（作用域结束）
- 特殊情况（闭包）：如果child需要访问外层变量, 则外层函数执行完后, 由于child函数对其存在引用, 外层函数激活对象无法被销毁, 导致内存开销增增加, 而且外层变量的引用在scope chain中的位置也会影响数据访问的性能. 
- 闭包有各种问题, 但是某些情况下, 闭包还是很有用的. 
    - 举例：时间加减
    ````
    function plusAny(senior) {
        return function(second) {
            return senior + second;
        }
    }

    var senior = 2838240000;
    var longLiveSeniorFunc = plusAny(senior);

    longLiveSeniorFunc(1);     // +1s
    longLiveSeniorFunc(3600);  // +1h
    longLiveSeniorFunc(86400); // +1d
    ````

## ETC
- C++闭包需要学习下函数指针, 否则无法直接返回函数
    - [函数指针](http://www.cnblogs.com/TenosDoIt/p/3164081.html)
    - [返回类型为函数指针](http://www.cnblogs.com/richard-g/p/3643337.html)
