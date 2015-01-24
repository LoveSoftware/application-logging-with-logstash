#Application Logging With Logstash And Monolog 

##Introduction

This code is the companion to the conference talk of the same name given in 
London at PHPUK 2015. 

Follow the instructions below to create teo VMs. The first of these is a fully working 
Logstash instance and the second a webserver hosting a simple PHP demo application.

The web server sends its syslog, auth, Nginx and web application logs to the Logstash
instance. The demo app has two endpoints, one which simply outputs a greeting and 
another which fails in a variety of ways responding with a number of different http 
response codes. The second endpoint is used to demonstrate how to get interesting 
information from Nginx log files. 

##Set Up

###Requirments

1. [Virtual box](https://www.virtualbox.org/)

2. [Vagrant](https://www.vagrantup.com/)

3. The vagrant [host updater plugin](https://github.com/cogitatio/vagrant-hostsupdater)

###Instructions

1. vagrant up

2. vagrant ssh web -c "cd /vagrant && composer install"

3. Access Kibana from your web browser http://logs.logstashdemo.com

4. Access the demo web application from your browser: http://web.logstashdemo.com

### What am I looking at? 

When you visit the Kibana dashboard you should see a graph showing the various logs shipped from the web server 
to the logs server. There should be a lot of syslog entries initially. By visiting the web instance you can trigger some
Nginx access logs to be collected. 

Try the following query in the search box: 

```
type: nginx-access-hello-app AND response:200
```

You should see only the nginx access logs rather than all logs including syslogs.

### List of web endpoints

http://web.logstashdemo.com/

/ - A simple endpoint producing a sucesfull response and a single entry in the access log

/flappy - An endpoint that produces a range of errors to demonstrate using logstash to display errors

/fingerscrossed - An endpoint which uses Monolog + Fingers Crossed handler to demo application logging

/register - An endpoint which uses Monolog and Symfony Event Manager to demonstrate business event logging

###FAQ 

####How do you set up Logstash / Elastic Search 

I followed guides published by Digital Occean

[Part One: Setting up Logstash, Kibana](https://www.digitalocean.com/community/tutorials/how-to-use-logstash-and-kibana-to-centralize-and-visualize-logs-on-ubuntu-14-04)

[Part Two: Using Logstash filters](https://www.digitalocean.com/community/tutorials/adding-logstash-filters-to-improve-centralized-logging)

The file *build/provision-logstash.sh* contains a script which automates the steps in the first article

####How do you ship logs to Logstash

The article: 

[Part One: Setting up Logstash, Kibana](https://www.digitalocean.com/community/tutorials/how-to-use-logstash-and-kibana-to-centralize-and-visualize-logs-on-ubuntu-14-04)

Shows how to use the Logstash log forwarder and the script in *build/provision-web.sh* 
shows how the log forwarder is installed and configured. 

####How do I search logs via Kibana 

Go to the http://logs.logstashdemo.com after following the instructions above. 

[The documentation](http://www.elasticsearch.org/guide/en/kibana/current/working-with-queries-and-filters.html) provides a set of examples on how to use the search effectivley.   

####Why Haven't you used *insert x configuration managment system* to set this up?

In an effort to clearly define the steps required to install Logstash and make the accessible to everyone I haven't used a config management tool.
In a production setup I recommend you automate the deployment of Logstash and its agents! 

###Troubleshooting

####Networking Issues

This vagrant file uses a host only networking configuration. This should be created automatically but where it isn't:

1) Open Virtual Box
2) Open preferences
3) Select networking
4) Select 'Host Only Networks'
5) Create a host only network wit the following settings: 
```
IPV4 Address: 10.0.4.1
IPV4 Mask: 255.255.255.0
```

####No Logfiles in Kibana

If you aren't seeing logs appear in Kibana check the log for the logstash forwarding agent.
```
tail -f /var/log/logstash-forwarder.log
```

You should also be able to use the browser console to see if any errors are being returned from ajax calls to elastic search.


  