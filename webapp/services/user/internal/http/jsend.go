//
// user/internal/http/jsend.go
//

package http

type JSend struct {
	Status  string      `json:"status"`
	Data    interface{} `json:"data,omitempty"`
	Message string      `json:"message,omitempty"`
}

func Success(data interface{}) JSend {
	return JSend{
		Status: "success",
		Data:   data,
	}
}

func Fail(msg string) JSend {
	return JSend{
		Status:  "fail",
		Message: msg,
	}
}

func Error(msg string) JSend {
	return JSend{
		Status:  "error",
		Message: msg,
	}
}