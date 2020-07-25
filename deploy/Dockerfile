##############################################
# 基于centos7、python3构建scrapy、scrapyd运行环境
# 构建命令: 在Dockerfile文件目录下执行 docker build -t centos7-python3-scrapyd .
# 容器启动命令: docker run -dit --name scrapyd --restart=always --privileged=true centos7-py3-scrapyd
# 进入容器：docker exec -it scrapyd /bin/bash
##############################################
FROM centos:7.6.1810
MAINTAINER sgs # 指定作者信息
RUN set -ex \
    # 预安装所需组件
    && yum install -y wget tar unzip libffi-devel zlib-devel bzip2-devel openssl-devel ncurses-devel \
    sqlite-devel readline-devel tk-devel gcc make initscripts vim cronie lrzsz rsyslog \
    # && wget https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tgz \
    && wget https://mirrors.huaweicloud.com/python/3.7.4/Python-3.7.4.tgz \
    && tar -zxvf Python-3.7.4.tgz \
    && cd Python-3.7.4 \
    && ./configure prefix=/usr/local/python3 \
    && make \
    && make install \
    && make clean \
    && rm -rf /Python-3.7.4* \
    && yum install -y epel-release \
    && yum install -y python-pip \
    && yum clean all && rm -rf /var/cache/yum/* && rm -rf /tmp/*
 
# 基础环境配置
RUN set -ex \
    # 修改系统时区为东八区
    && rm -rf /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
 
# 支持中文
RUN set -ex \
    &&yum install -y kde-l10n-Chinese python-devel libevent-devel \
    && yum clean all && rm -rf /var/cache/yum/* && rm -rf /tmp/*
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8
ENV LC_ALL zh_CN.UTF-8

# 配置rsyslog 配置当未使用所有权限启动容器时仍可以收集日志
RUN set -ex \
    && mv /etc/rsyslog.d/listen.conf /etc/rsyslog.d/listen.conf.backup \
    && sed -i 's/^$ModLoad imjournal/# $ModLoad imjournal/' /etc/rsyslog.conf \
    && sed -i 's/^$OmitLocalLogging on/$OmitLocalLogging off/' /etc/rsyslog.conf \
    && sed -i 's/^$IMJournalStateFile imjournal.state/# $IMJournalStateFile imjournal.state/' /etc/rsyslog.conf
 
# 设置默认为python3
RUN set -ex \
    # 删除旧版本python环境变量
    && rm -f /usr/bin/python \
    && rm -f /usr/bin/pip \
    # 配置默认为python3
    && ln -s /usr/local/python3/bin/python3.7 /usr/bin/python \
    && ln -s /usr/local/python3/bin/pip3 /usr/bin/pip \
    && pip install --upgrade pip
 
# 修复因修改python版本导致yum失效问题
RUN set -ex \
    && sed -i "s#/usr/bin/python#/usr/bin/python2.7#" /usr/bin/yum \
    && sed -i "s#/usr/bin/python#/usr/bin/python2.7#" /usr/libexec/urlgrabber-ext-down \
    && yum install -y deltarpm \
    # 安装谷歌浏览器和chrome driver
    && yum install -y  https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm \
    && wget http://chromedriver.storage.googleapis.com/70.0.3538.16/chromedriver_linux64.zip \
    && unzip chromedriver_linux64.zip \
    && chmod +x chromedriver \
    && mv chromedriver /usr/local/bin/ \
    && rm -rf chromedriver_linux64.zip \
    && yum clean all && rm -rf /var/cache/yum/* && rm -rf /tmp/*
 
# 添加python3的环境变量
ENV PATH=$PATH:/usr/local/python3/bin
ADD ./requirements.txt /tmp/requirements.txt
 
# 安装python爬虫以来库
RUN pip --no-cache-dir install -r /tmp/requirements.txt \
    && pip2 --no-cache-dir install urwid speedometer
 
# 配置scrapyd
RUN sed -i "s/127.0.0.1/0.0.0.0/g" /usr/local/python3/lib/python3.7/site-packages/scrapyd/default_scrapyd.conf \
    && sed -i "s/max_proc_per_cpu = 4/max_proc_per_cpu = 30/g" /usr/local/python3/lib/python3.7/site-packages/scrapyd/default_scrapyd.conf
 
# 配置vim
RUN echo "alias vi=vim" >> /root/.bashrc
ADD ./vimrc /root/.vimrc
 
RUN mkdir /scrapyd_work
WORKDIR /scrapyd_work
 
EXPOSE 6800
 
CMD ["/bin/bash", "-c", "rsyslogd && crond && scrapyd"]

