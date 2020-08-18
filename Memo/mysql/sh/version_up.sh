#! /bin/sh
# OS     : CentOS/7  ★ssh user=centos
# MySQL  : 8.0
# Zabbix : 5.0
# PHP    : 7.3
# DB_data: Local PC sql_file -> Restore (※From: MySQL_ver5.7, Zabbix_ver4.2, PHP_ver5.4)



# [Before]
# ------------------------------------------------------------------------------------------
# sudo yum update -y
# sudo sed -i 's/^SELINUX.*/SELINUX=disable/' /etc/selinux/config
# sudo reboot



# [MySQL8.0] 
# mysql-comunity-server, mysql-comunity-devel
# ------------------------------------------------------------------------------------------
# From local PC ※
# scp -i ~/.ssh/miyake-key.pem ~/mysql_dump_zabbix_20200817.sql ec2-user@<IP>:/home/ec2-user/

# Repo & package install
sudo rpm -ivh https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
sudo yum -y install mysql-community-server mysql-community-devel

# #default-authentication-plugin=mysql_native_password -> comment in (ver5.7 認証形式)
sudo sed -i '/^#.*mysql_native.*/s/^# //' /etc/my.cnf

# checked shell script till this line

# Starting Setting
sudo systemctl start mysqld
sudo systemctl enable mysqld                           # something wrong: cant't start mysqld

# set env tmp_Password
TMP_PASSWORD=$(sudo cat /var/log/mysqld.log | grep 'temporary password' | sed -e 's/^.*localhost://' | sed 's/ //g')
# sudo cat /var/log/mysqld.log | grep 'temporary password' | sed -e 's/^.*localhost://' | sed 's/ //g' > TMP_PASSWORD (not_check_yet)

# mysql_secure_installation
mysqladmin -p$(TMP_PASSWORD) password $(TMP_PASSWORD)
yes | mysql_secure_installation -p$(TMP_PASSWORD) -D
# mysql -u root -p$(TMP_PASSWORD)
# UPDATE mysql.user SET Password=PASSWORD('$(TMP_PASSWORD)') WHERE User='root';
# DELETE FROM mysql.user WHERE User='';
# DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
# DROP DATABASE IF EXISTS test;
# DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
# FLUSH PRIVILEGES;


# set Password (diff validate_query from 5.7)
mysql -u root -p$(TMP_PASSWORD)
SET GLOBAL validate_password.length = 4;
SET GLOBAL validate_password.policy = LOW;
SET GLOBAL validate_password.check_user_name = OFF;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
#--------------------------
# user     root
# password root
#--------------------------

# Create zabbix user
create database zabbix character set utf8 collate utf8_bin;
create user 'zabbix'@'%' identified by 'password';
grant all on zabbix.* to 'zabbix'@'%';
flush privileges;
quit;
#--------------------------
# user     zabbix
# password password
#--------------------------

# Restore DB
mysql -u zabbix -p -D zabbix < ./mysql_dump_zabbix_20200817.sql



# [Zabbix5.0]
# zabbix-server-mysql, zabbix-agent
# ------------------------------------------------------------------------------------------
# Repo & Package install
sudo yum install -y https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
sudo yum install -y zabbix-server-mysql zabbix-agent

# /etc/zabbix/zabbix_server.conf/
# default ↓            # change
# # DBHost=localhost
# DBName=zabbix
# DBUser=zabbix
# # DBPassword=        # DBPassword=password
sudo sed -i '/#DBPassword=/a DBPassword=password' /etc/zabbix/zabbix_server.conf


# /etc/yum.repos.d/zabbix.repo/
# [zabbix-frontend]
# enabled=1
sudo sed -i '11 s/enable.*/enable=1/g' /etc/yum.repos.d/zabbix.repo



# [PHP7.3]    ★ A lot of dependency!!!
# zabbix-web, zabbix-web-deps-scl, zabbix-web-mysql-scl, zabbix-apache-conf-scl, zabbix-web-japanese
# ------------------------------------------------------------------------------------------
# SCL & Package install
sudo yum install -y centos-release-scl
sudo yum install -y zabbix-web zabbix-web-deps-scl zabbix-web-mysql-scl zabbix-apache-conf-scl zabbix-web-japanese

# /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf/
# php_value[date.timezone] = Asia/Tokyo
sudo sed -i 's/#.*timezone.*/php_value[date.timezone] = Asia\/Tokyo' /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf

# Starting Setting
systemctl start zabbix-agent zabbix-server rh-php72-php-fpm httpd
systemctl enable zabbix-agent zabbix-server rh-php72-php-fpm httpd



# ------------------------------------------------------------------------------------------
# Zabbix web Alert!!!
# Zabbix server	/etc/passwd has been changed on Zabbix server	
# Zabbix server	Host information was changed on Zabbix server	
# Zabbix server	Hostname was changed on Zabbix server
# Zabbix server	Version of Zabbix agent was changed on Zabbix server

# Ref
# EC2 centos            (https://dev.classmethod.jp/articles/centos7-initial-settings/)
# zbx5 flontend install (https://www.zabbix.com/documentation/current/manual/installation/install_from_packages/frontend_on_rhel7)
# zbx5 centos7 ★       (https://qiita.com/atanaka7/items/429d7a3151542420c944)
# MySQL secure_insta    (https://qiita.com/MasahitoShinoda/items/9c2d895084b222ac816a)
# MySQL secure_insta2   (https://github.com/qryuu/aws_on_zabbix/blob/master/UserData/Launch-ZabbixServer-on-AmazonLinux.sh)