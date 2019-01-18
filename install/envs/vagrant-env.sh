#!/usr/bin/env bash

# User input
IMAGE=${1}

# Defaults
VAGRANT_FILE=https://raw.githubusercontent.com/noconnor/development/master/vagrant/${IMAGE}.Vagrantfile
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
    log "INFO: Destroy vm by running: vagrant destroy"
}

trap info EXIT

check_target
download_vagrant_file
initialise_environment
