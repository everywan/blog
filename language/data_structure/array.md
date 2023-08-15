# 数组

以 Go 中的 slice 举例, 分别介绍下 `makeslice() && growslice()`.

[slice源码](/dataStructure/source/slice.go)

知识点如下
1. `mallocgc(size uintptr, typ *_type, needzero bool) unsafe.Pointer`: 申请并分配内存. needzero 表示是否使用默认值初始化每个元素.
2. 对于常用的数据, 可以在外层进行缓存, 在此处是 `maxSliceCap()` 的值.
3. growslice 规则
  ```Go
  if cap > old.cap * 2 {
    newcap = cap
  } else {
    if old.cap < 1024 {
      newcap = old.cap * 2
    } else {
      newcap = old.cap * 5 / 4 
    }
  }
  ```
4. `sys.PtrSize == 4 << (^uintptr(0) >> 63)`, 根据系统架构(x86/x64)决定PtrSize(指针大小). x86 中可使用的地址线为32个, 寻址范围在 `0 ~ 1<<33-1` 之间. 所以 x86 内存最大支持 4Gb(存储中, 为了方便寻址, 最小单位是byte而不是bit, 详细可以参考计算机原理), 所以Ptrsize为4即可. x64 原理如上.
5. grow

makeslice
```Go
func makeslice(et *_type, len, cap int) slice {
  // 获取可被分配的最大长度, maxSliceCap 中对常用的 Size 做了缓存, 详细见源码
	maxElements := maxSliceCap(et.size)
  // 断言数据结构size是否超过最大值.
	if len < 0 || uintptr(len) > maxElements {
		panicmakeslicelen()
	}
  // 判断总内存分配大小是否超过最大值.
	if cap < len || uintptr(cap) > maxElements {
		panicmakeslicecap()
	}

  // mallocgc 申请&&开辟内存, true 表示使用默认值初始化.(slice中每个元素都有默认值就是在这里确定的)
	p := mallocgc(et.size*uintptr(cap), et, true)
	return slice{p, len, cap}
}
```

growslice
```Go
func growslice(et *_type, old slice, cap int) slice {
  // go run -race 使用, 并发竞争检测. 详细参考 [](/language/golang/source/race.md)
	if raceenabled {...}
	if msanenabled {...}

  // 原因后续再看
	if et.size == 0 {
		if cap < old.cap {
			panic(errorString("growslice: cap out of range"))
		}
		return slice{unsafe.Pointer(&zerobase), old.len, cap}
	}

  // 增长逻辑: 当 cap>old.cap*2 时, newcap=cap
  // 否则: 当 old.cap<1024 时, newcap =old.cap*2, 否则 newcap 每次增长1/4, 直到第一个大于cap的值
	newcap := old.cap
	doublecap := newcap + newcap
	if cap > doublecap {
		newcap = cap
	} else {
		if old.len < 1024 {
			newcap = doublecap
		} else {
			for 0 < newcap && newcap < cap {
				newcap += newcap / 4
			}
			if newcap <= 0 {
				newcap = cap
			}
		}
	}

  // TODO
	var overflow bool
	var lenmem, newlenmem, capmem uintptr
	switch {
	case et.size == 1:
		lenmem = uintptr(old.len)
		newlenmem = uintptr(cap)
		capmem = roundupsize(uintptr(newcap))
		overflow = uintptr(newcap) > maxAlloc
		newcap = int(capmem)
	case et.size == sys.PtrSize:
		lenmem = uintptr(old.len) * sys.PtrSize
		newlenmem = uintptr(cap) * sys.PtrSize
		capmem = roundupsize(uintptr(newcap) * sys.PtrSize)
		overflow = uintptr(newcap) > maxAlloc/sys.PtrSize
		newcap = int(capmem / sys.PtrSize)
	case isPowerOfTwo(et.size):
		var shift uintptr
		if sys.PtrSize == 8 {
			// Mask shift for better code generation.
			shift = uintptr(sys.Ctz64(uint64(et.size))) & 63
		} else {
			shift = uintptr(sys.Ctz32(uint32(et.size))) & 31
		}
		lenmem = uintptr(old.len) << shift
		newlenmem = uintptr(cap) << shift
		capmem = roundupsize(uintptr(newcap) << shift)
		overflow = uintptr(newcap) > (maxAlloc >> shift)
		newcap = int(capmem >> shift)
	default:
		lenmem = uintptr(old.len) * et.size
		newlenmem = uintptr(cap) * et.size
		capmem = roundupsize(uintptr(newcap) * et.size)
		overflow = uintptr(newcap) > maxSliceCap(et.size)
		newcap = int(capmem / et.size)
	}

	if cap < old.cap || overflow || capmem > maxAlloc {
		panic(errorString("growslice: cap out of range"))
	}

	var p unsafe.Pointer
	if et.kind&kindNoPointers != 0 {
    // 当元素为指针类型时, 无默认值,
		p = mallocgc(capmem, nil, false)
    // memmove(to,from,n): 复制 src 所指的内存内容前 num 个字节到 dest 所指的地址上
    // 复制原地址的内容到新地址中
		memmove(p, old.array, lenmem)
    // 清空原地址内容
		memclrNoHeapPointers(add(p, newlenmem), capmem-newlenmem)
	} else {
    // TODO
		p = mallocgc(capmem, et, true)
		if !writeBarrier.enabled {
			memmove(p, old.array, lenmem)
		} else {
			for i := uintptr(0); i < lenmem; i += et.size {
				typedmemmove(et, add(p, i), add(old.array, i))
			}
		}
	}

	return slice{p, old.len, newcap}
}
```

## 其他
数组 源码如何在runtime时生效的

## ETC
c++ vector
