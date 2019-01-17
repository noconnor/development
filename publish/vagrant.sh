#!/usr/bin/env bash

[ -z ${VAGRANT_TOKEN+x} ] && { echo "Vagrant VAGRANT_TOKEN must be set!"; exit 1; }

TARGET_ENV=${1}
TARGET_OS=${2:-centos}
BOX_NAME=${TARGET_ENV}.${TARGET_OS}
VAGRANT_FILE=https://raw.githubusercontent.com/noconnor/development/master/vagrant/${TARGET_ENV}.${TARGET_OS}.Vagrantfile

# defaults
PROVIDER_NAME=${PROVIDER_NAME:-virtualbox}
VAGRANT_USER=${VAGRANT_USER:-noconnorie}
BOX_VERSION=${BOX_VERSION:-1}

VAGRANT_CLOUD="https://vagrantcloud.com/api/v1/box/${VAGRANT_USER}/${BOX_NAME}/version/${BOX_VERSION}/provider/${PROVIDER_NAME}/upload?access_token=${VAGRANT_TOKEN}"

function download_vagrant_file(){
    echo "Downloading vagrant file ${VAGRANT_FILE}"
    if ( curl -o/dev/null -sfI "${VAGRANT_FILE}" ); then
        [[ -f Dockerfile ]] && rm Vagrantfile
        curl "${VAGRANT_FILE}" -o Vagrantfile
        echo "Vagrant file downloaded!"
    else
       echo "ERROR: Target (${VAGRANT_FILE}) not found" && exit 1
    fi
}

function package_box(){
    vagrant up
    vagrant package --output ${BOX_NAME}.box
}

function publish(){
    local upload_path=$(curl "${VAGRANT_CLOUD}"})
    local parsed_path=$(echo "${upload_path}" | grep "upload_path:" | cut -d":" -f2,3 | sed 's/\s//g')
    curl -X PUT --upload-file "${BOX_NAME}" "${parsed_path}"
}

#download_vagrant_file
package_box
#publish
