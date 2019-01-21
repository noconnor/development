#!/usr/bin/env bash

# VAGRANT_BASE centos/7
# DOCKER_BASE centos:centos7
# DOCKER_EXPOSE 8080 8081 8082 9229 80 3000

yum -y update

# Node setup
curl -sL https://rpm.nodesource.com/setup_8.x | bash -
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
yum install -y nodejs
yum install -y epel-release

# AWS cli setup
yum install -y python-pip
pip install awscli --upgrade --user

yum clean all

echo 'alias ll="ls -al"' >> ~/.bashrc
echo 'export PATH=${PATH}:${HOME}/.local/bin/' >> ~/.bashrc
