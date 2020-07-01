#!/bin/bash
yum update -y
#安装docker
amazon-linux-extras install docker
systemctl start docker
systemctl enable docker

#安装python和git
yum groupinstall -y "Development Tools"
yum install -y python3-devel
yum install -y python3 git


# git 克隆
cd /
git clone https://github.com/johnlee888888/aws.git


# 安装python 模块
pip3 install boto3
pip3 install flask
pip3 install requests
pip3 install virtualenv


# 设置aws的region
mkdir ~/.aws/
echo '[default]' > ~/.aws/config
echo 'region=ap-south-1' >> ~/.aws/config



# 安装与配置uwsgi
yum python-virtualenv
cp /aws/myweb.service /etc/systemd/system/myweb.service
cp -rp /aws /home/ec2-user/
cd /home/ec2-user
chmod 775 aws && chown ec2-user aws
cd aws
chmod 775 * && chown ec2-user:ec2-user *
chmod 775 aws/* && chown ec2-user:ec2-user aws/*
chmod 775 templates/* && chown ec2-user:ec2-user templates/*

virtualenv aws -p python3
source aws/bin/activate
pip3 install boto3
pip3 install flask
pip3 install requests
pip3 install virtualenv
pip3 install uwsgi
deactivate
systemctl start myweb.service
systemctl enable myweb.service

#uwsgi --socket 0.0.0.0:8000 --protocol=http -w wsgi


# 使用python脚本创建数据库表
python3 /aws/insert_db_1_create_table.py
# 使用python脚本向数据库接入数据
python3 /aws/insert_db_2_insert.py
# 使用python脚本上传静态文件(图片)到webapp-aws[名字有严格要求,需要提前创建]的s3存储
python3 /aws/upload_files.py

# 安装与配置NGINX
amazon-linux-extras install nginx1.12
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
cp /aws/nginx.conf /etc/nginx/nginx.conf
systemctl start nginx
systemctl enable nginx