#!/bin/bash
if [ -e /osite/mysql ]; then
   cp -r --preserve=all /osite/mysql /var/lib
fi
if [ -e /osite/site ]; then
   cp -r --preserve=all /osite/site /
fi
service mysql start
service nginx start
service supervisor start
tail -F /tmp/site.stderr.log
