# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "debian/jessie64"

  config.vm.define "node1" do |node1|
    node1.vm.network :private_network, :ip => "172.16.255.251"
    node1.vm.hostname = "node1"
    node1.vm.provider "virtualbox" do |v|
      v.memory = 2048
    end
    node1.vm.provision "shell", inline: <<SCRIPT
echo "installing node1"
bash /vagrant/scripts/install.sh bootstrap
SCRIPT
  end

  config.vm.define "node2" do |node2|
    node2.vm.network :private_network, :ip => "172.16.255.252"
    node2.vm.hostname = "node2"
    node2.vm.provider "virtualbox" do |v|
      v.memory = 2048
    end
    node2.vm.provision "shell", inline: <<SCRIPT
echo "installing node2"
bash /vagrant/scripts/install.sh bootstrap
SCRIPT
  end
  
end