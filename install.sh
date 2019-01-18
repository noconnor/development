#!/usr/bin/env bash

function usage() {
    echo ""
}

# Sources
FRAMEWORKS_ROOT=https://raw.githubusercontent.com/noconnor/development/master/install/runtimes
ENVS_ROOT=https://raw.githubusercontent.com/noconnor/development/master/install/envs

# Defaults
RUNTIME="vagrant"

POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case ${key} in
        --framework)
        FRAMEWORK="$2"
        shift # past argument
        shift # past value
        ;;
        --runtime)
        RUNTIME="$2"
        shift # past argument
        shift # past value
        ;;
        --image)
        TARGET_IMAGE="$2"
        shift
        shift
        ;;
        *)
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done

function install_framework(){
    [ -z ${FRAMEWORK+x} ] && return # nothing to do
    local framework_url="${FRAMEWORKS_ROOT}/${FRAMEWORK}-install.sh"
    ( curl -o/dev/null -sfI "${framework_url}" ) || { echo "ERROR: ${FRAMEWORK} install script not found"; exit 1; }
    echo "Installing ${FRAMEWORK}.."
    curl -o- ${framework_url} | bash
    [ $? -ne 0 ] && { echo "ERROR: framework install failed!"; exit 1; }
}

function install_environment() {
    [ -z ${TARGET_IMAGE+x} ] && return # nothing to do
    local runtime_url="${ENVS_ROOT}/${RUNTIME}-env.sh"
    ( curl -o/dev/null -sfI "${runtime_url}" ) || { echo "ERROR: ${RUNTIME} install script not found"; exit 1; }
    echo "Attempting to install ${TARGET_IMAGE} using ${RUNTIME}.."
    curl -o- ${runtime_url} | bash -s -- ${TARGET_IMAGE}
    [ $? -ne 0 ] && { echo "ERROR: environment install failed!"; exit 1; }
}

install_framework
install_environment

echo "Install complete!"

exit 0
