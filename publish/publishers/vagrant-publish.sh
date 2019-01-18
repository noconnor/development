#!/usr/bin/env bash

IMAGE=${1} # i.e. python3.centos
IMAGE_NO_REPO=$( echo ${IMAGE} | cut -d'/' -f2-)

# defaults
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROVISIONERS_DIR="${DIR}/../provisioners"
TEMPLATES_DIR="${DIR}/../templates"
BOX_NAME=${IMAGE_NO_REPO}.box
BOOTSTRAP=${PROVISIONERS_DIR}/${IMAGE_NO_REPO}.provision.sh
VAGRANT_PROVIDER=${VAGRANT_PROVIDER:-virtualbox}
VAGRANT_BOX_VERSION=${VAGRANT_BOX_VERSION:-1}
VAGRANT_BASE=${TEMPLATES_DIR}/base.Vagrantfile

function check_args(){
    [ ! -f ${BOOTSTRAP} ] && { echo "${BOOTSTRAP} does not exist, bailing!"; exit 1; }
}

function initialise(){
    echo "Initialising build dir..."
    [ ! -d tmp ] && mkdir tmp
    cp ${BOOTSTRAP} tmp/bootstrap.sh
    cp ${VAGRANT_BASE} tmp/Vagrantfile
    local base_box=$(grep VAGRANT_BASE tmp/bootstrap.sh| sed 's|# VAGRANT_BASE ||g')
    sed -i '' 's|BASE_BOX|'${base_box}'|g' tmp/Vagrantfile
    cd tmp
}

function cleanup(){
    [ -d tmp ] && rm -rf tmp
}

function package_box(){
    vagrant up
    vagrant package --output ${BOX_NAME}
}

function publish(){
    vagrant cloud auth login
    vagrant cloud publish ${IMAGE} \
        ${VAGRANT_BOX_VERSION} \
        ${VAGRANT_PROVIDER} \
        "${BOX_NAME}" \
        -d "Development box" \
        --release
    [ $? -eq 0 ] && vagrant destroy
}

trap cleanup EXIT
(
    check_args
    initialise
    package_box
    publish
)
