#!/bin/sh
sudo apt-get update

# Install Required packages
sudo apt-get install -y logstash-forwarder
sudo apt-get install -y git
sudo apt-get install -y nginx
sudo apt-get install -y php5-fpm php5 php5-dev 
sudo apt-get install -y varnish
sudo apt-get install -y supervisor

# Configure Nginx
sudo cp /vagrant/build/nginx/logdemo.conf /etc/nginx/sites-available/default
sudo service nginx restart

# Configure Varnish
sudo cp /vagrant/build/varnish/varnish /etc/default/varnish
sudo cp /vagrant/build/varnish/default.vcl /etc/varnish/default.vcl
sudo service varnish restart

# Configure Composer 
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Add log files
sudo touch /var/log/logstash-forwarder.log
sudo touch /var/log/app.log
sudo touch /var/log/bus.log
sudo chown www-data /var/log/app.log
sudo chown www-data /var/log/bus.log
sudo chmod 777 /var/log/logstash-forwarder.log

# Hosts File
echo '10.0.4.55 logs.logstashdemo.com' | sudo tee --append /etc/hosts
echo '127.0.0.1 web.logstashdemo.com' | sudo tee --append /etc/hosts

# Configure The Logstash Forwarder
sudo cp /vagrant/build/logstash/logstash-forwarder /usr/bin/logstash-forwarder
sudo cp /vagrant/build/supervisord/supervisord.conf /etc/supervisor/supervisord.conf 

sudo mkdir -p /etc/pki/tls/certs
sudo cp /vagrant/build/artifacts/logstash-forwarder.crt /etc/pki/tls/certs/

sudo service supervisor restart
