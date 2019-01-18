#!/usr/bin/env bash

TARGET_ENV=${1}
TARGET_OS=${2:-centos}
PREFIX=${TARGET_ENV}.${TARGET_OS}
BOOTSTRAP=${PREFIX}.provision.sh
OS=$(uname -s)

# defaults
DOCKER_USER=${DOCKER_USER:-noconnorie}
DOCKER_IMG_VERSION=${DOCKER_IMG_VERSION:-latest}

function check_args(){
    [ ! -f ${BOOTSTRAP} ] && { echo "${BOOTSTRAP} does not exist, bailing!"; exit 1; }
}

function initialise(){
    echo "Initialising build dir..."
    [ ! -d tmp ] && mkdir tmp
    cp ${BOOTSTRAP} tmp/bootstrap.sh
    cp base.Dockerfile tmp/Dockerfile
    local base_box=$(grep DOCKER_BASE tmp/bootstrap.sh| sed 's|# DOCKER_BASE ||g')
    local expose=$(grep DOCKER_EXPOSE tmp/bootstrap.sh| sed 's|# DOCKER_EXPOSE ||g')
    sed -i '' 's|BASE_BOX|'${base_box}'|g' tmp/Dockerfile
    [ -z ${expose+} ] && echo "EXPOSE ${expose}" >> tmp/Dockerfile
    cd tmp
}

function cleanup(){
    [ -d tmp ] && rm -rf tmp
}

function package_image(){
    [[ ${OS} == "Darwin" ]] && { eval "$(docker-machine env default)"; docker build --tag=${PREFIX} .; }
    [[ ${OS} == "Linux" ]] && sg docker -c "docker build --tag=${PREFIX} ."
}

function publish(){
    echo "publishing..."
    docker login
    docker tag ${PREFIX} ${DOCKER_USER}/${PREFIX}:${DOCKER_IMG_VERSION}
    docker push ${DOCKER_USER}/${PREFIX}:${DOCKER_IMG_VERSION}
    docker image rm ${PREFIX}
}

trap cleanup EXIT
(
    check_args
    initialise
    package_image
    publish
)
