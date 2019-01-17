#!/usr/bin/env bash

# VAGRANT_BASE-centos/7
# DOCKER_BASE-centos:centos7

yum -y install epel-release
yum install -y git gcc zlib-devel bzip2-devel readline-devel sqlite-devel openssl-devel
yum -y install libffi-devel
yum clean all

curl -L https://raw.github.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> /root/.bashrc
echo 'eval "$(pyenv init -)"' >> /root/.bashrc
echo 'eval "$(pyenv virtualenv-init -)"' >> /root/.bashrc
echo '3.7.0' >> /root/.pyenv/version
source /root/.bashrc && pyenv install 3.7.0
source /root/.bashrc && pip install --upgrade pip
source /root/.bashrc && pip install robotframework
