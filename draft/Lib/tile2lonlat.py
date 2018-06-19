# coding:utf-8
"""
参考: http://cntchen.github.io/2016/05/09/国内主要地图瓦片坐标系定义及计算原理/
根据切片XY和像素值获取对应的经纬度坐标
"""
import math
import numpy

def tile2lonlat(zoom, tileX, tileY,pixelX_min, pixelX_max, pixelY_min, pixelY_max):
    """
        根据 切片xy值获取坐标
        像素点与经纬度关系（像素值为256*256）
            像素点值越大, 经度(lon) 越大，维度(lat) 越小
    """
    lng_min = (tileX + pixelX_min/256)/math.pow(2,zoom)*360 - 180
    lng_max = (tileX + pixelX_max/256)/math.pow(2,zoom)*360 - 180
    temp_min = math.sinh(math.pi * (1- ((tileY + (pixelY_max/256))/math.pow(2,zoom-1))))
    lat_min = numpy.arctan(temp_min)*180/math.pi
    temp_max = math.sinh(math.pi* (1- ((tileY + (pixelY_min/256))/math.pow(2,zoom-1))))
    lat_max = numpy.arctan(temp_max)*180/math.pi
    result = {
        "leftBottom":{"lon":lng_min,"lat":lat_min},
        "rightTop":{"lon":lng_max,"lat":lat_max}
    }
    return result

def tile2lonlat_max_min(zoom, tileX, tileY):
    """
        根据 切片xy值 获取坐标的最大最小值 
    """
    lng_min = tileX/math.pow(2,zoom)*360-180
    lng_max = (tileX+1)/math.pow(2,zoom)*360-180
    temp_min = math.sinh(math.pi* (1- ((tileY-1)/math.pow(2,zoom-1))))
    lat_min = numpy.arctan(temp_min)*180/math.pi
    temp_max = math.sinh(math.pi* (1- ((tileY)/math.pow(2,zoom-1))))
    lat_max = numpy.arctan(temp_max)*180/math.pi
    result = {
        "leftBottom":{"lon":lng_min,"lat":lat_min},
        "rightTop":{"lon":lng_max,"lat":lat_max}
    }
    return result

# def lonlat2tile(zoom = 17, lng_deg=109, lat_deg=34):
#     """
#         根据经纬度获取切片xy值
#     """
#     n = math.pow(2, int(zoom))
#     xtile = ((lng_deg + 180) / 360) * n
#     lat_rad = lat_deg * math.pi/180
#     fenzi = math.log(math.tan(lat_rad) + 1 / math.cos(lat_rad))
#     ytile = (1.0 - ( fenzi/(math.pi*2) ) ) * n
#     return {"tileX":int(xtile), "tileY":int(ytile)}

def lonlat2tile(zoom = 17, lng_deg=109, lat_deg=34):
    """
        根据经纬度获取切片xy值
    """
    n = math.pow(2, int(zoom))
    xtile = ((lng_deg + 180) / 360) * n
    lat_rad = math.sin(lat_deg * math.pi/180)
    ytile = (2.0 - ( math.log((1+lat_rad)/(1-lat_rad))/math.pi ) ) * n/4
    return {"tileX":int(xtile), "tileY":int(ytile)}

if __name__=="__main__":
    lon = 116.3977300859833
    lat = 39.91371035156561
    tile = lonlat2tile(zoom=17,lng_deg=lon,lat_deg=lat)
    print tile
    print tile2lonlat_max_min(17,tile.get("tileX"),tile.get("tileY"))
