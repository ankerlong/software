#!/bin/bash
#clsn

#设置解析 注意：网络条件较好时，可以不用自建yum源
# echo '10.0.0.1 mirrors.aliyuncs.com mirrors.aliyun.com repo.zabbix.com' >> /etc/hosts

#安装zabbix源、aliyun YUM源
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm

#安装zabbix 
yum install -y zabbix-server-mysql zabbix-web-mysql

#安装启动 mariadb数据库
yum install -y  mariadb-server
systemctl start mariadb.service

#创建数据库
mysql -e 'create database zabbix character set utf8 collate utf8_bin;'
mysql -e 'grant all privileges on zabbix.* to zabbix@localhost identified by "zabbix";'

#导入数据
zcat /usr/share/doc/zabbix-server-mysql-3.0.13/create.sql.gz|mysql -uzabbix -pzabbix zabbix

#配置zabbixserver连接mysql
sed -i.ori '115a DBPassword=zabbix' /etc/zabbix/zabbix_server.conf

#添加时区
sed -i.ori '18a php_value date.timezone  Asia/Shanghai' /etc/httpd/conf.d/zabbix.conf

#解决中文乱码
yum -y install wqy-microhei-fonts
\cp /usr/share/fonts/wqy-microhei/wqy-microhei.ttc /usr/share/fonts/dejavu/DejaVuSans.ttf

#启动服务
systemctl start zabbix-server
systemctl start httpd

#写入开机自启动
chmod +x /etc/rc.d/rc.local
cat >>/etc/rc.d/rc.local<<EOF
systemctl start mariadb.service
systemctl start httpd
systemctl start zabbix-server
EOF

#输出信息
echo "浏览器访问 http://`hostname -I|awk '{print $1}'`/zabbix"