<!-- TOC -->

- [HTTP Status Code](#http-status-code)
    - [1xx](#1xx)
    - [2xx-OK](#2xx-ok)
        - [200-OK](#200-ok)
        - [204-NoContent](#204-nocontent)
        - [205-ResetContent](#205-resetcontent)
        - [206-PartialContent](#206-partialcontent)
    - [3xx](#3xx)
        - [300-MultipleChoices](#300-multiplechoices)
        - [301-MovedPermanently](#301-movedpermanently)
        - [302-Found](#302-found)
        - [304-NotModified](#304-notmodified)
    - [4xx](#4xx)
        - [400-BadRequest](#400-badrequest)
        - [401-Unauthorized](#401-unauthorized)
        - [403-Forbidden](#403-forbidden)
        - [404-NotFound](#404-notfound)
        - [408-RequestTimeout](#408-requesttimeout)
        - [409-Conflict](#409-conflict)
    - [5xx](#5xx)
        - [500-InternalServerError](#500-internalservererror)
        - [505-HTTPVersionNotSupported](#505-httpversionnotsupported)
- [参考](#参考)

<!-- /TOC -->
## HTTP Status Code
HTTP状态码 是表示网络服务器 超文本传输协议(HyperText Transfer Protocol, HTTP) 响应状态的三位数字, 由 RFC2616 定义, 并由 RFC2518,RFC2817,RFC2295,RFC2774,RFC4918 等规范支持.

HTTP状态码的官方注册表由 互联网号码分配局(IANA, Internet Assigned Numbers Authority) 维护.

HTTP状态码是一种规范/公约/建议, 并不是所有服务的相应都符合此规范.

常用状态码如下
- [200:OK](#200-OK)
- [204:No Content](#204-NoContent)
- [205:Reset Content](#206-PartialContent)
- [301-Moved Permanently](#301-MovedPermanently)
- [302-Found](#302-Found)
- [304-Not Modified](#304-NotModified)
- [400-Bad Request](#400-BadRequest)
- [403-Forbidden](#403-Forbidden)
- [408-Request Timeout](#408-RequestTimeout)
- [409-Conflict](#409-Conflict)
- [500-Internal Server Error](#500-InternalServerError)
- [505-HTTP Version Not Supported](#505-HTTPVersionNotSupported)

### 1xx
表示状态已被接受, 需要继续处理. 1xx 相应都是临时相应, 只包含状态行和某些可选的响应头信息, 并以空行结束

### 2xx-OK
表示请求已成功被服务器接收, 理解, 并接受.
#### 200-OK
请求已成功, 请求所希望的响应头或数据体将随此响应返回. 实际的响应将取决于所使用的请求方法. 在GET请求中, 响应将包含与请求的资源相对应的实体. 在POST请求中, 响应将包含描述或操作结果的实体.
#### 204-NoContent
服务器成功处理了请求, 没有返回任何内容. 适合某些不需要返回数据的操作, 比如 数据更新是否成功: 成功则返回204, 不成功其他异常状态码.
#### 205-ResetContent
与204基本相同, 既成功处理请求但不返回任何数据. 但是205要求请求者重置文档视图.
#### 206-PartialContent
服务器已经成功处理了部分GET请求. 如 迅雷 等HTTP下载工具, 使用此状态码响应断点续传或文件拆分下载.

### 3xx
表示需要客户端采取进一步的操作才能完成请求. 通常用于重定向, 后续的请求(重定向地址)在本次响应的 Location域 中指明.

当且仅当后续的请求是 GET或HEAD时, 浏览器才可以在没有用户介入的情况下自动提交后续请求. 按照约定, 浏览器应当检测重定向循环(A->B->A), 避免无所谓的资源消耗. 按照 HTTP1.0 建议, 浏览器不应该自动访问超过五次的重定向.
#### 300-MultipleChoices
被请求的资源有一系列可供选择的回馈信息, 每个都有自己特定的地址和浏览器驱动的商议信息. 用户或浏览器能够自行选择一个首选的地址进行重定向.
#### 301-MovedPermanently
被请求的资源已永久移动到新位置, 并且将来任何对此资源的引用都应该使用本响应返回的若干个URI之一. 除非额外指定, 否则这个响应也是可缓存的.

新的永久性的URI应当在响应的Location域中返回. 除非这是一个HEAD请求, 否则响应的实体中应当包含指向新的URI的超链接及简短说明.

如果这不是一个GET或者HEAD请求, 那么浏览器禁止自动进行重定向, 除非得到用户的确认, 因为请求的条件可能因此发生变化
#### 302-Found
被请求的资源临时重定向到新位置. 由于这样的重定向是临时的, 客户端应当继续向原有地址发送以后的请求. 只有在Cache-Control或Expires中进行了指定的情况下, 这个响应才是可缓存的. 

其他规则与 301 相同, 唯一的区别是一个是临时的且默认不缓存 一个是永久的且默认缓存.
#### 304-NotModified
表示资源未被修改. 因为请求头指定的版本 `If-Modified-Since` 或`If-None-Match`. 在这种情况下, 由于客户端仍然具有以前下载的副本, 因此不需要重新传输资源.

### 4xx
表示客户端似乎发生了错误, 导致服务端处理数据. 除非是HEAD请求, 否则服务器应该返回解释on当前错误状况的信息, 以及是否是临时/永久的.

如果错误发生时客户端正在传送数据, 那么使用TCP的服务器实现应当仔细确保在关闭客户端与服务器之间的连接之前, 客户端已经收到了包含错误信息的数据包. 如果客户端在收到错误信息后继续向服务器发送数据, 服务器的TCP栈将向客户端发送一个重置数据包, 以清除该客户端所有还未识别的输入缓冲, 以免这些数据被服务器上的应用程序读取并干扰后者.
#### 400-BadRequest
由于明显的客户端错误, 服务器不能或不会处理该请求. 如语法错误, 请求信息无效, 数据太大, 欺骗性路由请求等.
#### 401-Unauthorized
表示当前请求需要用户验证.

当网站(通常是网站域名)禁止IP地址时, 有些网站状态码显示的401, 表示该特定地址被拒绝访问网站. 该状态码是 RFC7235 补充的.
#### 403-Forbidden
服务器已经理解请求, 但是拒绝执行它. 如果这不是一个HEAD请求, 而且服务器希望能够讲清楚为何请求不能被执行, 那么就应该在实体内描述拒绝的原因. 常见于 访问频次过高, 被服务器禁止访问, 如爬虫频繁抓取某些信息.
#### 404-NotFound
请求失败, 请求所希望得到的资源未被在服务器上发现, 但允许用户的后续请求. 如用户输入了错误/不存在的路径.
#### 408-RequestTimeout
请求超时. 根据HTTP规范, 客户端没有在服务器预备等待的时间内完成一个请求的发送, 客户端可以随时再次提交这一请求而无需进行任何更改.
#### 409-Conflict
因为请求存在冲突无法处理该请求, 例如多个同步更新之间的编辑冲突.

### 5xx
表示服务器无法完成明显有效的请求. 5xx代表服务器在处理请求的过程中有错误或者异常状态发生, 也有可能是服务器意识到以当前的软硬件资源无法完成对请求的处理.

除非这是一个HEAD请求, 否则服务器应当包含一个解释当前错误状态以及这个状况是临时的还是永久的解释信息实体. 浏览器应当向用户展示任何在当前响应中被包含的实体. 这些状态码适用于任何响应方法.
#### 500-InternalServerError
通用错误消息, 服务器遇到了一个未曾预料的状况, 导致了它无法完成对请求的处理. 没有给出具体错误信息.
#### 505-HTTPVersionNotSupported
服务器不支持, 或者拒绝支持在请求中使用的HTTP版本. 这暗示着服务器不能或不愿使用与客户端相同的版本. 响应中应当包含一个描述了为何版本不被支持以及服务器支持哪些协议的实体.

## 参考
- [HTTP状态码-维基百科](https://zh.wikipedia.org/zh-hans/HTTP状态码)
- [Restful手册](https://sofish.github.io/restcookbook/)