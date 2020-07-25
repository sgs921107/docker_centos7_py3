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
LOGDIR=./logs
IMAGE=centos7-py3
CONTAINER=work

# 2.是否指定pip的下载源 不指定置为空
# pip_repository=
pip_repository=https://pypi.tuna.tsinghua.edu.cn/simple

# 给用户添加work命令,快捷进入开发环境  /home/$user/.bashrc
bashrc=/etc/bashrc

# ==========================配置结束==================================

# 声明变量
install_docker_script=./install_docker.sh
dockerfile=./Dockerfile

# 检查/安装docker和docker-compose
if [ -n "$pip_repository" ]
then
    sed -i "s#pip install#pip install -i $pip_repository#g" $install_docker_script
fi
sh $install_docker_script
if [ -n "$pip_repository" ]
then
    git checkout $install_docker_script
fi

echo "WORKDIR=$WORKDIR
LOGDIR=$LOGDIR
IMAGE=$IMAGE
CONTAINER=$CONTAINER
" > .env

# 启动服务
if [ -n "$pip_repository" ]
then
    sed -i "s#pip install#pip install -i $pip_repository#g" $dockerfile
    sed -i "s#pip2 install#pip2 install -i $pip_repository#g" $dockerfile
fi
docker-compose up -d
if [ -n "$pip_repository" ]
then
    git checkout $dockerfile
fi

# 追加进入开发环境的快捷方式
echo "alias work='docker exec -it work /bin/bash'" >> $bashrc
source $bashrc
