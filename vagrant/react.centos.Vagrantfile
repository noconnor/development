# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|

  config.vm.box = "centos/7"

  config.vm.provision "shell", inline: <<-SHELL
    yum -y update
    curl -sL https://rpm.nodesource.com/setup_8.x | bash -
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
    yum install -y nodejs
    yum install -y epel-release
    yum install -y python-pip
    echo 'alias ll="ls -al"' >> ~/.bashrc
    pip install awscli --upgrade --user
    echo 'export PATH=${PATH}:${HOME}/.local/bin/' >> ~/.bashrc
  SHELL

  config.ssh.forward_agent = true
  config.vm.network "private_network", ip: "192.168.50.4"
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 4
  end

  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 8081, host: 8081
  config.vm.network "forwarded_port", guest: 8082, host: 8082
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.network "forwarded_port", guest: 9229, host: 9229
  config.vm.network "forwarded_port", guest: 80, host: 80

  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder ".", "/vagrant-nfs", type: :nfs
  config.bindfs.bind_folder "/vagrant-nfs", "/home/vagrant/workspace"

end
