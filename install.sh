#!/usr/bin/env bash

DOCKER_ROOT=https://raw.githubusercontent.com/noconnor/development/master/docker/
TARGET=${1}
DOCKER_FILE_NAME=${1}.Dockerfile
EXPOSE_PORTS=
DOCKER_PORT_MAPPING=
OS=$(uname -s)
MOUNT_DIR=$(pwd)
INFO=""
CPUS=$(sysctl hw.logicalcpu | cut -d':' -f2)
RAM=4096

function check_target(){
    # add switch
    case ${TARGET} in
        react)
            ;;
        robot)
            ;;
        *)
            INFO+="Unexpected target profile: ${TARGET}"
            exit 1;
     esac
}

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
        docker-machine create --virtualbox-cpu-count ${CPUS} --virtualbox-memory ${RAM} --driver virtualbox default
    fi
    eval "$(docker-machine env default)"

    # work around for slow filesystem sync on mac osx
    brew ls --versions ruby || { log "You may want to install ruby using brew, see README for instructions"; }
    if ! which docker-sync > /dev/null; then
        echo "Installing docker-sync...";
        brew install unison
        brew install eugenmayer/dockersync/unox
        gem install docker-sync
        [ $? -ne 0 ] && log "WARN: docker-sync install failed, see http://docker-sync.io/"
    fi

}

function download_docker_file() {
    echo "Looking for ${DOCKER_FILE_NAME} at ${DOCKER_ROOT} ..."
    URL=${DOCKER_ROOT}${DOCKER_FILE_NAME}
    if ( curl -o/dev/null -sfI "${URL}" ); then
        [[ -f Dockerfile ]] && rm Dockerfile
        curl "${URL}" -o Dockerfile
        echo "Docker file downloaded!"
    else
       log "Target (${URL}) not found" && exit 1
    fi
}

function generate_docker_port_mappings() {
    local expose=$(grep -i "EXPOSE" Dockerfile | cut -d' ' -f2-)
    DOCKER_PORT_MAPPING=""
    for PORT in ${expose}; do DOCKER_PORT_MAPPING+="-p ${PORT}:${PORT} "; done
}

function generate_start_script_macosx() {

    if [[ "${MOUNT_DIR}" != ${HOME}* ]]; then
        log "WARN: \"VirtualBox Shared Folder\" permissions required to mount an non ${HOME} directory"
    fi

    docker build --tag=${TARGET} - < Dockerfile

    local volume=${TARGET}-sync
    # setup docker sync
    URL=${DOCKER_ROOT}docker-sync.yml
    curl -s "${URL}" -o docker-sync.yml
    sed -i '' "s|MOUNT|${MOUNT_DIR}|" docker-sync.yml
    sed -i '' "s|TARGET|${TARGET}|" docker-sync.yml

    echo "#!/usr/bin/env bash" > start.sh
    echo "eval \"\$(docker-machine env default)\"" >> start.sh
    echo "(which docker-sync > /dev/null) || { echo \"WARN: docker-sync is not installed, filesystem syncing will not work\"; }" >> start.sh
    echo "(which docker-sync > /dev/null) && { docker-sync clean; docker-sync start; }" >> start.sh
    echo "docker run -w /home/workspace -v ${volume}:/home/workspace ${DOCKER_PORT_MAPPING} -it ${TARGET} bash" >> start.sh

    log "INFO: To force a filesystem sync run: docker-sync sync"
}

function generate_start_script_linux(){
    sg docker -c "docker build --tag=${TARGET} ."
    echo "#!/usr/bin/env bash" > start.sh
    echo "sg docker -c \"docker run -v ${MOUNT_DIR}:/home/workspace -w /home/workspace ${DOCKER_PORT_MAPPING} -it ${TARGET} bash\"" >> start.sh
}

function launch_docker_environment() {

    [[ ${OS} == "Darwin" ]] && generate_start_script_macosx
    [[ ${OS} == "Linux" ]]  && generate_start_script_linux

    chmod +x start.sh

    echo "To start env manually run: ./start.sh"
    (tty -s)
    [[ $? -eq 0 ]] && { echo "Launching docker ..."; ./start.sh; }
}

trap info EXIT

check_target
docker_setup
download_docker_file
generate_docker_port_mappings
launch_docker_environment
