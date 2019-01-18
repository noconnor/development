#!/usr/bin/env bash

#
# Script to install docker and its dependencies
#

OS=$(uname -s)
INFO=""
RAM=4096

function log(){
    INFO="${INFO}\n${1}"
}

function info(){
    echo -e "${INFO}"
}

function docker_setup(){
    [[ "${OS}" == "Darwin" ]] && docker_setup_macosx
    [[ "${OS}" == "Linux" ]] && docker_setup_linux
}

function docker_setup_linux() {
    docker --version
    if [[ $? -ne 0 ]]; then
      echo "Docker is not installed, installing now..."
      sudo yum --enablerepo=extras install -y docker
      [[ $? -ne 0 ]] && { log "ERROR: Docker install failed, exiting!"; exit 1; }
      sudo groupadd docker
      sudo usermod -aG docker ${USER}
      log "WARN: logout and back in again to run docker as a non-sudo users"
    fi
    sudo systemctl restart docker || { log "ERROR: unable to start docker systemctl process"; exit 1; }
}

function docker_setup_macosx() {
    docker --version
    if [[ $? -ne 0 ]]; then
        which brew || { log "WARN: brew is required, see https://brew.sh/"; exit 1; }
        which virtualbox || { echo "Installing virtualbox..."; brew cask install virtualbox; [ $? -ne 0 ] && exit 1; }
        docker --version || { echo "Installing docker..."; brew install docker; [ $? -ne 0 ] && exit 1; }
        docker --version || { echo "Re-installing docker..."; brew reinstall docker; [ $? -ne 0 ] && exit 1; }
        docker-machine --version || { echo "Installing docker machine..."; brew install docker-machine; [ $? -ne 0 ] && exit 1; }
    fi

    docker-machine ls | grep default
    if [[ $? -ne 0 ]]; then
        echo "Creating default virtual machine..."
        cpu=$(sysctl hw.logicalcpu | cut -d':' -f2)
        docker-machine create --virtualbox-cpu-count ${cpu} --virtualbox-memory ${RAM} --driver virtualbox default
    fi

    if ! (docker-machine ls | grep default | grep Running); then
        ( docker-machine start ) || { log "ERROR: Unable to start default docker machine"; exit 1; }
    fi

    eval "$(docker-machine env default)"

    # work around for slow filesystem sync on mac osx
    brew ls --versions ruby || { log "WARN: You may want to install ruby using brew"; }
    if ! which docker-sync > /dev/null; then
        echo "Installing docker-sync...";
        brew install unison
        brew install eugenmayer/dockersync/unox
        gem install docker-sync
        [ $? -ne 0 ] && log "WARN: docker-sync install failed, see http://docker-sync.io/"
    fi

}


trap info EXIT

docker_setup

exit 0
