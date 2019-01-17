FROM centos:centos7

# https://www.digitalocean.com/community/tutorials/how-to-install-python-3-and-set-up-a-local-programming-environment-on-centos-7
RUN yum -y update
RUN yum -y install yum-utils
RUN yum -y groupinstall development


# http://devopspy.com/python/pyenv-setup/
RUN yum -y install epel-release
RUN yum install -y git gcc zlib-devel bzip2-devel readline-devel sqlite-devel openssl-devel
RUN yum -y install libffi-devel
RUN curl -L https://raw.github.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

RUN echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> /root/.bashrc
RUN echo 'eval "$(pyenv init -)"' >> /root/.bashrc
RUN echo 'eval "$(pyenv virtualenv-init -)"' >> /root/.bashrc
RUN source /root/.bashrc && pyenv install 3.7.0
RUN echo '3.7.0' >> /root/.pyenv/version
RUN source /root/.bashrc && pip install --upgrade pip
RUN source /root/.bashrc && pip install robotframework

RUN yum clean
