#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


TARGET=${1}
DOCKER_FILE_NAME=dockerfile-${1}
DOCKER_FILE=
EXPOSE_PORTS=

function check_for_brew() {
    which brew
    [ $? -ne 0 ] && echo "brew is not installed, see https://brew.sh/" && exit 1
}

function check_for_virtualbox() {
    which virtualbox
    [ $? -ne 0 ] && echo "virtualbox is not installed, run `brew cask install virtualbox`" && exit 1
}
function check_for_docker() {
    docker --version
    [ $? -ne 0 ] && echo "Docker is not installed, run `brew cask install docker`" && exit 1
}

function check_for_docker_machine() {
    docker-machine --version
    [ $? -ne 0 ] && echo "Docker machine is not installed, run `brew install docker-machine`" && exit 1
}

function initialise_docker_machine() {
    docker-machine ls | grep default
    [ $? -ne 0 ] && echo "Creating default virtual machine..." && docker-machine create --driver virtualbox default
    eval "$(docker-machine env default)"
}

function find_docker_file() {
    echo "Looking for ${DOCKER_FILE_NAME} in ${SCRIPT_DIR} ..."
    DOCKER_FILE=$(find ${SCRIPT_DIR} -name ${DOCKER_FILE_NAME});
    [ ! -f "${DOCKER_FILE}" ] && echo "Target (${DOCKER_FILE_NAME}) not found" && exit 1
    echo "Docker file: ${DOCKER_FILE}"
}

function find_expose_ports() {
    EXPOSE_PORTS=$(grep -i "EXPOSE" ${DOCKER_FILE} | cut -d' ' -f2-)
    echo "Exposing ports: ${EXPOSE_PORTS}"
}

function launch_docker_environment() {
    echo "Launching ${DOCKER_FILE} ..."
    docker build -f "${DOCKER_FILE}" --tag="${TARGET}" .
    PORTS=""
    for PORT in ${EXPOSE_PORTS}; do PORTS+="-p ${PORT}:${PORT} "; done
    docker run ${PORTS} -it ${TARGET} bash
}

# pre-requisites
check_for_brew
check_for_virtualbox
check_for_docker
check_for_docker_machine

# initialise environment
initialise_docker_machine

# run docker file
find_docker_file
find_expose_ports
launch_docker_environment
