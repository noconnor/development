#!/usr/bin/env bash

# User input
IMAGE=${1}
IMAGE_NO_REPO=$( echo ${IMAGE} | cut -d'/' -f2-)

# Defaults
DOCKER_ROOT=https://raw.githubusercontent.com/noconnor/development/master/docker/

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
    docker pull ${IMAGE}
    [ $? -ne 0 ] && { log "ERROR: Unable to pull docker image ${IMAGE}"; exit 1; }
}

function generate_start_script_macosx() {

    if [[ "${MOUNT_DIR}" != ${HOME}* ]]; then
        log "WARN: \"VirtualBox Shared Folder\" permissions required to mount an non ${HOME} directory"
    fi

    local volume=${IMAGE_NO_REPO//./-}-sync
    # setup docker sync
    URL=${DOCKER_ROOT}docker-sync.yml
    curl -s "${URL}" -o docker-sync.yml
    sed -i '' "s|MOUNT|${MOUNT_DIR}|" docker-sync.yml
    sed -i '' "s|VOLUME|${volume}|" docker-sync.yml

    echo "#!/usr/bin/env bash" > start.sh
    echo "eval \"\$(docker-machine env default)\"" >> start.sh
    echo "(which docker-sync > /dev/null) || { echo \"WARN: docker-sync is not installed, filesystem syncing will not work\"; }" >> start.sh
    echo "(which docker-sync > /dev/null) && { docker-sync clean; docker-sync start; }" >> start.sh
    echo "docker run -w /home/workspace -v ${volume}:/home/workspace -P -it ${IMAGE} bash" >> start.sh
    echo "(which docker-sync > /dev/null) && { docker-sync stop; }" >> start.sh
}

function generate_start_script_linux(){
    echo "#!/usr/bin/env bash" > start.sh
    echo "sg docker -c \"docker run -v ${MOUNT_DIR}:/home/workspace:z -w /home/workspace -P -it ${IMAGE} bash\"" >> start.sh
}

function generate_start_script() {

    [[ ${OS} == "Darwin" ]] && generate_start_script_macosx
    [[ ${OS} == "Linux" ]]  && generate_start_script_linux

    chmod +x start.sh

    log "INFO: To start env run: ./start.sh"
}

trap info EXIT

pull_docker_image
generate_start_script

exit 0
