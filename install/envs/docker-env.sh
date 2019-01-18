#!/usr/bin/env bash

# User input
IMAGE=${1}

# Defaults
DOCKER_ROOT=https://raw.githubusercontent.com/noconnor/development/master/docker/
DOCKER_REPO=${DOCKER_REPO:-noconnorie}
DOCKER_IMAGE=${DOCKER_IMAGE:-"${DOCKER_REPO}/${IMAGE}"}

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

function pull_docker_image(){
    [[ ${OS} == "Darwin" ]] && eval "$(docker-machine env default)"
    (docker pull ${DOCKER_IMAGE}) || docker pull ${IMAGE}
    [ $? -ne 0 ] && { log "ERROR: Unable to pull docker image ${DOCKER_IMAGE} or ${IMAGE}"; exit 1; }
}

function generate_start_script_macosx() {

    if [[ "${MOUNT_DIR}" != ${HOME}* ]]; then
        log "WARN: \"VirtualBox Shared Folder\" permissions required to mount an non ${HOME} directory"
    fi

    local volume=${IMAGE//./-}-sync
    # setup docker sync
    URL=${DOCKER_ROOT}docker-sync.yml
    curl -s "${URL}" -o docker-sync.yml
    sed -i '' "s|MOUNT|${MOUNT_DIR}|" docker-sync.yml
    sed -i '' "s|VOLUME|${volume}|" docker-sync.yml

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

function generate_start_script() {

    [[ ${OS} == "Darwin" ]] && generate_start_script_macosx
    [[ ${OS} == "Linux" ]]  && generate_start_script_linux

    chmod +x start.sh

    echo "To start env manually run: ./start.sh"
    (tty -s)
    [[ $? -eq 0 ]] && { echo "Launching docker ..."; ./start.sh; }
}

trap info EXIT

pull_docker_image
generate_start_script
