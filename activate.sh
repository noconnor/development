#!/usr/bin/env bash

DOCKER_ROOT=https://raw.githubusercontent.com/noconnor/development/master/docker/
TARGET=${1}
DOCKER_FILE_NAME=dockerfile-${1}
EXPOSE_PORTS=
OS=$(uname -s)
MOUNT_DIR=$(pwd)

function check_docker_setup(){
    [ "${OS}" == "Darwin" ] && check_mac_osx_docker_setup
    [ "${OS}" == "Linux" ] && check_linux_docker_setup
}

function check_linux_docker_setup() {
    docker --version
    if [ $? -ne 0 ]; then
      echo "Docker is not installed, installing now..."
      sudo yum --enablerepo=extras install -y docker
      [ $? -ne 0 ] && { echo "Docker install failed, exiting!"; exit 1; }
      sudo groupadd docker
      sudo usermod -aG docker ${USER}
      newgrp docker
    fi
    sudo systemctl restart docker || { echo "ERROR: unable to start docker systemctl process"; exit 1; }
}

function check_mac_osx_docker_setup() {
    which brew || { echo "WARN brew is not installed, see https://brew.sh/"; }
    which virtualbox || { echo "virtualbox is not installed, run: brew cask install virtualbox"; exit 1; }
    docker --version || { echo "Docker is not installed, run: brew cask install docker"; exit 1; }
    docker-machine --version || { echo "Docker machine is not installed, run: brew install docker-machine"; exit 1; }
    initialise_docker_machine
}

function initialise_docker_machine() {
    docker-machine ls | grep default
    [ $? -ne 0 ] && echo "Creating default virtual machine..." && docker-machine create --driver virtualbox default
    eval "$(docker-machine env default)"
}

function download_docker_file() {
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

function identify_ports_to_expose() {
    EXPOSE_PORTS=$(grep -i "EXPOSE" Dockerfile | cut -d' ' -f2-)
    echo "Exposing ports: ${EXPOSE_PORTS}"
}

function launch_docker_environment() {
    echo "Launching docker ..."
    docker build --tag="${TARGET}" .
    PORTS=""
    for PORT in ${EXPOSE_PORTS}; do PORTS+="-p ${PORT}:${PORT} "; done

    [[ ${OS} == "Darwin" && "${MOUNT_DIR}" != ${HOME}* ]] && echo "WARN: \"VirtualBox Shared Folder\" permissions required to mount an non ${HOME} directory"

    echo "#!/usr/bin/env bash" > start.sh
    echo "eval \"\$(docker-machine env default)\"" >> start.sh
    echo "docker run -w /home/workspace -v ${MOUNT_DIR}:/home/workspace ${PORTS} -it ${TARGET} bash" >> start.sh
    chmod +x start.sh

    echo "To start env manually run: ./start.sh"
    (tty -s)
    [ $? -eq 0 ] && ./start.sh
}


check_docker_setup
download_docker_file
identify_ports_to_expose
launch_docker_environment
