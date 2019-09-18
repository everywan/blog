# Map

map 通常原理与实现

map 源码如何在runtime时生效的

## Map in Java

## Map in Go
源码位置: `/$GOROOT/src/runtime/map.go`

Go map 遍历是乱序的: 所谓的乱序, 不是指遍历顺序有变化, 而是指每次遍历起始位置不同.
- 参考[Go map为什么遍历是无序](https://blog.csdn.net/qun_y/article/details/89115910)

参考源码: `/$GOROOT/src/runtime/map.go#mapiterinit`, 其中对起始位置添加随机数(`r := uintptr(fastrand())`).
