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

echo "====================== begin deploy ========================="

# -----------------------------------------------------------------
# 宿主机的env配置文件所在的目录
HOST_ENV_PATH=/etc/centos7_py3/.env

source $HOST_ENV_PATH

# 部署目录
DEPLOY_DIR=$HOST_PROJECT_DIR/deploy
# docker-compose配置文件
COMPOSE_ENV_PATH=$DEPLOY_DIR/.env
# 安装docker的脚本
DOCKER_INSTALLER=install_docker.sh

# -------------------------------- 开始部署 --------------------------

# 进入部署目录
cd $DEPLOY_DIR || { echo "部署失败: 进入项目部署目录失败, 请校验您的分支是否正确"; exit 1; }

# 检查是否已安装docker服务
sh $DOCKER_INSTALLER || { echo "部署失败: 安装docker服务失败,请检查是否缺少依赖并重新运行部署脚本"; exit 1; }

# 将项目env配置链接至deploy/.env
ln -f $HOST_ENV_PATH $COMPOSE_ENV_PATH

# 构建镜像
docker-compose build || { echo '部署失败: 创建镜像失败,请重新运行部署脚本'; exit 1; }

# 删除产生的<none>镜像
none_imgs=$(docker images | grep '<none>' | awk '{print $3}')
if [ "$none_imgs" != "" ]
then
    docker rmi $none_imgs
fi

# 如果部署成功,添加快捷命令
if docker-compose up -d;
then
    echo "deploy succeed"
    echo "you can add a alias cmd to your bashrc file and then source this file"
    echo "for example: echo \"alias $COMPOSE_CONTAINER='docker exec -it $COMPOSE_CONTAINER /bin/bash'\" >> ~/.bashrc && source ~/.bashrc"
else
    echo "deploy failed!!!"
fi
