# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/contrib-stretch64"
  config.vm.box_version = "9.8.0"
  config.vm.synced_folder "resources/", "/home/vagrant/resources/"
  config.vm.provision "shell", inline: "echo \"export PATH=$PATH:/home/vagrant/omnetpp-5.1/bin\" >> /home/vagrant/.bashrc", run: "always"
  config.vm.provision "shell", inline: "echo \"export PATH=$PATH:/home/vagrant/omnetpp-5.1/bin\" >> /home/vagrant/.profile", run: "always"
  config.vm.provision :shell, privileged: false, path: "provision.sh"
end
