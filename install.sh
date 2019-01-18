#!/usr/bin/env bash

function usage() {
    echo ""
}

# Sources
FRAMEWORKS_ROOT=https://raw.githubusercontent.com/noconnor/development/master/install/tools
ENVS_ROOT=https://raw.githubusercontent.com/noconnor/development/master/install/envs

# Defaults
PROVIDER="vagrant"
TARGET_OS="centos"

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
        --provider)
        PROVIDER="$2"
        shift # past argument
        shift # past value
        ;;
        --env)
        TARGET_ENV="$2"
        shift
        shift
        ;;
        --os)
        TARGET_OS="$2"
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
    [ -z ${FRAMEWORK+} ] && return # nothing to do
    local framework_url="${FRAMEWORKS_ROOT}/${FRAMEWORK}.sh"
    ( curl -o/dev/null -sfI "${framework_url}" ) || { log "ERROR: ${FRAMEWORK} install script not found"; exit 1; }
    echo "Installing ${FRAMEWORK}.."
    curl -o- ${framework_url} | bash
    [ $? -ne 0 ] && { echo "ERROR: framework install failed!"; exit 1; }
}

function install_environment() {
    [ -z ${TARGET_ENV+} ] && { echo "No target environment specified, skipping"; return; }
    local provider_env_url="${ENVS_ROOT}/${PROVIDER}-env.sh"
    ( curl -o/dev/null -sfI "${provider_env_url}" ) || { log "ERROR: ${PROVIDER} install script not found"; exit 1; }
    echo "Attempting to install ${TARGET_ENV} using ${PROVIDER}.."
    curl -o- ${provider_env_url} | bash -s -- ${TARGET_ENV} ${TARGET_OS}
    [ $? -ne 0 ] && { echo "ERROR: environment install failed!"; exit 1; }
}

install_framework
install_environment
