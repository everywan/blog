# Map

map 通常原理与实现

map 源码如何在runtime时生效的

## Map in Java

## Map in Go
源码位置: `/$GOROOT/src/runtime/map.go`

Go map 遍历是乱序的: 所谓的乱序, 不是指遍历顺序有变化, 而是指每次遍历起始位置不同.
- 参考[Go map为什么遍历是无序](https://blog.csdn.net/qun_y/article/details/89115910)

参考源码: `/$GOROOT/src/runtime/map.go#mapiterinit`, 其中对起始位置添加随机数(`r := uintptr(fastrand())`).

map 遍历为什么要设置为乱序: 正常情况下, 当hash长度不变时, hash可以是顺序的(按hash值插入), 但当map容量变大, hash扩充之后, 会重新排序, 此时遍历顺序与扩充前不同.
猜测Go是因为这个原因, 才将所有的遍历设置为乱序
