#!/bin/bash
if [ ! -e /install_done ]; then
    if [ -e /osite/mysql ]; then
    cp -r --preserve=all /osite/mysql /var/lib
    fi
    if [ -e /osite/site ]; then
    cp -r --preserve=all /osite/site /
    fi
fi
service mysql start
if [ ! -e /install_done ]; then
    mysql -uroot --execute="CREATE DATABASE dmoj DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
    python manage.py migrate
    python manage.py loaddata navbar
    python manage.py loaddata language_small
    # The next line is optional
    #python manage.py loaddata demo
touch /install_done
fi
service nginx start
service supervisor start
tail -F /tmp/site.stderr.log
