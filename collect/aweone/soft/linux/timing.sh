#!/bin/bash
# 定时器脚本, 定时提醒放松下
function timing_fun(){
    sleep $1
    zenity --question --width=150 --height=50 --ok-label "完成" --cancel-label "延迟十分钟" --text "$2" --title "时间到啦"
    if [ $? = 1 ]; then
        timing_fun 600 $2
        exit 0
    fi
}

timing_fun $1 $2 &

# 在.bashrc 下添加如下别名, 别忘了修改路径
# alias timing='/home/wzs/.bin/timing.sh $1 $2 >/dev/null 2>&1'
# alias timing1='/home/wzs/.bin/timing.sh 1800 时间到啦 >/dev/null 2>&1'
