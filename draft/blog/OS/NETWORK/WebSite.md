## 浏览器是如何解析网站的
1. 当在浏览器地址栏输入url时, 为什么html会被渲染出来,但是其他比如 js/json/文本 不会渲染, 浏览器是如何识别的?
    - 答: 其实 浏览器接收到请求返回的数据时, 是没有格式的. 后缀的格式是给人看而不是给机器看的. 浏览器在收到 服务器返回的数据后, 不论内容是什么, 浏览器都会去渲染, 只是默认情况下只有html可以被渲染出来而已
    - 同样,参考sql语句.不管你输入什么 数据库都会去执行, 只不过有些是 错误的/恶意的 sql,数据库执行不了而已, 并不是因为这个后缀,才可以被执行的
    - 使用 静态资源映射/服务 返回数据时有感(服务 是指 直接读取服务器上的html数据返回, 所以返回数据里没有文件名等信息,所以想到了这个问题)
2. DNS解析默认服务器的80端口,只能指定IP,不能指定端口 (所以,域名只能绑定服务器的80端口)
3. 多个域名指定一个IP的方法: 获取 request.Host , 判断是哪个域名访问,然后做分支判断.

### 多域名指向同一IP的实现
> 基于 GO 语言实现
#### 方法
1. 首先获取 `Request.Host`, 根据不同的域名切换相应的 服务/静态资源(html/js/css等)
2. 实现静态资源的返回: `http.HandleFunc("/", fileServer)`
    - 不加任何后缀返回 `index.html/default.html`(看自己爱好选择)
    - css 文件设置Header中的 `Content-Type`: `w.Header().Set("Content-Type", "text/css")`
    - 其他情况直接返回文件内容
#### demo
> 完整示例在 [瞎搞瞎玩](https://github.com/everywan/xiagaoxiawan)
```Go
// http.HandleFunc("/", fileServer)
func fileServer(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	_url := r.URL.Path
	_len := len(_url)

	// 首先根据 Host 做一遍划分
	_htmlDir := func() string {
		switch r.Host {
		case "www.xiagaoxiawan.com":
			return htmlDir
		case "todo.xiagaoxiawan.com":
			return htmlDir + "/play/TODO"
		case "drawgraph.xiagaoxiawan.com":
			return htmlDir + "/play/DrawGraph"
		case "resume.xiagaoxiawan.com":
			return htmlDir + "/play/resume"
		}
		return htmlDir
	}()

	if _url == "/" {
		// 默认情况
		_url = _htmlDir + "/index.html"
	} else if _len > 4 && _url[_len-4:] == ".css" {
		_url = _htmlDir + _url
		w.Header().Set("Content-Type", "text/css")
	} else {
		_url = _htmlDir + _url
	}
	data, _ := common.GetFileHelper(_url)
	fmt.Fprintf(w, "%s", data)
}
```