# 数学函数收集

<!-- TOC -->

- [数学函数收集](#数学函数收集)
    - [高斯函数](#高斯函数)

<!-- /TOC -->

## 高斯函数
    ````
    // x代表坐标,自变量.
    // o 代表尺度参数,决定分布的幅度.值越大越平缓(必须>0,建议小于3,否则太过平缓)
    // u 代表位置参数,决定分布的位置.值与最高点的坐标有关
    // scale 约等于 峰值人数/峰值比率, 即 scale*峰值概率 = 峰值人数
    public static double gaussian(double x,double o,double u,double scale)
    {
        double coeff1 = (float)1/(Math.sqrt(2.0 * (float)Math.PI)*o);
        double coeff2 = -1/(2*Math.pow(o,2));
        double coeff3 =  Math.pow(Math.E, coeff2* Math.pow(x-u, 2));
        return coeff1*coeff3*scale;
    }
    ````