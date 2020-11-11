#!/bin/bash
if [ ! -e /site/install_done ]; then
    if [ ! -e /site/manage.py ]; then
        echo "firstrun: Extracting data"
        cp -r --preserve=all /osite/. /site
        chown -R dmoj:dmoj /site
    fi
    echo "firstrun: Creating database"
    mycli -h db -u root -p dmoj --execute="CREATE DATABASE dmoj DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_general_ci;"
    echo "firstrun: Migrating database"
    python3 manage.py migrate
    python3 manage.py loaddata navbar
    python3 manage.py loaddata language_small
    # The next line is optional
    #python manage.py loaddata demo
    echo "firstrun: Done"
    touch /site/install_done
fi
service nginx start
service supervisor start
tail -F /tmp/site.stderr.log
