# grpc
rpc介绍: rpc(远程服务调用), 分布式部署的服务之间互相调用的技术. 解决服务通信的问题.

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
