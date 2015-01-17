# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure("2") do |config|

  config.vm.provision "shell", inline: "echo Hello"

  config.vm.define "log" do |log|
    
    # Box template to use  
    log.vm.box = "ubuntu/trusty64"
    
    # Increase memory available
    log.vm.provider "virtualbox" do |v|
      v.memory = 1024
    end

    log.vm.network "private_network", ip: "10.0.4.55"

    log.vm.synced_folder ".", "/vagrant", type: "nfs"

    log.ssh.forward_agent = true

    log.hostsupdater.aliases = ["logs.logstashdemo.com"]

    log.vm.provision "shell", path: "build/provision-logstash.sh"

  end

  config.vm.define "web" do |web|
    
    # Box template to use  
    web.vm.box = "ubuntu/trusty64"
    
    # Increase memory available
    web.vm.provider "virtualbox" do |v|
      v.memory = 1024
    end

    web.vm.network "private_network", ip: "10.0.4.56"

    web.vm.synced_folder ".", "/vagrant", type: "nfs"

    web.ssh.forward_agent = true

    web.hostsupdater.aliases = ["web.logstashdemo.com"]

    web.vm.provision "shell", path: "build/provision-web.sh"
  end
end