#!/bin/bash
#clsn

#设置解析
echo '10.0.0.1 mirrors.aliyuncs.com mirrors.aliyun.com repo.zabbix.com' >> /etc/hosts

#安装zabbix源、aliyu nYUM源
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm

#安装zabbix客户端
yum install zabbix-agent -y
sed -i.ori 's#Server=127.0.0.1#Server=172.16.1.61#' /etc/zabbix/zabbix_agentd.conf
systemctl start  zabbix-agent.service

#写入开机自启动
chmod +x /etc/rc.d/rc.local
cat >>/etc/rc.d/rc.local<<EOF
systemctl start  zabbix-agent.service
EOF