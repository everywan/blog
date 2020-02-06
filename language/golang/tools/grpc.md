# grpc
rpc: Remote Procedure Call, 远程过程调用, 分布式部署的服务之间互相调用的技术. 解决服务通信的问题.

通常来讲, HTTP 用于提供给外部服务, 使用标准的格式如REST, 如网站.
RPC更多的是面向服务内部之间的互相调用, 更注重 RPC函数能像本地函数一样调用, 一般RPC框架会支持 socket/http/http2 等多种连接方式, 以及 protobuf/xml/soap 等多种数据格式, 以追求服务间通信的效率.

将上述设计思想上的差异具体表现出来就是
1. HTTP 多使用路由拘束, 推荐使用 REST 风格. 而 RPC 框架一般使用 Schema 约束请求, 包括请求函数与参数.
2. HTTP 使用标准的HTTP协议, 而RPC框架可以根据业务需求使用 socket/http 等多种链接方式, 可以实现长链接等(HTTP1是每次请求一个新连接, HTTP2支持连接共享(即复用))
3. HTTP 报文中有很多信息使我们不需要的, RPC使用其他的数据格式可以减少数据包大小, 提升传输效率, 而且如 protobuf 等格式的序列化/反序列化效率更高, 具体后续再查阅.
4. 如下是延伸出的优点: RPC 框架可以支持 服务自动注册与发现,负载均衡,连接池,可视化管理 等功能, 避免重复造轮子

可以总结如下: 
1. HTTP服务可以视为RPC服务的一种, 因为他可以实现 RPC 框架的要求.
2. 由于 HTTP 并不是特别适合服务内部调用的场景, 但是这种需求又很频繁/重要, 所以针对这些场景, 衍生出了 grpc 等rpc框架.

常用的RPC框架
1. grpc
2. thrift
3. dubbo(java)
4. wcf(.Net)

由于我使用的Go语言, 自然选择grpc.

参考: https://www.jianshu.com/p/b0343bfd216e

rpc解决的问题:
1. 通信: 建立tcp连接, 以及连接方式: 长连接/随用随连
2. 寻址: 寻找机器地址与服务地址
3. 数据序列化/反序列化

rpc是技术名词, 并非协议/框架. rpc可以通过http实现, 但是一般 已实现的rpc框架有以下特点
- 使用特有的数据格式, 序列化/反序列化, 包头包尾相比较http更短, 传输效率更高(数据体积减少)
- 自定义rpc一般使用长链接, 减少断开/重连的损耗
- 有框架, 可以很方便的实现功能

grpc 使用 Protocol Buffer 数据结构

使用方式: [参考: 官方示例](https://github.com/grpc/grpc-go/tree/master/examples/helloworld)
1. 定义 .proto 文件
2. 使用 .proto 生成 .go 文件: `protoc --go_out=plugins=grpc:. xxx.proto`
3. 创建服务端: 服务端创建结构体server实现 .proto 中定义的接口, 并使用该接口实例注册rpc服务(`pb.RegisterXXXServer(s, &server{})`).
4. 客户端链接服务端地址, 注册客户端即可 远程调用

## 示例
服务端注册
```go
func init(){
	lis, err := net.Listen("tcp", port)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	s := grpc.NewServer()
	pb.RegisterGreeterServer(s, &server{})
	// Register reflection service on gRPC server.
	reflection.Register(s)
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
```

客户端注册
```go
func main() {
	// Set up a connection to the server.
	conn, err := grpc.Dial(address, grpc.WithInsecure())
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()
	c := pb.NewGreeterClient(conn)

	// Contact the server and print out its response.
	name := defaultName
	if len(os.Args) > 1 {
		name = os.Args[1]
	}
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
    defer cancel()
    // 函数调用
	r, err := c.SayHello(ctx, &pb.HelloRequest{Name: name})
	if err != nil {
		log.Fatalf("could not greet: %v", err)
	}
	log.Printf("Greeting: %s", r.Message)
}
```

## 插件
### validator
[go-proto-validators](https://github.com/mwitkow/go-proto-validators)

A protoc plugin that generates Validate() error functions on Go proto structs based on field options inside .proto files.

就一 readme, 没有文档, 字段需要自己去代码里看.

字段信息: [validator.proto](https://github.com/mwitkow/go-proto-validators/blob/master/validator.proto)

示例: [官方代码](https://github.com/mwitkow/go-proto-validators/tree/master/examples)
```Proto
import "github.com/mwitkow/go-proto-validators/validator.proto";
message InnerMessage {
  // some_integer can only be in range (1, 100).
  int32 some_integer = 1 [(validator.field) = {int_gt: 0, int_lt: 100}];
}
```

### annotations
grpc 转 http 插件

[annotations](https://github.com/googleapis/googleapis/blob/master/google/api/annotations.proto)

使用方法.. 好了, 这个连readme都懒得写.. 大概搜索了下, 在如下两个位置
1. [google cloud 文档管理: grpc transcoding](https://cloud.google.com/endpoints/docs/grpc/transcoding?hl=zh-cn)
2. 还是代码即文档.. [annotations http.proto](https://github.com/googleapis/googleapis/blob/master/google/api/http.proto)

示例
```Proto
import "google/api/annotations.proto";

service Messaging {
  rpc GetMessage(GetMessageRequest) returns (Message) {
    option (google.api.http) = {
      get: "/v1/{name}"
    };
  }
}
```

对于 http 方法所需字段和 grpc 所需字段
1. 优先从 url 中取出对应字段, 填充到 MessageRequest 中
2. url 中找不到的字段
  - 如果是 GET 方法, 则从 querystring 中取其他字段, 取不到则默认值
  - 如果是 POST/PATCH 等方法, 则从 body 中取.
3. 添加正则匹配: `get "/v1/{name=messgae/*}"`, 则请求路径变为 `/v1/message/{name}`
4. 绑定多个路由: 
  ````
  get: "/v1/messages/{message_id}"
  additional_bindings {
    get: "/v1/users/{user_id}/messages/{message_id}"
  }
  ```

## 编译示例
```Makefile
proto:
	# If build proto failed, make sure you have protoc installed and:
	# go get -u github.com/google/protobuf
	# go get -u github.com/golang/protobuf/protoc-gen-go
	# go install github.com/mwitkow/go-proto-validators/protoc-gen-govalidators
	# mkdir -p ${GOPATH}/src/github.com/googleapis && git clone git@github.com:googleapis/googleapis.git ${GOPATH}/src/github.com/googleapis/
	# Building proto for Golang
	@protoc \
		--proto_path=${GOPATH}/src \
		--proto_path=${GOPATH}/src/github.com/googleapis/googleapis \
		--proto_path=. \
		--include_imports \
		--include_source_info \
		--go_out=plugins=grpc:$(PWD)/pb \
		--govalidators_out=$(PWD)/pb \
		--descriptor_set_out=$(PWD)/envoy/example.descriptor \
 		example.proto
	$(call color_out,$(CL_ORANGE),"Done")
```

## 使用
项目结构:
````
xxx.proto
- client      Client, 提供给其他项目使用. 创建一个 grpc Client
- pb          存放生成的 pb 代码
````

---
grpc server 启动示例

grap server 一般还增加如下中间件
```Go
import (
  grpc_middleware "github.com/grpc-ecosystem/go-grpc-middleware"
  grpc_logrus "github.com/grpc-ecosystem/go-grpc-middleware/logging/logrus"
  grpc_ctxtags "github.com/grpc-ecosystem/go-grpc-middleware/tags"
  grpc_validator "github.com/grpc-ecosystem/go-grpc-middleware/validator"
)

var logger *logrus.Entry
gs := grpc.NewServer(
	grpc.KeepaliveParams(keepalive.ServerParameters{
		Time: 10 * time.Minute,
	}),
	grpc_middleware.WithUnaryServerChain(
		grpc_ctxtags.UnaryServerInterceptor(
			grpc_ctxtags.WithFieldExtractor(grpc_ctxtags.CodeGenRequestFieldExtractor),
			grpc_ctxtags.WithFieldExtractor(func(fullMethod string, req interface{}) map[string]interface{} {
				fields := map[string]interface{}{"request_id": xid.New().String()}
				return fields
			}),
		),
		grpc_logrus.UnaryServerInterceptor(logger.Entry),
		grpc_logrus.PayloadUnaryServerInterceptor(logger.Entry, func(ctx context.Context, fullMethodName string, servingObject interface{}) bool { return true }),
		grpc_validator.UnaryServerInterceptor(),
	),
)
pb.RegisterXxxServiceServer(gs, xxxCtl)
```

## 测试
evans grpc cli 测试工具

