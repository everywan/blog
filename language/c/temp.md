一个比较经典的问题——问以下两种声明的区别：
1)  const char * p
2)  char * const p

 

这里的 const 关键字是用于修饰常量，书上说 const 将修饰离它最近的对象，所以，以上两种声明的意思分别应该是：
1)  p 是一个指向常量字符的指针，不变的是 char 的值，即该字符的值在定义时初始化后就不能再改变。
2)  p 是一个指向字符的常量指针，不变的是 p 的值，即该指针不能再指向别的。

 

现在倒是正确说出了两者的意思，但应该怎样记忆它们呢？
至少我觉得我经常会忘记，以后再遇到了可能又会混淆不清。-_- !

 

无意间，在网上看到有人介绍了一种不错的记忆方法，分享如下：

 

Bjarne 在他的《The C++ Programming Language》里面给出过一个助记的方法——“以 * 分界，把一个声明从右向左读”。
注意语法，* 读作 pointer to (指向...的指针)，const (常量) 是形容词，char (变量类型) 和 p (变量名) 当然都是名词。 
1)  const char * p 读作：p is a pointer to a const char，译：p 是一个指针(变量)，它指向一个常量字符(const char)。
2)  char * const p 读作：p is a const pointer to a char，译：p 是一个常量指针(const p)，它指向一个字符(变量)。
