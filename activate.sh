#!/usr/bin/env bash

DOCKER_ROOT=https://raw.githubusercontent.com/noconnor/development/master/docker/
TARGET=${1}
DOCKER_FILE_NAME=dockerfile-${1}
EXPOSE_PORTS=
DOCKER_PORT_MAPPING=
OS=$(uname -s)
MOUNT_DIR=$(pwd)
WARNINGS=

function warnings(){
    echo "${WARNINGS}"
}

function docker_setup(){
    [ "${OS}" == "Darwin" ] && docker_setup_macosx
    [ "${OS}" == "Linux" ] && docker_setup_linux
}

function docker_setup_linux() {
    docker --version
    if [ $? -ne 0 ]; then
      echo "Docker is not installed, installing now..."
      sudo yum --enablerepo=extras install -y docker
      [ $? -ne 0 ] && { WARNINGS+="Docker install failed, exiting!\n"; exit 1; }
      sudo groupadd docker
      sudo usermod -aG docker ${USER}
      WARNINGS+="WARN: logout and back in again to run docker as a non-sudo users\n"
    fi
    sudo systemctl restart docker || { WARNINGS+="ERROR: unable to start docker systemctl process\n"; exit 1; }
}

function docker_setup_macosx() {
    docker --version
    if [ $? -ne 0 ]; then
        which brew || { WARNINGS+="WARN: brew is required, see https://brew.sh/\n"; exit 1; }
        which virtualbox || { echo "Installing virtualbox..."; brew cask install virtualbox; [ $? -ne 0 ] && exit 1; }
        docker --version || { echo "Installing docker..."; brew install docker; [ $? -ne 0 ] && exit 1; }
        docker --version || { echo "Re-installing docker..."; brew reinstall docker; [ $? -ne 0 ] && exit 1; }
        docker-machine --version || { echo "Installing docker machine..."; brew install docker-machine; [ $? -ne 0 ] && exit 1; }
    fi
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
        [ -f Dockerfile ] && rm Dockerfile
        curl "${URL}" -o Dockerfile
        echo "Docker file downloaded!"
    else
       WARNINGS+="Target (${URL}) not found\n" && exit 1
    fi
}

function generate_docker_port_mappings() {
    local expose=$(grep -i "EXPOSE" Dockerfile | cut -d' ' -f2-)
    DOCKER_PORT_MAPPING=""
    for PORT in ${expose}; do DOCKER_PORT_MAPPING+="-p ${PORT}:${PORT} "; done
}

function generate_start_script_macosx() {

    if [[ "${MOUNT_DIR}" != ${HOME}* ]]; then
        WARNINGS+="WARN: \"VirtualBox Shared Folder\" permissions required to mount an non ${HOME} directory\n"
    fi

    docker build --tag=${TARGET} .
    echo "#!/usr/bin/env bash" > start.sh
    echo "eval \"\$(docker-machine env default)\"" >> start.sh
    echo "docker run -w /home/workspace -v ${MOUNT_DIR}:/home/workspace ${DOCKER_PORT_MAPPING} -it ${TARGET} bash" >> start.sh
    chmod +x start.sh
}

function generate_start_script_linux(){
    sg docker -c "docker build --tag=${TARGET} ."
    echo "#!/usr/bin/env bash" > start.sh
    echo "sg docker -c \"docker run -w /home/workspace -v ${MOUNT_DIR}:/home/workspace ${DOCKER_PORT_MAPPING} -it ${TARGET} bash\"" >> start.sh

}

function launch_docker_environment() {

    [ ${OS} == "Darwin" ] && generate_start_script_macosx
    [ ${OS} == "Linux" ]  && generate_start_script_linux

    chmod +x start.sh

    echo "To start env manually run: ./start.sh"
    (tty -s)
    [ $? -eq 0 ] && { echo "Launching docker ..."; ./start.sh; }
}

trap warnings EXIT

docker_setup
download_docker_file
generate_docker_port_mappings
launch_docker_environment
