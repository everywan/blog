## 移动端debug工具
- 安卓下debug工具较多, ios下比较惨..
- [参考: 本地调试H5页面方案总结](https://www.jianshu.com/p/a43417b28280)

通过Chrome等浏览器测试, 不再详述.

### charles
Mac下的抓包工具. 通过代理查看移动端网络请求(查看网络请求的最佳工具)

### 微信web开发者工具
- [官网链接](https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1455784140)

可以调试移动端 基于微信的网页, 也可以通过代理调试浏览器的网页.
- 可以查看 console 输出, 网络请求, 以及 css盒子模型与计算值.
- 对 网络请求-response-json 没有格式化, 不太适合查看网络请求.

### vConsole

vue插件, 启用后可以在手机端查看终端, 包括终端输出以及网络请求. 该插件也是微信团队开发的.
