#!/usr/bin/env bash

DOCKER_ROOT=https://raw.githubusercontent.com/noconnor/development/master/docker/
TARGET=${1}
DOCKER_FILE_NAME=dockerfile-${1}
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
    echo "Looking for ${DOCKER_FILE_NAME} at ${DOCKER_ROOT} ..."
    URL=${DOCKER_ROOT}${DOCKER_FILE_NAME}
    if ( curl -o/dev/null -sfI "${URL}" ); then
        rm Dockerfile
        curl "${URL}" -o Dockerfile
        echo "Docker file downloaded!"
    else
       echo "Target (${URL}) not found" && exit 1
    fi
}

function find_expose_ports() {
    EXPOSE_PORTS=$(grep -i "EXPOSE" Dockerfile | cut -d' ' -f2-)
    echo "Exposing ports: ${EXPOSE_PORTS}"
}

function launch_docker_environment() {
    echo "Launching docker ..."
    docker build --tag="${TARGET}" .
    PORTS=""
    for PORT in ${EXPOSE_PORTS}; do PORTS+="-p ${PORT}:${PORT} "; done

    echo "#!/usr/bin/env bash" > start.sh
    echo "eval \"\$(docker-machine env default)\"" >> start.sh
    echo "docker run -w /home/project -v $(pwd):/home/project ${PORTS} -it ${TARGET} bash" >> start.sh
    chmod +x start.sh

    echo "To start env manually run: ./start.sh"
    (tty -s)
    [ $? -eq 0 ] && ./start.sh
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
