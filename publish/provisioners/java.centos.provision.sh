#!/usr/bin/env bash

# VAGRANT_BASE noconnorie/aws.centos
# DOCKER_BASE noconnorie/aws.centos
# DOCKER_EXPOSE 8080 8000

yum -y update

# https://tecadmin.net/install-java-8-on-centos-rhel-and-fedora/
# latest https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
export JDK8=jdk1.8.0_201
export JDK8_TAR=jdk-8u201-linux-i586.tar.gz
export DL="https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/${JDK8_TAR}"

cd /opt/
curl -k -L --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "${DL}" -o "${JDK8_TAR}"
tar -xvzf ${JDK8_TAR} || exit 1
cd /opt/${JDK8}

# Fix for /lib/ld-linux.so.2: bad ELF interpreter: No such file or directory
yum install -y glibc.i686

alternatives --install /usr/bin/java java /opt/${JDK8}/bin/java 2
alternatives --install /usr/bin/jar jar /opt/${JDK8}/bin/jar 2
alternatives --install /usr/bin/javac javac /opt/${JDK8}/bin/javac 2

# make JDK java 8 the default
alternatives --set java /opt/${JDK8}/bin/java
alternatives --set jar /opt/${JDK8}/bin/jar
alternatives --set javac /opt/${JDK8}/bin/javac

echo "export JAVA_HOME=/opt/${JDK8}" >> /etc/bashrc
echo "export JRE_HOME=/opt/${JDK8}/jre" >> /etc/bashrc
echo "export PATH=$PATH:/opt/${JDK8}/bin:/opt/${JDK8}/jre/bin" >> /etc/bashrc

yum clean all
