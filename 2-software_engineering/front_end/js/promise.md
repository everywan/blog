# Promise
- [官方文档](http://es6.ruanyifeng.com/#docs/promise)

Promise 是异步编程的一种解决方案.

所谓Promise, 简单说就是一个容器, 里面保存着某个未来才会结束的事件(通常是一个异步操作)的结果. 从语法上说，Promise 是一个对象, 从它可以获取异步操作的消息. Promise 提供统一的 API, 各种异步操作都可以用同样的方法进行处理.

Promise对象有两个特点
1. 对象的状态不受外界影响. Promise 对象代表一个异步操作, 有三种状态: `pending(进行中) / fulfilled(已成功) / rejected(已失败)`. 只有异步操作的结果, 可以决定当前是哪一种状态, 任何其他操作都无法改变这个状态. 这也是 Promise 这个名字的由来.
2. 一旦状态改变, 就不会再变, 任何时候都可以得到这个结果. Promise 对象的状态改变, 只有两种可能: 从 pending 变为 fulfilled 和从 pending 变为 rejected. 只要这两种情况发生, 状态就凝固了, 不会再变了, 会一直保持这个结果. 这时就称为 resolved(已定型). 与事件不同的是, 事件需要监听, 错过事件消息就无法获取结果, 但是 Promise 只要状态确定, 任何事件都可以获取结果.

Promise 常用方法有 then/catch/finally, then/catch 都返回一个Promise对象. 具体解释与示例如下.
1. `then(res=>{})`: 当 Promise 状态为 onullfilled/resolved 时触发 then() 方法. 对于网络请求(Axios库), 参数通常都是 response, 返回值为 Promise.
2. `catch(e=>{})`: 当 Promise 状态为 onrejected/reject 时触发 then() 方法. 对于网络请求(Axios库), 参数通常都是 error, 返回值为 Promise. 其中, 可以通过 `e.response` 获取 response.
3. `finally(()=>{})`: 无论任何情况下都会触发. 没有参数, 也没有返回值. 常用于标记请求结束, 更改store状态(vue中)

Promise 示例如下
```TypeScript
let p1 = Promise.reject("p1")
p2 = p1.catch((err)=>{
    console.log(err)
})
let p3 = new Promise<any>((resolved,reject)=>{
    axios.(req).then(res=>{
        resolved(res)
    }).catch(e=>{
        reject(e)
    }).finally(()=>{
        console.log("request done")
    })
    // 或者这么写作用相同
    axios.(req).then(resolved).catch(reject)
})
```

## 问题
之前我们说到, then/catch 方法都返回一个Promise, 那么这个 Promise 究竟是什么呢? 如果then返回值本身就是 Promise 时, 返回值是什么? 是将返回值使用 resolved/reject 封装后返回, 还是直接返回 then 的 Promise 返回值?

另外, catch 的返回值也是 Promise, 那么返回的 Promise 是什么状态呢? 如果 catch 成功执行, 返回什么状态? 如果 catch 执行异常, 返回什么状态? 同样, 对于 then 一样么?

如果你对上面的问题有疑惑, 请参考/执行如下示例.
```TypeScript
let p1 = Promise.reject("p1")
// 获取 catch 函数的返回值, 一个 Promise 对象.
p2 = p1.catch((err)=>{
    console.log(err)
})
p3 = p1.catch((err)=>{
    return "p3"
})
p4 = p1.catch((err)=>{
    return Promise.reject("p4")
})

console.log(p2)

// 查看 p1.catch() 函数的返回值
p2.then(res=>{
    console.log(res)
})

p3.then(res=>{
    console.log(res)
})
```
观察 p2: 可以看到 p2 是状态为 resoved, 表示 `catch()` 返回的 Promise 只是用来表示 `catch()` 函数的执行情况. 通俗讲, 就是如果 `catch()` 没有报错, 那么 p2 的 `PromiseStatus==resolved`, 如果 `catch()` 执行报错, 那么 p2 的 `PromiseStatus==reject`.

观察 p2/p3: 当 `catch()` 函数没有返回值时, p2 的 `PromiseValue==undefined`, 当 `catch()` 函数返回值为`"p3"`时, `PromiseValue=="p3"`

观察 p2/p4: 当 `catch()` 函数的返回值不是 Promise 时, `catch()` 会返回一个新的 Promise, 当 `catch()` 的返回值是 Promise 时, 将该 Promise 作为返回值返回.

Promise 实现伪代码如下.
```TypeScript
// 示例源码如下
then(fn){
    value = fn(this.value)
    // 当函数执行有异常时, 返回新的Promise
    if(err){
        return Promise.reject(err)
    }
    // 如果返回值是 Promise, 则返回该Promise
    if (value instanceof Promise){
        return value
    }
    // 没有异常时, 返回一个新的 Promise, 状态为resolve, 值为函数返回值
    return Promise.resolve(value)
}
```

## 扩展
### Promise.all
`Promise.all(iterable)` 执行一系列 Promise 对象, 当所有 Promise 都执行成功时返回 resolved, 结果是一个数组, 包含各 Promise 的返回值, 顺序与参数顺序相同. 当有一个 Promise 执行失败时, `all` 函数返回 reject, 值时第一个失败 Promise 的返回值.

```TypeScript
Promise.all([p1, p2]).then((res) => {
    resolved(res)
}).catch(reject).finally(() => {
    reject("request error")
}).finally(() => {
    console.log("done")
})
```

那么, 如何自己写一个函数, 实现 `Promise.all()` 函数的功能呢? 如果想要深入了解 `Promise.all()`, 那么自己动手写个吧.
```TypeScript
let p1 = Promise.reject("p1")
let p2 = Promise.resolve("p2")
let p3 = Promise.reject("p3")
let p4 = Promise.resolve("p4")

var practice_1 = (promices: Promise<any>[]) => {
    return new Promise(function (resolve, reject) {
        let len = promices.length;
        let arr = Array(len).fill(0)
        let hasFill = 0;
        for (let i = 0; i < len; i++) {
            promices[i].then((res) => {
                arr[i] = res
                hasFill += 1;
                if (hasFill == len) {
                    resolve(arr)
                }
            }).catch((e) => {
                reject(e)
            })
        }
    })
}

practice_1([p1, p2, p3, p4]).then((res) => {
    console.log(res)
}).catch((e) => {
    console.log(e)
})
```