#!/bin/bash
if [ ! -e /install_done ]; then
    if [ ! -e /site/manage.py ]; then
    cp -r --preserve=all /osite/site /
    mycli -h db -u root -p dmoj --execute="CREATE DATABASE dmoj DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
    python3 manage.py migrate
    python3 manage.py loaddata navbar
    python3 manage.py loaddata language_small
    # The next line is optional
    #python manage.py loaddata demo
    fi
    touch /install_done
fi
service nginx start
service supervisor start
tail -F /tmp/site.stderr.log
