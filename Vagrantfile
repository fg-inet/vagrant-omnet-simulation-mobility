# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  required_plugins = %w( vagrant-disksize )
  _retry = false
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false  
  end
  required_plugins.each do |plugin|
      unless Vagrant.has_plugin? plugin
          system "vagrant plugin install #{plugin}"
          _retry=true
      end
  end

  if (_retry)
      exec "vagrant " + ARGV.join(' ')
  end
  config.vm.box = "debian/contrib-stretch64"
  config.disksize.size = "20GB"
  config.vm.box_version = "9.8.0"
  config.vm.synced_folder "resources/", "/home/vagrant/resources/"
  config.vm.provision "shell", inline: "echo \"export PATH=$PATH:/home/vagrant/omnetpp-5.1/bin\" >> /home/vagrant/.bashrc", run: "always"
  config.vm.provision "shell", inline: "echo \"export PATH=$PATH:/home/vagrant/omnetpp-5.1/bin\" >> /home/vagrant/.profile", run: "always"
  config.vm.provision :shell, privileged: false, path: "provision.sh"
end
