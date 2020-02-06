package cmd

import "github.com/spf13/cobra"

//	grpc_middleware "github.com/grpc-ecosystem/go-grpc-middleware"
//	grpc_logrus "github.com/grpc-ecosystem/go-grpc-middleware/logging/logrus"
//	grpc_ctxtags "github.com/grpc-ecosystem/go-grpc-middleware/tags"
//	grpc_validator "github.com/grpc-ecosystem/go-grpc-middleware/validator"

var xxxCmd = &cobra.Command{
	Use:   "xxx",
	Short: "xxx cmd",
	Long:  ``,
	Run: func(cmd *cobra.Command, args []string) {
		//opts, err := loadOptions()
		//handleInitError("load_options", err)
		//boot := bootstrap(opts)

		//lis, err := net.Listen("tcp", fmt.Sprintf(":%d", opts.Xxx))
		//handleInitError("grpc_listen", err)

		//var logger *logrus.Entry
		//gs := grpc.NewServer(
		//	grpc.KeepaliveParams(keepalive.ServerParameters{
		//		Time: 10 * time.Minute,
		//	}),
		//	grpc_middleware.WithUnaryServerChain(
		//		grpc_ctxtags.UnaryServerInterceptor(
		//			grpc_ctxtags.WithFieldExtractor(grpc_ctxtags.CodeGenRequestFieldExtractor),
		//			grpc_ctxtags.WithFieldExtractor(func(fullMethod string, req interface{}) map[string]interface{} {
		//				fields := map[string]interface{}{"request_id": xid.New().String()}
		//				return fields
		//			}),
		//		),
		//		grpc_logrus.UnaryServerInterceptor(logger.Entry),
		//		grpc_logrus.PayloadUnaryServerInterceptor(logger.Entry, func(ctx context.Context, fullMethodName string, servingObject interface{}) bool { return true }),
		//		grpc_validator.UnaryServerInterceptor(),
		//	),
		//)
		//pb.RegisterXxxServiceServer(gs, xxxCtrl)

		//quit := make(chan os.Signal, 1)
		//go func() {
		//	boot.Logger.Infof("grpc server start at port %d...", 111)
		//	err = gs.Serve(lis)
		//	if err != nil {
		//		boot.Logger.Fatalf("start server error, error is %v ", err)
		//		quit <- os.Interrupt
		//	}
		//}()
		//signal.Notify(quit, os.Interrupt)
		//<-quit

		//gs.GracefulStop()
	},
}

func init() {
	rootCmd.AddCommand(xxxCmd)
}
