#! /bin/sh

sudo yum update -y

# [MySQL5.7]
# ------------------------------------------------------------------------------------------
# From local PC ※
# scp -i ~/.ssh/miyake-key.pem ~/mysql_dump_zabbix_20200817.sql ec2-user@<IP>:/home/ec2-user/

sudo yum localinstall https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm -y
sudo yum-config-manager --disable mysql80-community
sudo yum-config-manager --enable mysql57-community
sudo yum install mysql-community-server -y
sudo systemctl start mysqld.service
sudo systemctl enable mysqld.service

# set env tmp_Password
TMP_PASSWORD="sudo cat /var/log/mysqld.log | grep 'temporary password' | sed -e 's/^.*localhost://' | sed 's/ //g'"

# set Password
mysql -u root -p$(TMP_PASSWORD)
SET GLOBAL validate_password_length=4;
SET GLOBAL validate_password_policy=LOW;
set password for root@localhost=password('root');

# Create zabbix user
create database zabbix character set utf8 collate utf8_bin;
create user 'zabbix'@'%' identified by 'password';
grant all on zabbix.* to 'zabbix'@'%';
flush privileges;
quit;

# Restore DB
mysql -u zabbix -p -D zabbix < ./mysql_dump_zabbix_20200817.sql


# [Zabbix]
# ------------------------------------------------------------------------------------------
sudo rpm -Uvh https://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-2.el7.noarch.rpm
sudo yum -y install zabbix-server-mysql zabbix-web-mysql zabbix-web-japanese zabbix-agent

# default [# DBHost=localhost] [DBName=zabbix] [DBUser=zabbix] [# DBPassword=]
# password=root
sudo sed -i '/#DBPassword=/a DBPassword=root' /etc/zabbix/zabbix_server.conf

# timezone=Tokyo
sudo sed -i '/;date.timezone =/a date.timezone = Asia/Tokyo' /etc/php.ini

sudo systemctl start httpd zabbix-server zabbix-agent
sudo systemctl enable httpd zabbix-server zabbix-agent
