#!/usr/bin/env bash

TARGET_ENV=${1}
TARGET_OS=${2:-centos}
PREFIX=${TARGET_ENV}.${TARGET_OS}
BOOTSTRAP=${PREFIX}.provision.sh
OS=$(uname -s)

function check_args(){
    [ ! -f ${BOOTSTRAP} ] && { echo "${BOOTSTRAP} does not exist, bailing!"; exit 1; }
}

function initialise(){
    echo "Initialising build dir..."
    [ ! -d tmp ] && mkdir tmp
    cp ${BOOTSTRAP} tmp/bootstrap.sh
    cp base.Dockerfile tmp/Dockerfile
    local base_box=$(grep DOCKER_BASE tmp/bootstrap.sh| cut -d'-' -f2)
    sed -i '' 's|BASE_BOX|'${base_box}'|g' tmp/Dockerfile
    cd tmp
}

function cleanup(){
    [ -d tmp ] && rm -rf tmp
}

function package_image(){
    [[ ${OS} == "Darwin" ]] && { eval "$(docker-machine env default)"; docker build --tag=${PREFIX} - < Dockerfile; }
    [[ ${OS} == "Linux" ]] && sg docker -c "docker build --tag=${PREFIX} - < Dockerfile"
}

function publish(){
    echo "publishing..."
}

#trap cleanup EXIT
(
    check_args
    initialise
    package_image
    publish
)
