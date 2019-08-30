# 批量插入
目前 gorm 尚不支持批量插入.

[issue](https://github.com/jinzhu/gorm/issues/255)

根据 反射 + gorm 实现的批量插入小工具如下, 借助 反射取出结构提所有字段, 借助 gorm 插入数据库.
1. 要求
  - Struct 中必须包含 gorm tag
2. 程序自动取所有字段(Public字段)拼接

示例源码如下
```Go
type Test struct {
	ID  int `gorm:"id"`
	Val int `gorm:"val"`
}

func main() {
	ls := make([]*Test, 2)
	for i := range ls {
		ls[i] = &Test{}
		ls[i].ID = i
		ls[i].Val = i
	}
	fmt.Println(genSql(ls, "test"))
}

func genSql(ptrs []*Test, table string) (sql string, values []interface{}) {
	values = []interface{}{}
	if len(ptrs) == 0 {
		return "()", values
	}
	ptr := ptrs[0]
	typ := reflect.TypeOf(ptr).Elem()

	if typ.Kind() != reflect.Struct {
		return "()", values
	}
	fields := ""
	placeholder := "("
	for i := 0; i < typ.NumField(); i++ {
		field := typ.Field(i)
		gormTag := field.Tag.Get("gorm")
		if gormTag == "" {
			gormTag = field.Name
		}
		fields += gormTag + ","
		placeholder += "?,"
	}
	placeholder = placeholder[:len(placeholder)-1] + ")"
	fields = fields[:len(fields)-1]
	placeholders := ""
	for _, b := range ptrs {
		val := reflect.ValueOf(*b)
		for i := 0; i < typ.NumField(); i++ {
			values = append(values, val.Field(i).Interface())
		}
		placeholders += placeholder + ","
	}
	placeholders = placeholders[:len(placeholders)-1]
	sql = fmt.Sprintf("INSERT INTO %s ( %s ) VALUES %s ", table, fields, placeholders)

	return sql, values
}
```
