# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|

  config.vm.box = "centos/7"

  config.vm.provision "shell", inline: <<-SHELL
    yum -y install epel-release
    yum install -y git gcc zlib-devel bzip2-devel readline-devel sqlite-devel openssl-devel
    yum -y install libffi-devel
    curl -L https://raw.github.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

    echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> /root/.bashrc
    echo 'eval "$(pyenv init -)"' >> /root/.bashrc
    echo 'eval "$(pyenv virtualenv-init -)"' >> /root/.bashrc
    source /root/.bashrc && pyenv install 3.7.0
    echo '3.7.0' >> /root/.pyenv/version
    source /root/.bashrc && pip install --upgrade pip
    source /root/.bashrc && pip install robotframework
  SHELL

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
