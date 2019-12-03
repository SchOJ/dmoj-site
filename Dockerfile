FROM debian:buster

# DMOJ Site Dockerfile
# If you are using external judgers, UNCOMMENT last two lines.

RUN mkdir /site /uwsgi

ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y nano debconf-utils default-libmysqlclient-dev gnupg wget git gcc g++ make python-dev libxml2-dev libxslt1-dev zlib1g-dev gettext curl wget openssl vim supervisor mycli
RUN echo 'deb http://mirrors.ustc.edu.cn/nodesource/deb/node_12.x buster main' >> /etc/apt/sources.list && \
    echo 'deb http://nginx.org/packages/debian/ buster nginx' >> /etc/apt/sources.list && \
    wget -qO - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    wget -qO - https://nginx.org/keys/nginx_signing.key | apt-key add - && \
    apt-get update && apt-get install -y nodejs nginx
RUN apt-get install -y python3-pip && \
    npm install -g cnpm --registry=http://registry.npm.taobao.org
RUN cnpm install -g sass postcss-cli autoprefixer && \
    apt-get clean

RUN git clone https://github.com/dmoj/online-judge.git /site --depth=1

WORKDIR /site
RUN git submodule init && \
    git config -f .gitmodules submodule.resources/libs.shallow true && \
    git config -f .gitmodules submodule.resources/pagedown.shallow true && \
    git submodule update
RUN pip3 install -r requirements.txt
RUN pip3 install mysqlclient django_select2 websocket-client pymysql uWSGI
RUN cnpm install qu ws simplesets
COPY local_settings.py /site/dmoj

WORKDIR /site
RUN ./make_style.sh && \
    echo yes | python3 manage.py collectstatic && \
    python3 manage.py compilemessages && \
    python3 manage.py compilejsi18n

RUN mkdir /osite && \
    mv /site /osite

COPY uwsgi.ini /uwsgi
COPY site.conf bridged.conf wsevent.conf /etc/supervisor/conf.d/
COPY config.js /site/websocket

RUN rm /etc/nginx/conf.d/*
ADD nginx.conf /etc/nginx/conf.d
ADD start.sh /

ENTRYPOINT /bin/sh /start.sh

EXPOSE 80
# Comment next line if you do not use SSL/TLS.
EXPOSE 443 
EXPOSE 15100
EXPOSE 15101
EXPOSE 15102
# Uncomment below if you need judge from external judgers.
#EXPOSE 9998
#EXPOSE 9999
