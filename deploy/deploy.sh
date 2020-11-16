#########################################################################
# File Name: deploy.sh
# Author: qiezi
# mail: qiezi@gmail.com
# Created Time: Wed 19 Feb 2020 12:29:13 PM CST
#########################################################################
#!/bin/bash

# ===================run the script with root user=================================
# ==========================开始配置==================================

# 1.docker-compose.yml依赖配置
WORKDIR=/home/sgs/work
LOGDIR=/var/logs/work
IMAGE=centos7-py3
CONTAINER=work

# ==========================配置结束==================================

# 声明变量
install_docker_script=./install_docker.sh
dockerfile=./Dockerfile

sh $install_docker_script || { echo "部署失败: 安装docker失败,请检查是否缺少依赖并重新运行部署脚本"; exit 1; }

echo "WORKDIR=$WORKDIR
LOGDIR=$LOGDIR
IMAGE=$IMAGE
CONTAINER=$CONTAINER
" > .env

docker-compose build || { echo '部署失败: 创建镜像失败,请重新运行部署脚本'; exit 1; }


# 如果部署成功,添加快捷命令
if docker-compose up -d;
then
    echo "deploy succeed"
    echo "you can add a alias cmd to your bashrc file and then source this file"
    echo "for example: echo \"alias work='docker exec -it work /bin/bash'\" >> /etc/bashrc && source /etc/bashrc"
else
    echo "deploy failed!!!"
fi
