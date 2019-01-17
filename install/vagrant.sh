#!/usr/bin/env bash

TARGET_ENV=${1}
TARGET_OS=${2:-centos}
VAGRANT_FILE=https://raw.githubusercontent.com/noconnor/development/master/vagrant/${TARGET_ENV}.${TARGET_OS}.Vagrantfile
INFO=""
OS=$(uname -s)

function log(){
    INFO="${INFO}\n${1}"
}

function info(){
    echo -e "${INFO}"
}

function check_target(){
    ( curl -o/dev/null -sfI "${VAGRANT_FILE}" ) || { log "ERROR: Target (${VAGRANT_FILE}) not found"; exit 1; }
}

function vagrant_setup(){
    [[ "${OS}" == "Darwin" ]] && vagrant_setup_macosx
}

function vagrant_setup_macosx(){
    which virtualbox || { echo "Installing virtualbox..."; brew cask install virtualbox; [ $? -ne 0 ] && exit 1; }
    which vagrant || { echo "Installing vagrant..."; brew cask install vagrant; [ $? -ne 0 ] && exit 1; }
    brew cask list vagrant-manager || { echo "Installing vagrant-manager..."; brew cask install vagrant-manager; [ $? -ne 0 ] && exit 1; }
    (vagrant plugin list | grep vagrant-bindfs) || { echo "Installing vagrant-bindfs..."; vagrant plugin install vagrant-bindfs; [ $? -ne 0 ] && exit 1; }
}

function download_vagrant_file(){
    echo "Downloading ${VAGRANT_FILE}..."
    if ( curl -o/dev/null -sfI "${VAGRANT_FILE}" ); then
        [[ -f Dockerfile ]] && rm Vagrantfile
        curl "${VAGRANT_FILE}" -o Vagrantfile
        echo "Vagrant file downloaded!"
    else
       log "ERROR: Target (${VAGRANT_FILE}) not found" && exit 1
    fi
}

function initialise_environment(){
    vagrant up
    log "INFO: Access vm by running: vagrant ssh"
}

trap info EXIT

check_target
vagrant_setup
download_vagrant_file
initialise_environment
