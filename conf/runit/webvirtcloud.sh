#!/bin/sh
# `/sbin/setuser nginx` runs the given command as the user `nginx`.
cd /opt/webvirtcloud
exec /sbin/setuser nginx /opt/webvirtcloud/venv/bin/gunicorn webvirtcloud.wsgi:application -c /opt/webvirtcloud/gunicorn.conf.py >> /var/log/webvirtcloud.log 2>&1
