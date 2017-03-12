## WebVirtCloud Beta


## Features

* User can add SSH public key to root in Instance (Tested only Ubuntu)
* User can change root password in Instance (Tested only Ubuntu)

### Warning!!!

How to update <code>gstfsd</code> daemon on hypervisor:

```bash
wget -O - https://clck.ru/9VMRH | sudo tee -a /usr/local/bin/gstfsd
sudo service supervisor restart
```

### Description

WebVirtCloud is a virtualization web interface for admins and users. It can delegate Virtual Machine's to users. A noVNC viewer presents a full graphical console to the guest domain.  KVM is currently the only hypervisor supported.

### Install WebVirtCloud panel (Ubuntu)

```bash
sudo apt-get -y install git python-virtualenv python-dev libxml2-dev libvirt-dev zlib1g-dev nginx supervisor libsasl2-modules gcc pkg-config
git clone https://github.com/retspen/webvirtcloud
cd webvirtcloud
sudo cp conf/supervisor/webvirtcloud.conf /etc/supervisor/conf.d
sudo cp conf/nginx/webvirtcloud.conf /etc/nginx/conf.d
cd ..
sudo mv webvirtcloud /opt
sudo chown -R www-data:www-data /opt/webvirtcloud
cd /opt/webvirtcloud
virtualenv venv
source venv/bin/activate
pip install -r conf/requirements.txt
python manage.py migrate
sudo chown -R www-data:www-data /opt/webvirtcloud
sudo rm /etc/nginx/sites-enabled/default
```

Restart services for running WebVirtCloud:

```bash
sudo service nginx restart
sudo service supervisor restart
```

Setup libvirt and KVM on server

```bash
wget -O - https://clck.ru/9V9fH | sudo sh
```

### Install WebVirtCloud panel (CentOS)

```bash
sudo yum -y install python-virtualenv python-devel libvirt-devel glibc gcc nginx supervisor libxml2 libxml2-devel git
```

#### Creating directories and cloning repo

```bash
sudo cd /opt
sudo git clone https://github.com/retspen/webvirtcloud && cd webvirtcloud
```

#### Start installation webvirtcloud
```
sudo virtualenv venv
sudo source venv/bin/activate
sudo venv/bin/pip install -r conf/requirements.txt
sudo cp conf/nginx/webvirtcloud.conf /etc/nginx/conf.d/
sudo venv/bin/python manage.py migrate
```

#### Configure the supervisor for CentOS
Put the needed config files in /etc/supervisord.d/
```bash
cd webvirtcloud
sudo cp conf/supervisor/webvirtcloud.ini /etc/supervisor/conf.d
```

**Or:**

Add the following after the [include] line (after **files = ... ** actually):
```bash
sudo vim /etc/supervisord.conf

[program:webvirtcloud]
command=/opt/webvirtcloud/venv/bin/gunicorn webvirtcloud.wsgi:application -c /opt/webvirtcloud/gunicorn.conf.py
directory=/opt/webvirtcloud
user=nginx
autostart=true
autorestart=true
redirect_stderr=true

[program:novncd]
command=/opt/webvirtcloud/venv/bin/python /opt/webvirtcloud/console/novncd
directory=/opt/webvirtcloud
user=nginx
autostart=true
autorestart=true
redirect_stderr=true
```

#### Edit the nginx.conf file
You will need to edit the main nginx.conf file as the one that comes from the rpm's will not work. Comment the following lines:

```
#    server {
#        listen       80 default_server;
#        listen       [::]:80 default_server;
#        server_name  _;
#        root         /usr/share/nginx/html;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        location / {
#        }
#
#        error_page 404 /404.html;
#            location = /40x.html {
#        }
#
#        error_page 500 502 503 504 /50x.html;
#            location = /50x.html {
#        }
#    }
}
```

Also make sure file in **/etc/nginx/conf.d/webvirtcloud.conf** has the proper paths:
```
upstream gunicorn_server {
    #server unix:/opt/webvirtcloud/venv/wvcloud.socket fail_timeout=0;
    server 127.0.0.1:8000 fail_timeout=0;
}
server {
    listen 80;

    server_name servername.domain.com;
    access_log /var/log/nginx/webvirtcloud-access_log;

    location /static/ {
        root /opt/webvirtcloud;
        expires max;
    }

    location / {
        proxy_pass http://gunicorn_server;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-for $proxy_add_x_forwarded_for;
        proxy_set_header Host $host:$server_port;
        proxy_set_header X-Forwarded-Proto $remote_addr;
        proxy_connect_timeout 600;
        proxy_read_timeout 600;
        proxy_send_timeout 600;
        client_max_body_size 1024M;
    }
}
```

Change permissions so nginx can read the webvirtcloud folder:

```bash
sudo chown -R nginx:nginx /opt/webvirtcloud
```

Change permission for selinux:

```bash
sudo semanage fcontext -a -t httpd_sys_content_t "/opt/webvirtcloud(/.*)"
```

Add required user to the kvm group:
```bash
sudo usermod -G kvm -a webvirtmgr
```

Let's restart nginx and the supervisord services:
```bash
sudo systemctl restart nginx && systemctl restart supervisord
```

And finally, check everything is running:
```bash
sudo supervisorctl status

novncd                           RUNNING    pid 24186, uptime 2:59:14
webvirtcloud                     RUNNING    pid 24185, uptime 2:59:14

```

#### Apache mod_wsgi configuration
```
WSGIDaemonProcess webvirtcloud threads=2 maximum-requests=1000 display-name=webvirtcloud
WSGIScriptAlias / /opt/webvirtcloud/webvirtcloud/wsgi.py
```

#### Install final required packages for libvirtd and others on Host Server
```bash
wget -O - https://clck.ru/9V9fH | sudo sh
```

Done!!

Go to http://serverip and you should see the login screen.

### Default credentials
<pre>
login: admin
password: admin
</pre>

### How To Update
```bash
git pull
python manage.py migrate
sudo service supervisor restart
```

### License

WebVirtCloud is licensed under the [Apache Licence, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).
