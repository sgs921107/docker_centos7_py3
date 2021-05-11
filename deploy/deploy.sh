#########################################################################
# File Name: deploy.sh
# Author: qiezi
# mail: qiezi@gmail.com
# Created Time: Wed 19 Feb 2020 12:29:13 PM CST
#########################################################################
#!/bin/bash

# ===================run the script with root user=================================
# 1.根据conf/env_demo生成自己的.env配置文件/etc/centos7_py3/.env
# 2.部署: /bin/bash deploy.sh
# =================================================================================

source /etc/centos7_py3/.env
# 安装docker的脚本路径
install_docker_script=./install_docker.sh

sh $install_docker_script || { echo "部署失败: 安装docker失败,请检查是否缺少依赖并重新运行部署脚本"; exit 1; }

echo "COMPOSE_PROJECT_NAME=centos7_py3
WORKDIR=$WORKDIR
LOGDIR=$LOGDIR
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
