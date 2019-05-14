#!/bin/sh
# function:自动监控tomcat进程，挂了就执行重启操作
# author:anker
# DEFINE
#set -vx
# 获取tomcat PPID
TomcatID=`ps -ef |grep tomcat |grep -w 'hopdeploy'|grep -v 'grep'|awk '{print $2}'`
OKCODE=200
# tomcat_startup
StartTomcat=/home/hopdeploy/tomcat/bin/startup.sh

# 定义要监控的页面地址
WebUrl=http://10.138.8.204:33333

# 获取返回状态码
TomcatServiceCode=`curl -s -i -X  GET --head -m 3 $WebUrl |awk 'NR==1{print $2}'`

# 日志输出
GetPageInfo=/dev/null
TomcatMonitorLog=/home/hopdeploy/script/TomcatMonitor.log

Monitor()
{
  echo "[info]开始监控tomcat...[$(date +'%F %H:%M:%S')]"
#  if [ $TomcatID ];then
#    echo "[info]tomcat进程ID为:$TomcatID."
#  else
#    echo "[error]进程不存在!tomcat自动重启..."
#    echo "[info]$StartTomcat,请稍候......"
#    echo "请尽快验证可用性" | mail -s "服务出现重启" 389554843@qq.com
#    #rm -rf $TomcatCache
#    $StartTomcat
#  fi

  if [ "$TomcatServiceCode" -eq "$OKCODE" ];then
        echo "[info]返回码为$TomcatServiceCode,tomcat启动成功,页面正常."
    elif [ $TomcatID ]; then
      #statements
        echo "[error]访问出错，状态码为$TomcatServiceCode,错误日志已输出到$GetPageInfo"        
        echo "[error]开始重启tomcat"
        kill -9 $TomcatID  # 杀掉原tomcat进程
        sleep 3
        echo "请尽快验证可用性" | mail -s "服务出现重启" 389554843@qq.com
        $StartTomcat
    else 
        echo "[error]进程不存在!tomcat自动重启..."
        echo "请尽快验证可用性" | mail -s "服务出现重启" 389554843@qq.com
        $StartTomcat  
    fi
    echo "------------------------------"
}

Monitor >>$TomcatMonitorLog
