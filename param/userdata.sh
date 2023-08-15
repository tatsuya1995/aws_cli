#!/bin/bash

# Variables
AWS_AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone) && echo $AWS_AVAIL_ZONE
AWS_REGION=$(echo "$AWS_AVAIL_ZONE" | sed 's/[a-z]$//') && echo $AWS_REGION
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) && echo $INSTANCE_ID
EC2_NAME=$(aws ec2 describe-instances --region $AWS_REGION --instance-id $INSTANCE_ID \
  --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value' --output text) && echo $EC2_NAME

# Apachのインストールと起動
sudo yum install httpd -y
sudo systemctl start httpd.service
sudo systemctl enable httpd.service

# Install nginx if not installed
nginx -v
if [ "$?" -ne 0 ]; then
  sudo amazon-linux-extras install -y nginx1
  sudo systemctl enable nginx
  sudo systemctl start nginx
fi

# Install mysql client if not installed
mysql --version
if [ "$?" -ne 0 ]; then
  # delete mariadb
  yum list installed | grep mariadb
  sudo yum remove mariadb-libs -y

  # import GnuPG key and upgrade package
  sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
  sudo rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm

  # disable mysql5.7 repo and enable mysql8.0 repo
  sudo yum-config-manager --disable mysql57-community
  sudo yum-config-manager --enable mysql80-community

  # install mysql client
  sudo yum install -y mysql-community-client
fi

  # php8.0を有効化
  $ sudo amazon-linux-extras enable php8.0

  # php8.0をインストール
  $ sudo amazon-linux-extras install -y php8.0

  # laravelで必要なモジュールをインストール
  $ sudo yum install -y php-cli php-pdo php-fpm php-mysqlnd php-mbstring php-xml php-bcmath

  # metadataを削除
  $ yum clean metadata

  # 自動起動設定
  sudo systemctl enable php-fpm

  sudo curl -sS https://getcomposer.org/installer | php　# コンポーザーのインストール
  sudo chown root:root composer.phar 
  sudo mv composer.phar /usr/bin/composer # パスを通す
  composer # インストールされたか確認

  # install git 
  sudo yum install -y git

# Create index.html
echo "<h1>${EC2_NAME}</h1>" >index.html
sudo mv ./index.html /usr/share/nginx/html/
