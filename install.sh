#!/usr/bin/env bash

DOCKER_ROOT=https://raw.githubusercontent.com/noconnor/development/master/docker/
TARGET=${1}
DOCKER_FILE_NAME=Dockerfile.${1}
EXPOSE_PORTS=
DOCKER_PORT_MAPPING=
OS=$(uname -s)
MOUNT_DIR=$(pwd)
INFO=""
CPUS=$(sysctl hw.logicalcpu | cut -d':' -f2)
RAM=4096

function info(){
    echo "${INFO}"
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
      [ $? -ne 0 ] && { INFO+="ERROR: Docker install failed, exiting!\n"; exit 1; }
      sudo groupadd docker
      sudo usermod -aG docker ${USER}
      INFO+="WARN: logout and back in again to run docker as a non-sudo users\n"
    fi
    sudo systemctl restart docker || { INFO+="ERROR: unable to start docker systemctl process\n"; exit 1; }
}

function docker_setup_macosx() {
    docker --version
    if [ $? -ne 0 ]; then
        which brew || { INFO+="WARN: brew is required, see https://brew.sh/\n"; exit 1; }
        which virtualbox || { echo "Installing virtualbox..."; brew cask install virtualbox; [ $? -ne 0 ] && exit 1; }
        docker --version || { echo "Installing docker..."; brew install docker; [ $? -ne 0 ] && exit 1; }
        docker --version || { echo "Re-installing docker..."; brew reinstall docker; [ $? -ne 0 ] && exit 1; }
        docker-machine --version || { echo "Installing docker machine..."; brew install docker-machine; [ $? -ne 0 ] && exit 1; }
    fi

    docker-machine ls | grep default
    if [ $? -ne 0 ]; then
        echo "Creating default virtual machine..."
        docker-machine create --virtualbox-cpu-count ${CPUS} --virtualbox-memory ${RAM} --driver virtualbox default
    fi
    eval "$(docker-machine env default)"

    # work around for slow filesystem sync on mac osx
    which docker-sync || { echo "Installing docker-sync..."; gem install docker-sync; [ $? -ne 0 ] && exit 1; }

}

function download_docker_file() {
    echo "Looking for ${DOCKER_FILE_NAME} at ${DOCKER_ROOT} ..."
    URL=${DOCKER_ROOT}${DOCKER_FILE_NAME}
    if ( curl -o/dev/null -sfI "${URL}" ); then
        [ -f Dockerfile ] && rm Dockerfile
        curl "${URL}" -o Dockerfile
        echo "Docker file downloaded!"
    else
       INFO+="Target (${URL}) not found\n" && exit 1
    fi
}

function generate_docker_port_mappings() {
    local expose=$(grep -i "EXPOSE" Dockerfile | cut -d' ' -f2-)
    DOCKER_PORT_MAPPING=""
    for PORT in ${expose}; do DOCKER_PORT_MAPPING+="-p ${PORT}:${PORT} "; done
}

function generate_start_script_macosx() {

    if [[ "${MOUNT_DIR}" != ${HOME}* ]]; then
        INFO+="WARN: \"VirtualBox Shared Folder\" permissions required to mount an non ${HOME} directory\n"
    fi

    docker build --tag=${TARGET} - < Dockerfile

    local volume=shared
    # setup docker sync
    echo "version: \"2\"" > docker-sync.yml
    echo "syncs:" >> docker-sync.yml
    echo "  ${volume}:" >> docker-sync.yml
    echo "      src: '"${MOUNT_DIR}"'" >> docker-sync.yml
    echo "      sync_excludes: ['Gemfile.lock', 'Gemfile', 'config.rb', '.sass-cache', 'sass', 'sass-cache', 'composer.json' , 'bower.json', 'Gruntfile*', 'bower_components', 'node_modules', '.gitignore', '.git', '*.coffee', '*.scss', '*.sass']"  >> docker-sync.yml


    # setup start script
    echo "#!/usr/bin/env bash" > start.sh
    echo "eval \"\$(docker-machine env default)\"" >> start.sh
    echo "docker volume create ${volume}" >> start.sh
    echo "docker-sync clean" >> start.sh
    echo "docker-sync start" >> start.sh
    echo "docker run -w /home/workspace -v ${volume}:/home/workspace ${DOCKER_PORT_MAPPING} -it ${TARGET} bash" >> start.sh

    INFO+="INFO: To force a filesystem sync run: docker-sync sync"
}

function generate_start_script_linux(){
    sg docker -c "docker build --tag=${TARGET} ."
    echo "#!/usr/bin/env bash" > start.sh
    echo "sg docker -c \"docker run -v shared:/home/workspace -w /home/workspace ${DOCKER_PORT_MAPPING} -it ${TARGET} bash\"" >> start.sh
}

function launch_docker_environment() {

    [ ${OS} == "Darwin" ] && generate_start_script_macosx
    [ ${OS} == "Linux" ]  && generate_start_script_linux

    chmod +x start.sh

    echo "To start env manually run: ./start.sh"
    (tty -s)
    [ $? -eq 0 ] && { echo "Launching docker ..."; ./start.sh; }
}

trap info EXIT

docker_setup
#download_docker_file
generate_docker_port_mappings
launch_docker_environment
