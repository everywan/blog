web框架对比

iris/gin/echo/beego

beego 不考虑了

区别点
1. Context
  - gin 中, `gin.Context` 是struct, 不易扩展
  - iris/echo 中, Context 是 interface.
2. Middreware: `route.Use`
