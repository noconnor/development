#!/usr/bin/env bash

# VAGRANT_BASE noconnorie/python3.centos
# DOCKER_BASE noconnorie/python3.centos
# DOCKER_EXPOSE 8080 8081 8082 9229 80 3000

yum -y update

# Node setup
curl -sL https://rpm.nodesource.com/setup_8.x | bash -
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
yum install -y nodejs

# AWS cli setup
pip install --upgrade awscli

yum clean all

echo 'alias ll="ls -al"' >> ~/.bashrc
