package codes

import "fmt"

// DBRecordNotFound 未找到数据
var DBRecordNotFound = &Error{Code: NotFound, Msg: "未找到数据 in db"}

// BadRequestError 未找到数据
var BadRequestError = &Error{Code: BadRequest, Msg: "请求不合法, 请检查参数"}

type (
	// Error 自定义error类型
	Error struct {
		Code       string `json:"code"`
		Msg        string `json:"msg,omitempty"`
		InnerError error  `json:"-"`
	}
)

func (e Error) Error() string {
	return fmt.Sprintf("code: %s, msg: %s", e.Code, e.Msg)
}
