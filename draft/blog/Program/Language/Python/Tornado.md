<!-- TOC -->

- [Tornado](#tornado)
    - [Web框架](#web框架)
        - [Application&RequestHandler](#applicationrequesthandler)
            - [简单示例](#简单示例)
            - [文档](#文档)
                - [RequestHandler](#requesthandler)
                - [使用模板](#使用模板)

<!-- /TOC -->

# Tornado

## Web框架
### Application&RequestHandler
> [web应用](http://tornado-zh.readthedocs.io/zh/latest/web.html)
#### 简单示例
```Python
def webApp():
    ' web应用 '
    import tornado.ioloop
    import tornado.web
    
    class TestHandle(tornado.web.RequestHandler):
        def get(self):
            self.write("<h1>Hello Tornado WebApp Test!<h1>")

    def testFun():
        return tornado.web.Application([
            url(r'/',TestHandle)
        ])

    app = testFun()
    app.listen(8080)
    tornado.ioloop.IOLoop.current().start()
```
#### 文档
1. Application: 路由表. 负责配置以及映射请求到处理程序
    - 构造函数: `Application(handlers=None, default_host=None, transforms=None,**settings)`
        - handlers: URLSpec对象数组, `[(parttern,RequestHandler,dict()),...]`, 负责配置映射到处理程序
            - `parttern`: url正则表达式
            - `RequestHandler` 处理请求的 Handler. 
            - `dict()`: 作为参数传递给 `RequestHandler.initialize()`, 在请求发生时被调用
            - 示例: `(parttern,RequestHandler,dict())`
        - `**settings`: 路由表属性
            - `autoreload`: 自动重载所做更改, debug时使用
    - 示例: `tornado.web.Application([(r'/',TestHandle)],default_host=None,transforms=None,autoreload=True)`
##### RequestHandler
1. RequestHandler: 请求处理类. 重写 `get()`/`post()` 等HTTP方法实现响应 `get/post` HTTP请求
2. 常用方法
    - `write()`: 输出请求返回值
    - `get_argument()/get_arguments()` 获取参数
        - `get_query_argument()/get_query_arguments()`
        - `get_body_argument()/get_body_arguments()`
        - `decode_argument()`: 从请求中解码一个参数， 返回unicode字符串. 如有需要可被复写
    - `write_error()`: 错误页面的输出
    - `on_connect_close()`: 当客户端断开链接时调用.(并不能保证一定可以监听到链接断开)
    - `set_default_headers`: 设置额外的响应头(可解决跨域)
    - `log_function()`: 在每次结束时调用, 记录请求结果
    - `get_current_user`, `get_user_locale`
3. 请求产生时， 处理程序执行流程
    1. 生成一个新的 `RequestHandler` 对象
    2. `Application` 的初始化函数调用 `initialize()` 方法
    3. 调用 `prepare()`方法: 无论使用哪种HTTP方法, `prepare()` 都会被调用
    4. 调用HTTP方法, 如果URL的正则表达式包含捕获组, 捕获值作为参数传递给HTTP方法(使用`get_argument()`获取参数)
    5. 请求结束, 调用 `on_finish()` 方法. 同步调用程序在 `get()`等HTTP方法后立即返回, 异步调用会在 `finish()` 后返回
4. 错误处理: Tornado 默认使用 `RequestHandler.write_error()` 处理错误并且生成错误页
    - 可以使用 `tornado.web.HTTPError` 生成指定错误码, 默认返回响应码 500
    - 在 HTTP方法中, 可以通过 `rasie HTTPError(404)` 或复写 `write_error()` 处理错误
5. 重定向: 可以使用 `RequestHandler` 类内方法或 `RedirectHandler` 类实现重定向
    - `RequestHandler.redirect(url, permanent=False, status=None)`: permanent 标示是否永久重定向, status标示响应状态码
        - `permanent=False` 默认响应状态码`302`, True 则默认为`301 Moved Permanently`
    - `RedirectHandler`: 直接在 Application 路由表配置, 支持正则替换
        - 示例1: `tornado.web.Application([(r"/baidu", tornado.web.RedirectHandler,dict(url="http:www.bing.com")),])`
        - 示例2(正则): `(r"/pictures/(.*)", tornado.web.RedirectHandler,dict(url=r"/photos/1")`
##### 使用模板
1. `RequestHandler.render(template_name, **kwargs)`: 以固定模板渲染返回结果, `**kwargs` 表示传入模板的值
2. html模板语法
    - 控制语句: `{% ... %}`, 使用 `{% end %}` 结束
    - 表达式: `{{ ... }}`
    - 示例(控制语句): `{% for item in items %} {{ escape(item) }} {% end %}`
    - 示例(表达式): `<title>{{ title }}</title>`