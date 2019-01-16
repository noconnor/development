#!/usr/bin/env bash

VAGRANT_FILE=https://raw.githubusercontent.com/noconnor/development/master/vagrant/Vagrantfile
TARGET=${1}
INFO=""

function log(){
    INFO="${INFO}\n${1}"
}

function info(){
    echo -e "${INFO}"
}

function vagrant_setup(){
    which virtualbox || { echo "Installing virtualbox..."; brew cask install virtualbox; [ $? -ne 0 ] && exit 1; }
    which vagrant || { echo "Installing vagrant..."; brew cask install vagrant; [ $? -ne 0 ] && exit 1; }
    brew cask list vagrant-manager || { echo "Installing vagrant-manager..."; brew cask install vagrant-manager; [ $? -ne 0 ] && exit 1; }
}

function download_vagrant_file(){
    echo "Downloading ${VAGRANT_FILE}..."
    if ( curl -o/dev/null -sfI "${VAGRANT_FILE}" ); then
        [[ -f Dockerfile ]] && rm Vagrantfile
        curl "${VAGRANT_FILE}" -o Vagrantfile
        echo "Vagrant file downloaded!"
    else
       log "Target (${VAGRANT_FILE}) not found" && exit 1
    fi
}

function initialise_environment(){
    vagrant up
    vagrant ssh -c "cd /vagrant && curl -o- https://raw.githubusercontent.com/noconnor/development/master/install.sh | bash -s ${TARGET}"
    log "Access vm by running: vagrant ssh"
}

trap info EXIT

vagrant_setup
download_vagrant_file
initialise_environment
