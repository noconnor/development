#!/usr/bin/env bash

# VAGRANT_BASE centos/7
# DOCKER_BASE centos:centos7
# DOCKER_EXPOSE 8080
# DOCS-https://www.digitalocean.com/community/tutorials/how-to-install-python-3-and-set-up-a-local-programming-environment-on-centos-7

yum -y update
yum -y install yum-utils
yum -y groupinstall development
yum -y install epel-release
yum -y install python-pip

yum -y install git gcc zlib-devel bzip2-devel readline-devel sqlite-devel openssl-devel
yum -y install libffi-devel

yum -y install https://centos7.iuscommunity.org/ius-release.rpm
yum -y install python36u
yum -y install python36u-pip
yum -y install python36u-devel

cat > /etc/profile.d/python3.sh <<EOL
if [ ! -d \${HOME}/py3 ]; then
    echo "Creating default python3.6 env"
    (
        cd \${HOME}
        python3.6 -m venv py3
        echo "alias py3init=\"source \${HOME}/py3/bin/activate\"" >> \${HOME}/.bash_profile
        echo "echo \"run py3init to activate python3 environment\"" >> \${HOME}/.bash_profile
    )
fi
EOL
chmod +x /etc/profile.d/python3.sh

pip install --upgrade pip

yum clean all
