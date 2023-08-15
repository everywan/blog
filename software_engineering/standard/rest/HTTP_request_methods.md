<!-- TOC -->

- [HTTP请求方法](#http请求方法)
    - [GET](#get)
    - [HEAD](#head)
    - [POST](#post)
    - [PUT](#put)
    - [DELETE](#delete)
    - [TRACE](#trace)
    - [OPTIONS](#options)
    - [CONNECT](#connect)
    - [PATCH](#patch)
- [其他](#其他)
    - [PUT/PATCH/POST-幂等](#putpatchpost-幂等)
    - [幂等性(idempotent)](#幂等性idempotent)
    - [安全方法](#安全方法)

<!-- /TOC -->

## HTTP请求方法
HTTP是一个客户端和服务端请求和应答的标准.

- 所有的HTTP方法中, 除了 POST/PATCH 之外, 其他的方法都符合 [幂等性](#幂等性).
    - 按照规范而言, POST/PATCH 在一定条件下满足幂等性, 但是其他方法何时都满足幂等性.
- 所有的HTTP方法中, 只有 GET/HEAD/OPTION 方法是 [安全方法](#安全方法).
- 参考: https://sofish.github.io/restcookbook/http%20methods/idempotency/

### GET
GET方法应该只用在读取数据, 而不应该被用于产生"副作用"的操作中. 既GET请求不应该改变服务器资源状态.

### HEAD
与GET方法一样, 都是向服务器发出指定资源的请求. 只不过服务器将不传回资源的本文部分, 只返回该资源的元信息.

### POST
向指定资源提交数据, 请求服务器进行处理(例如提交表单或者上传文件). 数据被包含在请求文本中(body). 这个请求可能会创建新的资源或修改现有资源, 或二者皆有.

### PUT
替换服务器资源为上传资源.

### DELETE
请求服务器删除Request-URI所标识的资源.

### TRACE
回显服务器收到的请求, 主要用于测试或诊断.

### OPTIONS
使服务器传回该资源所支持的所有HTTP请求方法. 

用 '*' 来代替资源名称, 向Web服务器发送OPTIONS请求, 可以测试服务器功能是否正常运作.

### CONNECT
HTTP/1.1协议中预留给能够将连接改为管道方式的代理服务器. 通常用于SSL加密服务器的链接(经由非加密的HTTP代理服务器).

### PATCH
PATCH 是 RFC5789新加的方法, 用于将局部修改应用到资源.

## 其他
### PUT/PATCH/POST-幂等
首先, 按照规范, PUT是幂等的, 而PATCH不是幂等的.

PATCH和PUT的区别就在于, PUT必须提供全量的对象信息替换原有的服务器资源. 而PATCH只会更新提供的字段.

之所以 PUT 是幂等而 PATCH 不是幂等的, 是因为存在情况使PATCH不符合幂等原则, 举例如下: 假如对象中有一个version字段用来记录版本, 每次PATCH, version++. 正因为这样的不可控性, 所以PATCH被定义为可能是非幂等的. 而PUT请求替换整个资源, 多次请求都是替换成相同的资源, 与一次相同, 所以 PUT 总是幂等的.

POST 方法不是幂等的 是因为当发送创建资源的请求时, 多次请求会产生多个资源.

在Rest里, 一个HTTP方法不满足幂等性 不是指该方法在所有的情况下都不满足, 而是存在不满足幂等的情况 则认为该方法不是幂等方法. 只有一直满足幂等性的方法, 才是幂等方法.

当然, 这一切的前提都是按照Restful规范开发.

### 幂等性(idempotent)
一个幂等操作的特点是其任意多次执行所产生的影响均与一次执行的影响相同.

### 安全方法
安全方法是指 不修改服务器资源的方法.
