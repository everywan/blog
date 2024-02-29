# HTTP
net/http 包

主要包括如下
1. server 端: 提供http服务
2. client 端: HTTP客户端, 发起HTTP请求

## web服务
go 使用 http.Server 函数监听端口, 然后调用 Handler.ServeHTTP 方法处理请求.
- Server签名: `func Serve(l net.Listener, handler Handler) error`
- Handler 是定义了 `ServeHTTP(ResponseWriter, *Request)` 方法的 interface

常用的 Handler 有如下几种
- 路由分发: Go 提供了 ServeMux 结构体, DefaultServeMux 实例. ServeMux 实现了 Handler 接口, 实现了 parttern 的匹配(路由匹配). 
  - ServeMux 是HTTP请求的多路转接器. 它会将每一个接收的请求的URL与一个注册模式的列表进行匹配, 并调用和URL最匹配的模式的处理器
  - 处理器参数是nil表示采用包变量DefaultServeMux作为处理器. Handle和HandleFunc函数可以向DefaultServeMux添加处理器.
- 文件服务: Go 提供了 FileServer 函数, 返回 文件访问服务的 Handler.
  - FileServer签名: `func FileServer(root FileSystem) Handler`
- 自定义处理: 自己实现 Handler 接口, 根据 Request 处理请求, 将返回数据写入到 ResponseWriter 中.

### 例子
基于Go原生HTTP函数开发Web服务基础示例.

监听函数
```Go
func startWebServer(ipaddr string, network string) {
	defer func() {
		if err := recover(); err != nil {
			logger.ERROR(fmt.Sprintf("启动socket网络服务(startWebServer) 发生错误: %+v", err))
		}
	}()
    // 添加handle
    http.HandleFunc("/v1/test", test)
	// 设置监听
	listenPort := configure.ReadConfigByKey("./init.ini", "Net", "listenPort")
	// 创建server对象, 设置超时时间
	server := &http.Server{
		Addr:         ":" + listenPort,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 5 * time.Second,
	}
	err := server.ListenAndServe()
	if err != nil {
		logger.ERROR(fmt.Sprintf("启动socket网络服务(startWebServer) 发生错误(ListenAndServe方法): %+v", err))
	}
}
```

controller
```go
func test(w http.ResponseWriter, r *http.Request) {
	result := "false"
	defer func() {
		if err := recover(); err != nil {
			logger.ERROR(fmt.Sprintf("执行web方法出错(test), 错误是: %+v", err))
		}
		jsonResult, _ := json.Marshal(result)
		fmt.Fprintf(w, "%s", jsonResult)
    }()
    // 解析URL中的查询字符串(POST或PUT请求主体要优先于URL查询字符串)
    r.ParseForm()
    if msg, ok := r.Form["msg"]; ok {
        result = msg
    }else{
        result = "true"
    }
}
```

重定向: `func Redirect(w ResponseWriter, r *Request, urlStr string, code int)`
