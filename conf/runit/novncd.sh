#!/bin/sh
# `/sbin/setuser nginx` runs the given command as the user `nginx`.
cd /opt/webvirtcloud
exec /sbin/setuser nginx /opt/webvirtcloud/venv/bin/python /opt/webvirtcloud/console/novncd >> /var/log/novncd.log 2>&1
