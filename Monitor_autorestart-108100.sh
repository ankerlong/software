#!/bin/sh
# function:自动监控dubbo进程，挂了就执行重启操作
# author:anker
# DEFINE
#set -vx

#邮件
content="请尽快确认重启结果,服务器IP：10.135.108.100 [$(date +'%F %H:%M:%S')]"
title="HAC1169-V2.1服务出现重启"
Email='389554843@qq.com,572512893@qq.com,690948092@qq.com'

#获取dubbo服务PID
DubboID=`ps aux |grep hac1169-service-impl-2.1.0-SNAPSHOT |grep -v grep|awk '{print $2}'`

OKCODE=200
# dubbo_start.sh
StartDubbo=/home/haieradmin/deploy/temp/hac1169-service-impl-2.1.0-SNAPSHOT/bin/start.sh

# 定义要监控的页面地址
WebUrl=http://10.135.108.100:1024/com.haier.openplatform.hac.service.HacUserServiceCli?wsdl

# 获取返回状态码
DubboServiceCode=`curl -s -i -X  GET --head -m 3 $WebUrl |awk 'NR==1{print $2}'`
# 日志输出
DubboMonitorLog=/home/haieradmin/script/DubboMonitor.log

Monitor()
{
  echo "[info]开始监控HAC1169-DubboV2.1...[$(date +'%F %H:%M:%S')]"

  if [ "$DubboServiceCode" -eq "$OKCODE" ];then
        echo "[info]返回码为$DubboServiceCode,Dubbo正常.PID:$DubboID"
    elif [ $TomcatID ]; then
      #statements
        echo "[error]访问出错，状态码为$DubboServiceCode"                
        echo "[error]开始重启Dubbo"
        kill -9 $DubboID  # 杀掉原Dubbo进程
        echo $content | mail -s $title $Email
        $StartDubbo
        sleep 3
    else 
        echo "[error]进程不存在!Dubbo自动重启..."
        echo "[info]$StartDubbo,请稍候......"
        echo $content | mail -s $title $Email
        $StartDubbo
        sleep 3  
    fi
    echo "------------------------------"
}

Monitor >>$DubboMonitorLog