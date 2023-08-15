echo 在response中, httpstatus==200, 数据格式返回如下
1. `ctx.String(int,string)`: 数据可在 `res.request.response` 中读到
2. `ctx.JSON(int,interface{})`: 数据可在 `res.data` 中读到

为什么这样子? axios 处理的还是 echo 处理的?
