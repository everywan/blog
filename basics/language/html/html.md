query
params

通常, url? 后是query/parmas的内容, body里的内容一般以data/from表示


### Content-Type
Content-Type: Content-Type 属性指定请求和响应的HTTP内容类型, 常见类型如下
- text/html
- text/plain
- text/css
- text/javascript
- application/x-www-form-urlencoded
- multipart/form-data
- application/json
- application/xml
- ...

#### application/x-www-form-urlencoded
表单提交类型, 后台可以从 from中提取内容. 

后台获取的 raw body 是 `name=homeway&key=nokey`

#### multipart/form-data
当文件太长, HTTP 无法在一个包之内发送完毕, 就需要分割数据, 分割成一个一个 chunk 发送给服务端, 这时就是 multipart/form-data 的类型