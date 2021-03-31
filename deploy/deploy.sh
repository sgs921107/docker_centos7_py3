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
WORKDIR=/home/sgs/work/spiderPy3
LOGDIR=/var/log/spiderPy3
IMAGE=centos7-py3
CONTAINER=spiderPy3
RESERVED_PORT=8000

# ==========================配置结束==================================

# 声明变量
install_docker_script=./install_docker.sh
dockerfile=./Dockerfile

sh $install_docker_script || { echo "部署失败: 安装docker失败,请检查是否缺少依赖并重新运行部署脚本"; exit 1; }

echo "COMPOSE_PROJECT_NAME=centos7_py3
WORKDIR=$WORKDIR
LOGDIR=$LOGDIR
IMAGE=$IMAGE
CONTAINER=$CONTAINER
RESERVED_PORT=$RESERVED_PORT" > .env

docker-compose build || { echo '部署失败: 创建镜像失败,请重新运行部署脚本'; exit 1; }
# 删除产生的<none>镜像
# docker rmi $(docker images | grep '<none>' | awk '{print $3}')


# 如果部署成功,添加快捷命令
if docker-compose up -d;
then
    echo "deploy succeed"
    echo "you can add a alias cmd to your bashrc file and then source this file"
    echo "for example: echo \"alias $CONTAINER='docker exec -it $CONTAINER /bin/bash'\" >> ~/.bashrc && source ~/.bashrc"
else
    echo "deploy failed!!!"
fi
