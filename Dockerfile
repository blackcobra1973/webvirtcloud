FROM phusion/baseimage:0.9.17
MAINTAINER Jethro Yu <comet.jc@gmail.com>

RUN echo 'APT::Get::Clean=always;' >> /etc/apt/apt.conf.d/99AutomaticClean

RUN apt-get update -qqy
RUN DEBIAN_FRONTEND=noninteractive apt-get -qyy install \
	-o APT::Install-Suggests=false \
	git python-virtualenv python-dev libxml2-dev libvirt-dev zlib1g-dev nginx libsasl2-modules

ADD . /opt/webvirtcloud
RUN chown -R www-data:www-data /opt/webvirtcloud

# Setup webvirtcloud
RUN cd /opt/webvirtcloud && \
	virtualenv venv && \
	. venv/bin/activate && \
	pip install -U pip && \
	pip install -r conf/requirements.txt && \
	chown -R www-data:www-data /opt/webvirtcloud

RUN cd /opt/webvirtcloud && . venv/bin/activate && \
	python manage.py migrate && \
	chown -R www-data:www-data /opt/webvirtcloud

# Setup Nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
	rm /etc/nginx/sites-enabled/default && \
	chown -R www-data:www-data /var/lib/nginx

ADD conf/nginx/webvirtcloud.conf /etc/nginx/conf.d/

# Register services to runit
RUN	mkdir /etc/service/nginx && \
	mkdir /etc/service/nginx-log-forwarder && \
	mkdir /etc/service/webvirtcloud && \
	mkdir /etc/service/novnc
ADD conf/runit/nginx			/etc/service/nginx/run
ADD conf/runit/nginx-log-forwarder	/etc/service/nginx-log-forwarder/run
ADD conf/runit/novncd.sh		/etc/service/novnc/run
ADD conf/runit/webvirtcloud.sh		/etc/service/webvirtcloud/run

EXPOSE 80
EXPOSE 6080

# Define mountable directories.
#VOLUME []

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
