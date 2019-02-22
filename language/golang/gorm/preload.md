# Preload
Preload 的用法如下

```Go
type AccountTest struct {
	ID                int          `gorm:"column:id" json:"id"`
	BusinessAccountID int          `gorm:"column:business_account_id" json:"business_account_id"`
	Wuid              int          `gorm:"column:wuid" json:"wuid"`
	Logs              []AccountLog `gorm:"foreignkey:AccountID;association_foreignkey:ID"`
}

func (AccountTest) TableName() string {
	return "accounts"
}

type AccountLog struct {
	gorm.Model
	AccountID    int `gorm:"column:account_id" json:"account_id"`
	Wuid         int `gorm:"column:wuid" json:"wuid"`
}

func (AccountLog) TableName() string {
	return "account_logs"
}
```

假设数据结构如上.

foreignkey:AccountID 表示该结构体对应的外键, 即 AccountLog 结构体中的键, association_foreignkey:ID 表示在本结构体中与外键映射的键.

Preload:
```Go
logs := []AccountTest{}
err := db.Debug().Where("business_account_id = ? and wuid = ?", 1, 1).Preload("Logs").Find(&logs).Error
// 执行的sql为
SELECT * FROM `accounts`  WHERE (business_account_id = '1' and wuid = '1')
SELECT * FROM `account_logs`  WHERE `account_logs`.`deleted_at` IS NULL AND ((`account_id` IN ('5','7')))   // 其中 5 7 为第一个sql查询结果中的ID值, 即association_foreignkey指定的值
// 最后的结果为
[{ID: 5 BusinessAccountID: 1 Wuid: 1 Logs: [
        {Model: {ID: 79 CreatedAt: 2018-06-21 09: 54: 11 +0800 CST UpdatedAt: 2018-06-21 11: 34: 59 +0800 CST DeletedAt:<nil>
            } AccountID: 5 Wuid: 1
        } {Model: {ID: 107 CreatedAt: 2018-06-28 20: 58: 15 +0800 CST UpdatedAt: 2018-06-28 20: 58: 15 +0800 CST DeletedAt:<nil>
            } AccountID: 5 Wuid: 1
        }
    ]
} {ID: 7 BusinessAccountID: 1 Wuid: 1 Logs: [
        {Model: {ID: 82 CreatedAt: 2018-06-22 12: 51: 59 +0800 CST UpdatedAt: 2018-06-22 12: 51: 59 +0800 CST DeletedAt:<nil>
            } AccountID: 7 Wuid: 1
        } {Model: {ID: 109 CreatedAt: 2018-06-28 21: 02: 47 +0800 CST UpdatedAt: 2018-06-28 21: 02: 47 +0800 CST DeletedAt:<nil>
            } AccountID: 7 Wuid: 1
        }
    ]
}]
```

参考地址
http://gorm.io/zh_CN/docs/has_many.html
http://gorm.io/zh_CN/docs/preload.html
https://www.jianshu.com/p/b2de317bfe4a


gorm 中固定部分使用 gorm.Model 而不是手写. (指 ID/CreateDate/U/D..)