
# Update Apt 
wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
echo 'deb http://packages.elasticsearch.org/elasticsearch/1.1/debian stable main' | sudo tee /etc/apt/sources.list.d/elasticsearch.list
echo 'deb http://packages.elasticsearch.org/logstash/1.4/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash.list
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update

# Install Java
sudo echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo apt-get install -y oracle-java8-installer
sudo apt-get install -y oracle-java8-set-default

# Install Elastic Search
sudo apt-get -y install elasticsearch=1.1.1
sudo update-rc.d elasticsearch defaults 95 10
sudo cp /vagrant/build/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
sudo service elasticsearch start

# Install Kibana
cd ~; wget https://download.elasticsearch.org/kibana/kibana/kibana-3.0.1.tar.gz
tar xf kibana-3.0.1.tar.gz
cp /vagrant/build/kibana/config.js ~/kibana-3.0.1/config.js
sudo mkdir -p /var/www/kibana3
sudo cp -R ~/kibana-3.0.1/* /var/www/kibana3

# Install Nginx
sudo apt-get install -y nginx
sudo cp /vagrant/build/nginx/kibanaelastic.conf /etc/nginx/sites-available/default
sudo apt-get install -y apache2-utils
echo "password" | sudo htpasswd -c -i /etc/nginx/conf.d/logs.logstashdemo.com.passwd kibana
sudo service nginx restart

# Install logstash
sudo apt-get install logstash=1.4.2-1-2c0f5a1

# Create SSL Certs
sudo mkdir -p /etc/pki/tls/certs
sudo mkdir /etc/pki/tls/private

cd /etc/pki/tls; sudo openssl req -x509 -batch -nodes -days 3650 -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt
cp /etc/pki/tls/certs/logstash-forwarder.crt /vagrant/build/artifacts/logstash-forwarder.crt

sudo cp /vagrant/build/logstash/01-lumberjack-input.conf /etc/logstash/conf.d/01-lumberjack-input.conf
sudo cp /vagrant/build/logstash/10-filter.conf /etc/logstash/conf.d/10-filter.conf
sudo cp /vagrant/build/logstash/30-lumberjack-output.conf /etc/logstash/conf.d/30-lumberjack-output.conf

sudo service logstash restart
