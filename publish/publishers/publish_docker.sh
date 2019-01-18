#!/usr/bin/env bash

IMAGE=${1} # i.e. react.centos

# defaults
PROVISIONERS_DIR="../provisioners"
TEMPLATES_DIR="../templates"
DOCKER_USER=${DOCKER_USER:-noconnorie}
DOCKER_IMG_VERSION=${DOCKER_IMG_VERSION:-latest}
BOOTSTRAP=${PROVISIONERS_DIR}/${IMAGE}.provision.sh
DOCKER_BASE=${TEMPLATES_DIR}/base.Dockerfile
OS=$(uname -s)


function check_args(){
    [ ! -f ${BOOTSTRAP} ] && { echo "${BOOTSTRAP} does not exist, bailing!"; exit 1; }
}

function initialise(){
    echo "Initialising build dir..."
    [ ! -d tmp ] && mkdir tmp
    cp ${BOOTSTRAP} tmp/bootstrap.sh
    cp ${DOCKER_BASE} tmp/Dockerfile
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
    [[ ${OS} == "Darwin" ]] && package_image_maxosx
    [[ ${OS} == "Linux" ]] && package_image_linux
}

function package_image_maxosx(){
    eval "$(docker-machine env default)"
    ( docker build --tag=${IMAGE} . ) || { echo "ERROR: Docker build failed!"; exit 1; }

}

function package_image_linux(){
    ( sg docker -c "docker build --tag=${IMAGE} ." ) || { echo "ERROR: Docker build failed!"; exit 1; }
}

function publish(){
    echo "publishing..."
    docker login
    docker tag ${IMAGE} ${DOCKER_USER}/${IMAGE}:${DOCKER_IMG_VERSION}
    docker push ${DOCKER_USER}/${IMAGE}:${DOCKER_IMG_VERSION}
    docker image rm ${IMAGE}
}

trap cleanup EXIT
(
    check_args
    initialise
    package_image
    publish
)
