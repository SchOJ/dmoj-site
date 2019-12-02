#!/bin/bash
if [ ! -e /install_done ]; then
    if [ -e /osite/site ]; then
    cp -r --preserve=all /osite/site /
    fi
fi
if [ ! -e /install_done ]; then
    mysql -h db -u root -p dmoj --execute="CREATE DATABASE dmoj DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
    python3 manage.py migrate
    python3 manage.py loaddata navbar
    python3 manage.py loaddata language_small
    # The next line is optional
    #python manage.py loaddata demo
touch /install_done
fi
service nginx start
service supervisor start
tail -F /tmp/site.stderr.log
