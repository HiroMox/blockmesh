#!/bin/bash

# 检测Docker是否已安装
if ! command -v docker &> /dev/null; then
    echo "Docker未安装，正在安装Docker..."
    sudo apt update
    wget https://get.docker.com/ -O docker.sh
    sudo sh docker.sh
    rm docker.sh
else
    echo "Docker已安装，跳过安装步骤。"
fi

# 询问用户是否来自中国大陆地区
read -p "是否为中国大陆地区服务器，是请输入y，不是请直接按回车或输入n：" region

if [ "$region" == "y" ]; then
    echo "配置Docker镜像源..."
    sudo mkdir -p /etc/docker
    echo '{
"registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://noohub.ru",
    "https://huecker.io",
    "https://dockerhub.timeweb.cloud",
    "https://docker.rainbond.cc"
]
}' | sudo tee /etc/docker/daemon.json
    sudo systemctl restart docker
else
    echo "跳过Docker镜像源配置。"
fi

# 创建docker-compose.yml文件
mkdir -p blockmesh-node
cd blockmesh-node

touch docker-compose.yml

# 收集用户信息
read -p "您账号的邮箱地址：" email
read -p "您账号的密码：" password

read -p "是否需要配置代理，输入y为需要，n为不需要，按回车默认不需要：" proxy_enable
proxy_enable=${proxy_enable:-n}  # 默认值为n

if [ "$proxy_enable" == "y" ]; then
    proxy_enable_value=true
    read -p "请设置你的代理地址(http(s)://host:port)：" proxy_host
    read -p "请填写代理用户名：" proxy_user
    read -p "请填写代理密码：" proxy_pass
else
    proxy_enable_value=false
    proxy_host=""
    proxy_user=""
    proxy_pass=""
fi

# 写入docker-compose.yml
cat <<EOF > docker-compose.yml
version: '1'
services:
   blockmesh:
      image: aron666/blockmesh
      environment:
         - BM_EMAIL=$email
         - BM_PASS=$password
         - ADMIN_USER=admin
         - ADMIN_PASS=admin
         - PROXY_ENABLE=$proxy_enable_value
         - PROXY_HOST=$proxy_host
         - PROXY_USER=$proxy_user
         - PROXY_PASS=$proxy_pass
      ports:
         - 5004:50004
EOF

# 启动Docker Compose
sudo docker compose up -d

echo "安装和配置完成！程序已启动。"
