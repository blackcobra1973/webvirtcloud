#!/bin/sh
# `/sbin/setuser www-data` runs the given command as the user `www-data`.
cd /opt/webvirtcloud
exec /sbin/setuser www-data /opt/webvirtcloud/venv/bin/gunicorn webvirtcloud.wsgi:application -c /opt/webvirtcloud/gunicorn.conf.py >> /var/log/webvirtcloud.log 2>&1
