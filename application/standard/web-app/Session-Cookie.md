## Session 与 Cookie
> 参考 [session和数据存储](https://github.com/astaxie/build-web-application-with-golang/blob/master/zh/06.1.md)

为什么我们需要session/cookie: 
因为HTTP协议是无状态的, 所以客户的每一次请求都是无状态的; 既我们不知道在整个Web操作过程中, 当前进行到了哪一步, 客户是否已经登录. session/cookie 就是为了解决这个问题: 在无状态的请求中, 在服务端/浏览器 记录用户的状态.

所以, session/cookie 常常用于保存用户的一些操作信息, 比如 token, 比如浏览位置, 比如购物车,历史记录等(多数采用存储到session,并且持久化)

### Cookie
> [常用的本地存储—cookie篇](https://segmentfault.com/a/1190000004743454)
Cookies在本地浏览器记录用户数据, 并随每一个请求发送至同一个服务器, 提供用户之前的状态. 网络服务器用HTTP头向客户端发送cookies, 在客户终端, 浏览器解析这些cookies并将它们保存为一个本地文件, 它会自动将同一服务器的任何请求带上这些cookies.

同一个域名下可以共享Cookie, 部分浏览器出于安全考虑, Cookie无法跨域设置/获取, 既A域名只能设置当前域名和父域名的Cookie. 

Cookie的定义/用处/结构/用法基本已经约定, 各浏览器类似, 是一种具体的技术/实现; 在Cookie中, 常常保存以下数据:
- 用户身份验证数据, 如token, 用于在之后的浏览中标记该用户已经登录. 如果不使用Cookie保存, 只能在每次请求的url中捎带此字段(如 `url?token=...`)
- 跟踪用户行为: 比如浏览位置, 
- 指定数据: 如购物车, 浏览足记等.

#### Cookie的结构
> chrome可以通过: 开发者模式 --> Application --> Cookies 查看Cookie的结构

- name/value: k-v 对, 要存储的值. 其他字段都是元数据, 用于描述该key的信息
    - 一般包含Token, 用于验证身份.
    - 一般包含sid, 用于标识Session.
- domain/path: 共同决定Cookie的作用域
- expries/max-age: 控制声明周期, 默认关闭浏览器则删除. 一般session数据会采用默认方式.
    - expries表示失效时刻, max-age表示生效时间段. max-age是为了取代expries而出现的.
- secure: 安全标识, 设置后, cookie只有在使用SSL连接(如HTTPS请求)时才会发送到服务器. 默认不指定
- httponly: 限制客户端脚本对cookie的访问, 减轻xss攻击的危害, 防止cookie被窃取, 以增强cookie的安全性. 默认不指定

Cookie的 方法/设置 等参考链接文章.

#### 注意事项
- 安全性: 由于cookie在HTTP中是明文传递的, 其中包含的数据都可以被他人访问, 可能会被篡改,盗用.
- 大小限制: cookie的大小限制在4KB左右, 若要做大量存储显然不是理想的选择.
- 增加流量: 在其作用域内, 对于每次请求, cookie都会被自动添加到Request Header中, 无形中增加了流量. cookie信息越大, 对服务器请求的时间也越长.

### Session
Session在服务器端保存用户数据. 服务器使用 sessionId 标识用户, 并保存其他指定数据.

与Cookie不同, Session没有具体的实现, 接口, 只是一种模式, 一种机制, 一种思想. 凡是实现其功能, 都可称之为 Session.

Session可以看做Cookie的服务端实现, 相应的结构可以参照设计. 

#### Session结构
Session实现可以参考 [Go-Session实现](https://github.com/astaxie/build-web-application-with-golang/blob/master/zh/06.2.md), 不过这个写的比较复杂. 也可以使用第三方库.

- SessionId: 标识用户
- MaxAge: 标识过期时间
- Value: 键值对, 存储信息.
- Token: 身份验证
- Get/Set/Init/Delete 方法

还有需要考虑的就是, session的持久化.

### ETC
#### Token
而token, 和session/cookie关系并不大. token常用于身份校验, 每次登录后生成一个token, 在之后的访问中使用token替代passwd校验身份, 减少密码传输的次数. token中一般包含生成/解析的方法, token结构体中有用户id等一些信息.
