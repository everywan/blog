package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"reflect"
	"strings"
)

type resultMap struct {
	Code int16
	Body string
}

func main() {
	defer func() {
		if err := recover(); err != nil {
			fmt.Println(err)
		}
	}()

	var chargeingPile ChargeingPile
	// 为所有方法添加handle
	//　为什么必须使用地址
	t := reflect.TypeOf(&chargeingPile)
	for i := 0; i < t.NumMethod(); i++ {
		http.HandleFunc("/"+t.Method(i).Name, getStatus)
	}
	err := http.ListenAndServe(":9090", nil)
	if err != nil {
		fmt.Println("", err)
	}
}

func getStatus(w http.ResponseWriter, r *http.Request) {
	result := resultMap{
		Code: 0,
		Body: "",
	}
	defer func() {
		if err := recover(); err != nil {
			fmt.Println(err)
		}
		jsonResult, _ := json.Marshal(result)
		fmt.Fprintf(w, "%s", jsonResult)
	}()
	r.ParseForm()
	// 设置参数
	var chargeingPile ChargeingPile
	v := reflect.ValueOf(&chargeingPile)
	cmd := strings.Replace(r.URL.Path, "/", "", -1)
	msg := r.Form["msg"]
	args := []reflect.Value{reflect.ValueOf(msg[0])}
	// 执行反射方法
	fmt.Println("开始执行反射方法: " + cmd)
	values := v.MethodByName(cmd).Call(args)
	fmt.Println("反射方法执行完毕: " + cmd)
	hashId := values[0].String()
	result.Body = hashId
}

type ChargeingPile struct{}

func (c *ChargeingPile) Showmsg(msg string) string {
	return "执行成功" + msg
}
func (c *ChargeingPile) Test1(msg string) string {
	return "执行成功" + msg
}
