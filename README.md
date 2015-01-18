#Application Logging & Logstash 

##Introduction

This code is the companion to the conference talk of the same name given in 
London at PHPUK 2015. 

Follow the instructions below to create teo VMs. The first of these is a fully working 
logstash instance and the second a webserver hosting a simple PHP demo application.

The web server sends its syslog, auth, nginx and web application logs to the logstash
instance. The demo app has two endpoints, one which simply outputs a greeting and 
another which fails in a variety of ways responding with a number of differnt http 
response codes. The second endpoint is used to demonstrate how to get interesting 
information from nginx logfiles. 

##Set Up

###Requirments

1. Virtual box

2. Vagrant

3. The vagrant host updater plugin

###Instructions

1. vagrant up

2. vagrant ssh web -c "cd /vagrant && composer install"

3. Access Kibana from your web browser http://logs.logstashdemo.com

4. Access the demo web application from your browser: http://web.logstashdemo.com

###FAQ 

####How do you set up Logstash / Elastic Search 

I followed guides published by digital occean

https://www.digitalocean.com/community/tutorials/how-to-use-logstash-and-kibana-to-centralize-and-visualize-logs-on-ubuntu-14-04

https://www.digitalocean.com/community/tutorials/adding-logstash-filters-to-improve-centralized-logging

The file *build/provision-logstash.sh* contains a script which automates the steps in the first article

####How do you ship logs to logstash

The article: 

https://www.digitalocean.com/community/tutorials/how-to-use-logstash-and-kibana-to-centralize-and-visualize-logs-on-ubuntu-14-04

Shows hos to use the logstash log forwarder and the script in *build/provision-web.sh* 
shows how the log forwarder is installed and configured. 

