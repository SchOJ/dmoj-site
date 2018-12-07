FROM debian:jessie

# DMOJ Site Dockerfile
# If you are using external judgers, UNCOMMENT last two lines.

RUN mkdir /site /uwsgi

ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y nano debconf-utils libmysqlclient-dev gnupg wget git gcc g++ make python-dev libxml2-dev libxslt1-dev zlib1g-dev gettext curl wget openssl vim supervisor uwsgi uwsgi-plugin-python
RUN echo 'deb http://mirrors.ustc.edu.cn/nodesource/deb/node_8.x stretch main' >> /etc/apt/sources.list && \
    echo 'deb http://nginx.org/packages/debian/ jessie nginx' >> /etc/apt/sources.list && \
    echo 'deb http://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-10.3.10/repo/debian/ jessie main' >> /etc/apt/sources.list && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com 0x1655a0ab68576280 && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com 0xcbcb082a1bb943db && \
    wget -qO - https://nginx.org/keys/nginx_signing.key | apt-key add - && \
    apt-get update && apt-get install -y nodejs mariadb-server mariadb-client nginx
RUN wget -q --no-check-certificate -O- https://bootstrap.pypa.io/get-pip.py | python
RUN npm install -g sass pleeease-cli --registry=https://registry.npm.taobao.org --unsafe-perm && \
    apt-get clean

RUN git clone https://github.com/schoj/site.git /site

WORKDIR /site
RUN git submodule init && \
    git submodule update
RUN pip install -r requirements.txt && \
    pip install mysqlclient django_select2 websocket-client && \
    npm install qu ws simplesets

COPY local_settings.py /site/dmoj

WORKDIR /site
RUN sh make_style.sh && \
    echo yes | python manage.py collectstatic && \
    python manage.py compilemessages && \
    python manage.py compilejsi18n

RUN mkdir /osite && \
    mv /var/lib/mysql /osite && \
    mv /site /osite

COPY uwsgi.ini /uwsgi
COPY site.conf bridged.conf wsevent.conf /etc/supervisor/conf.d/
COPY config.js /site/websocket

RUN rm /etc/nginx/sites-enabled/*
ADD nginx.conf /etc/nginx/sites-enabled
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
