#!/usr/bin/env bash

TARGET_ENV=${1}
TARGET_OS=${2:-centos}

DOCKER_ROOT=https://raw.githubusercontent.com/noconnor/development/master/docker/
DOCKER_REPO=${DOCKER_REPO:-noconnorie}
DOCKER_IMAGE=${DOCKER_IMAGE:-"${DOCKER_REPO}/${TARGET_ENV}.${TARGET_OS}"}

OS=$(uname -s)
MOUNT_DIR=${MOUNT_DIR:-$(pwd)}
RAM=4096
INFO=""

function log(){
    INFO="${INFO}\n${1}"
}

function info(){
    echo -e "${INFO}"
}

function generate_start_script_macosx() {

    if [[ "${MOUNT_DIR}" != ${HOME}* ]]; then
        log "WARN: \"VirtualBox Shared Folder\" permissions required to mount an non ${HOME} directory"
    fi

    eval "$(docker-machine env default)"

    local volume=${TARGET_ENV}-sync
    # setup docker sync
    URL=${DOCKER_ROOT}docker-sync.yml
    curl -s "${URL}" -o docker-sync.yml
    sed -i '' "s|MOUNT|${MOUNT_DIR}|" docker-sync.yml
    sed -i '' "s|TARGET|${TARGET_ENV}|" docker-sync.yml

    echo "#!/usr/bin/env bash" > start.sh
    echo "eval \"\$(docker-machine env default)\"" >> start.sh
    echo "(which docker-sync > /dev/null) || { echo \"WARN: docker-sync is not installed, filesystem syncing will not work\"; }" >> start.sh
    echo "(which docker-sync > /dev/null) && { docker-sync clean; docker-sync start; }" >> start.sh
    echo "docker run -w /home/workspace -v ${volume}:/home/workspace -P -it ${DOCKER_IMAGE} bash" >> start.sh
    echo "(which docker-sync > /dev/null) && { docker-sync stop; }" >> start.sh
}

function generate_start_script_linux(){
    echo "#!/usr/bin/env bash" > start.sh
    echo "sg docker -c \"docker run -v ${MOUNT_DIR}:/home/workspace:z -w /home/workspace -P -it ${DOCKER_IMAGE} bash\"" >> start.sh
}

function set_docker_environment() {

    [[ ${OS} == "Darwin" ]] && generate_start_script_macosx
    [[ ${OS} == "Linux" ]]  && generate_start_script_linux

    docker pull ${DOCKER_IMAGE}
    [ $? -ne 0 ] && { log "ERROR: unable to pull docker image ${DOCKER_IMAGE}"; exit 1; }

    chmod +x start.sh

    echo "To start env manually run: ./start.sh"
    (tty -s)
    [[ $? -eq 0 ]] && { echo "Launching docker ..."; ./start.sh; }
}

trap info EXIT

set_docker_environment
