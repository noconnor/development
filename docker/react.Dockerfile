FROM centos:centos7

RUN yum -y update

RUN curl -sL https://rpm.nodesource.com/setup_8.x | bash -
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

RUN yum install -y initscripts && yum clean all
RUN yum install -y nodejs
RUN yum install -y epel-release
RUN yum install -y python-pip
RUN echo 'alias ll="ls -al"' >> ~/.bashrc

# OPTIONAL - not strictly required for react apps
RUN pip install awscli --upgrade --user
RUN echo 'export PATH=${PATH}:${HOME}/.local/bin/' >> ~/.bashrc

EXPOSE 8080 8081 8082 9229 80 3000
