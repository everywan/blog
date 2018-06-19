# 查询地点信息_高德地图
## 介绍
- 通过高德地图的 `http://restapi.amap.com/v3/geocode/geo` 接口获取省市等地区的详细信息. 
- 示例: `http://restapi.amap.com/v3/geocode/geo?key=7bb32daa7da4c202280232aeb5606cf9&s=rsv3&address=中关村` 获取中关村详细信息
### 流程
1. 从文件中读取要查询的地点列表
2. 调用高德接口,获取查询到的地点的详细信息
3. 解析, 然后保存到Mongo.

### 注意
1. 编码问题(demo使用的 Python2.7)

## 代码
```Python
import urllib2
import json
from pymongo import MongoClient
from urllib import quote_plus

uri = "mongodb://%s:%s@%s" % (quote_plus('root'), quote_plus('aa'), 'aa')
dbClient  = MongoClient(uri)
dbname = "national"
db = dbClient[dbname]
coll_point = db["pointInfo"]

def transAmap(point):
    cityInfoAmap = {}
    try:
        url = (u'http://restapi.amap.com/v3/geocode/geo?key=7bb32daa7da4c202280232aeb5606cf9&s=rsv3&address=' + point.decode("utf-8")).encode("utf-8")
        request = urllib2.Request(url)
        body = urllib2.urlopen(request).read()
        cityInfoAmap = json.loads(body)
        cityInfoAmap = cityInfoAmap["geocodes"][0]
        cityInfo = {}
        cityInfo["province"] = cityInfoAmap["province"]
        cityInfo["city"] = cityInfoAmap["city"]
        cityInfo["district"] = cityInfoAmap["district"]
        cityInfo["point"] = cityInfoAmap["formatted_address"]
        cityInfo["alias"] = [point]
        location = cityInfoAmap["location"].split(",")
        cityInfo["lon"] = location[0]
        cityInfo["lat"] = location[1]
        coll_point.insert(cityInfo)
    except BaseException,e :
        print point.decode("utf-8")+ " Not insert Mongo: "+repr(e)


if __name__=="__main__":
    for line in open('./points.txt','r'):
        line = line[:-2]
        transAmap(line)
```