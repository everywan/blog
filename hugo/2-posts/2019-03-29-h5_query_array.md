# HTTP请求中为query添加数组

开发过程中, 偶尔遇到需要在 query 中添加数组的请求. 假设我们需要传输一个 meids 数组给后端.

直接传递数组给echo后端(echo 为go服务端的一个框架), 发现 echo context.Bind() 转换参数会报错. 原因如下
1. 在 Bind 时, echo 将 queryParams 整体取出, 结构为 `url.Values == map[string][]string`
2. 当传输为 `url?meids=[1,2]` 时, `url.Values=map[meids:[[1,2]]]`, Bind 依次取出 meids 的各个元素赋值给结构体, 取出移动一个元素 `[1,2]` 转换为 int 时就会失败
3. 所以, 需要将url修改为 `url?meids=1&meids=2`, 后台才可以正常解析. (剧透可参考echo Bind 源码) (query的这种传参方式应该是约定方法)

常用思路如下
1. 将meids修改为字符串, 然后后端在 middleware/controller 中解析字符串, 转换为数组. 
2. 依旧使用数组, 借助 qs 处理数组. 对于ajax, 还可以使用 `traditional` 属性实现
  1. traditional: jQuery 需要调用 jQuery.param 序列化参数, `jQuery.param(obj, traditional)` 默认情况下traditional为false, 即jquery会深度序列化参数对象, 以适应如PHP和Ruby on Rails框架. 但servelt api无法处理, 我们可以通过设置 traditional 为 true 阻止深度序列化
    - [参考](https://www.cnblogs.com/bluecoding/p/8205894.html)
  2. 通过 qs 库实现上述逻辑.

```Javascript
import qs from 'qs'
axios.get(url, {
    params: {
     meids: [1,2],
    },
    paramsSerializer: params => {
      return qs.stringify(params, { indices: false })
    }})

// ajax 通过 traditional 属性实现
$.ajax({
  type: "get",
  traditional: true,
  data: {
    "meids": [1,2]
  },
  url: "xxxxx",
  success: function(data) {}
});
```

