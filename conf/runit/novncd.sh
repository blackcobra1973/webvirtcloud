#!/bin/sh
# `/sbin/setuser www-data` runs the given command as the user `www-data`.
cd /opt/webvirtcloud
exec /sbin/setuser www-data /opt/webvirtcloud/venv/bin/python /opt/webvirtcloud/console/novncd >> /var/log/novncd.log 2>&1
