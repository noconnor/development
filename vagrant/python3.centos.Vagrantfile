# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|

  config.vm.box = "noconnorie/python3.centos"

  config.ssh.forward_agent = true
  config.vm.network "private_network", ip: "192.168.50.4"
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 4
  end

  config.vm.network "forwarded_port", guest: 80, host: 80

  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder ".", "/vagrant-nfs", type: :nfs
  config.bindfs.bind_folder "/vagrant-nfs", "/home/vagrant/workspace"

end
