#!/bin/bash

apt -y update 
yum -y install httpd
MYIP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2>Web Server with IP: $MYIP</h2><br><font color="red">Build by Terraform" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd

amazon-linux-extras enable php7.4
yum clean metadata
yum install php-cli php-pdo php-fpm php-json php-mysqlnd

rpm -Uvh https://repo.mysql.com/mysql80-community-release-el7-3.noarch.rpm
sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/mysql-community.repo
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
yum --enablerepo=mysql80-community install mysql-community-server -y
systemctl start mysqld
systemctl status mysqld

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install 18.0.0