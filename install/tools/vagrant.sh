#!/usr/bin/env bash

INFO=""
OS=$(uname -s)

function log(){
    INFO="${INFO}\n${1}"
}

function info(){
    echo -e "${INFO}"
}

function vagrant_setup(){
    [[ "${OS}" == "Darwin" ]] && vagrant_setup_macosx
}

function vagrant_setup_macosx(){
    which virtualbox || { echo "Installing virtualbox..."; brew cask install virtualbox; [ $? -ne 0 ] && exit 1; }
    which vagrant || { echo "Installing vagrant..."; brew cask install vagrant; [ $? -ne 0 ] && exit 1; }
    brew cask list vagrant-manager || { echo "Installing vagrant-manager..."; brew cask install vagrant-manager; [ $? -ne 0 ] && exit 1; }
    (vagrant plugin list | grep vagrant-bindfs) || { echo "Installing vagrant-bindfs..."; vagrant plugin install vagrant-bindfs; [ $? -ne 0 ] && exit 1; }
}

trap info EXIT

vagrant_setup
