#!/usr/bin/env bash

# User input
IMAGE=${1}
IMAGE_NO_REPO=$( echo ${IMAGE} | cut -d'/' -f2-)

# Defaults
VAGRANT_FILE=https://raw.githubusercontent.com/noconnor/development/master/vagrant/${IMAGE_NO_REPO}.Vagrantfile
VAGRANT_DEFAULT_FILE=https://raw.githubusercontent.com/noconnor/development/master/vagrant/default.Vagrantfile
INFO=""
OS=$(uname -s)

function log(){
    INFO="${INFO}\n${1}"
}

function info(){
    echo -e "${INFO}"
}

function check_target(){
    ( curl -o/dev/null -sfI "${VAGRANT_FILE}" ) || { log "WARN: Target (${VAGRANT_FILE}) not found, using default"; VAGRANT_FILE=${VAGRANT_DEFAULT_FILE}; }
}

function download_vagrant_file(){
    echo "Downloading ${VAGRANT_FILE}..."
    if ( curl -o/dev/null -sfI "${VAGRANT_FILE}" ); then
        [[ -f Dockerfile ]] && rm Vagrantfile
        curl "${VAGRANT_FILE}" -o Vagrantfile
        sed -i '' 's|IMAGE|'${IMAGE}'|g' Vagrantfile
        echo "Vagrant file downloaded!"
    else
       log "ERROR: Target (${VAGRANT_FILE}) not found" && exit 1
    fi
}

function initialise_environment(){
    vagrant up
    log "INFO: Access vm by running: vagrant ssh"
    log "INFO: Destroy vm by running: vagrant destroy"
}

trap info EXIT

check_target
download_vagrant_file
initialise_environment

exit 0
