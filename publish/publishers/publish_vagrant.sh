#!/usr/bin/env bash

TARGET_ENV=${1}
TARGET_OS=${2:-centos}
PREFIX=${TARGET_ENV}.${TARGET_OS}
BOX_NAME=${PREFIX}.box
BOOTSTRAP=${PREFIX}.provision.sh

# defaults
VAGRANT_PROVIDER=${VAGRANT_PROVIDER:-virtualbox}
VAGRANT_USER=${VAGRANT_USER:-noconnorie}
VAGRANT_BOX_VERSION=${VAGRANT_BOX_VERSION:-1}

function check_args(){
    [ ! -f ${BOOTSTRAP} ] && { echo "${BOOTSTRAP} does not exist, bailing!"; exit 1; }
}

function initialise(){
    echo "Initialising build dir..."
    [ ! -d tmp ] && mkdir tmp
    cp ${BOOTSTRAP} tmp/bootstrap.sh
    cp base.Vagrantfile tmp/Vagrantfile
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
    vagrant cloud publish ${VAGRANT_USER}/${PREFIX} \
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
