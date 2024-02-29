## 指针
```Go
// 如下, 最终输出什么
func main() {
	var a, b *[]int
	a = &[]int{1, 3, 4}
	b = a
	a = &[]int{2}
	fmt.Printf("a= %p, b= %p\n", a, b)
	fmt.Println(a, b)
}
```

最近经常被这个弄混.. 其实想想很简单. 以 `var a,b int; a=1; b=a; a=2;` 举例, 在 `b=a` 时, 是将 a 的值赋给b, 而非将b指向a. 指针同理.
