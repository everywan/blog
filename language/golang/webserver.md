# Web服务
基于Go原生HTTP函数开发Web服务基础示例.

## 监听函数
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

## controller
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

## 其他
1. 重定向: `func Redirect(w ResponseWriter, r *Request, urlStr string, code int)`
