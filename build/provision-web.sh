#!/bin/sh
wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
echo 'deb http://packages.elasticsearch.org/logstashforwarder/debian stable main' | sudo tee /etc/apt/sources.list.d/logstashforwarder.list

sudo apt-get update

# Install Required packages
sudo apt-get install -y logstash-forwarder
sudo apt-get install -y git
sudo apt-get install -y nginx
sudo apt-get install -y php5-fpm php5 php5-dev 

# Configure Nginx
sudo cp /vagrant/build/nginx/logdemo.conf /etc/nginx/sites-available/default
sudo service nginx restart

# Configure Composer 
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Configure The Logstash Forwarder
sudo cp /vagrant/build/logstash/logstash-forwarder.init /etc/init.d/logstash-forwarder
sudo chmod +x /etc/init.d/logstash-forwarder
sudo update-rc.d logstash-forwarder defaults
sudo mkdir -p /etc/pki/tls/certs
sudo cp /vagrant/build/artifacts/logstash-forwarder.crt /etc/pki/tls/certs/
sudo cp /vagrant/build/logstash/logstash-forwarder /etc/logstash-forwarder

sudo service logstash-forwarder restart