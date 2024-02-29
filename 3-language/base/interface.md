## 接口
接口, 在 Java 中是一个抽象类型, 用来统一类的共通特性, 描述类的行为和功能; 但接口不需要也不允许实现这些行为和功能
- 接口只能包含方法签名和常量声明, 不能包含方法实现
- 常量声明是指 final/static 常量.

接口可以理解为双方为了交流而做出的约定: 只要实现该接口, 就有该接口的方法和常量的定义和实现.

接口有以下特性
- 接口类型无法被实例化, 但是可以被实现: 一个实现接口的类, 必须实现接口的所有方法, 否则该类必须声明为抽象类.
- **接口类型无法被实例化, 但是接口可以使用接口声明一个空指针, 然后被绑定到实现该接口的类上**
- 接口无法实现其他的接口.

接口的优势
- [隐藏具体实现](#隐藏具体实现)
- 在 Java 中, 是不允许多继承的, 既一个类最多只能有一个父类, 但是可以使用接口模拟 '多继承'(一个类可以 implement(实现) 多个接口)
    - `java.lang.Object` 是例外, Object 是顶层类型, 没有父类.

### 隐藏具体实现
[参考: 深入理解 Go Interface](http://legendtkl.com/2017/06/12/understanding-golang-interface/#2.2)

隐藏具体实现: 比如函数返回一个 interface, 那么你只能通过 interface 里面的方法来做一些操作, 但是内部的具体实现是完全不知道的.

context 最先由 google 提供, 现在已经纳入了标准库, 而且在原有 context 的基础上增加了: cancelCtx, timerCtx, valueCtx. 如下代码, 表面上 WithCancel 函数返回的还是一个 Context interface, 但是这个 interface 的具体实现是 cancelCtx struct. 既隐式更改了context的具体实现.
```Go
func WithCancel(parent Context) (ctx Context, cancel CancelFunc) {
    c := newCancelCtx(parent)
    propagateCancel(parent, &c)
    return &c, func() { c.cancel(true, Canceled) }
}
``` 

### java/go 接口区别
- go 语言的 interface 只能有方法, 不能有常量, java 中的接口中可以有静态常量, 也可以定义变量
- go语言的接口是非侵入式的, 既接口实现者(struct)不需要显示implement接口

```Java
interface ITest{
    int a = 3; // 等效于 final int a = 3;
    void printa();
    static int b =3;
}

class Test implements ITest{
    public void printa(){
        System.out.println(this.a);
    }
}
```
