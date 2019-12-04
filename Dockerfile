FROM debian:buster

# DMOJ Site Dockerfile
# If you are using external judgers, UNCOMMENT last two lines.

RUN mkdir /site /uwsgi

ENV DEBIAN_FRONTEND=noninteractive

RUN echo 'deb http://deb.nodesource.com/node_12.x buster main' >> /etc/apt/sources.list && \
    echo 'deb http://nginx.org/packages/debian/ buster nginx' >> /etc/apt/sources.list && \
    wget -qO - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    wget -qO - https://nginx.org/keys/nginx_signing.key | apt-key add - && \
    apt-get update && \
    apt-get install -y nano debconf-utils default-libmysqlclient-dev gnupg wget git gcc g++ make python-dev libxml2-dev libxslt1-dev zlib1g-dev gettext curl wget openssl vim supervisor mycli python3-pip nodejs nginx && \
    npm install -g sass postcss-cli autoprefixer && \
    apt-get clean && \
    git clone https://github.com/dmoj/online-judge.git /site --depth=1

WORKDIR /site
COPY local_settings.py /site/dmoj
RUN git submodule init && \
    git config -f .gitmodules submodule.resources/libs.shallow true && \
    git config -f .gitmodules submodule.resources/pagedown.shallow true && \
    git submodule update && \
    pip3 install -r requirements.txt && \
    pip3 install mysqlclient django_select2 websocket-client pymysql uWSGI && \
    npm install qu ws simplesets && \
    ./make_style.sh && \
    echo yes | python3 manage.py collectstatic && \
    python3 manage.py compilemessages && \
    python3 manage.py compilejsi18n && \
    mkdir /osite && \
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
