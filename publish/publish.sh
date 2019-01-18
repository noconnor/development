#!/usr/bin/env bash

function usage(){
    echo ""
}

# Defaults
PROVIDER="vagrant"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PUBLISHERS_DIR="${DIR}/publishers"

POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case ${key} in
        --provider)
        PROVIDER="$2"
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

[ -z ${TARGET_IMAGE+x} ] && { echo "Target image must be provided"; usage; exit 1; }

function publish(){
    local publish_script="${PUBLISHERS_DIR}/${PROVIDER}-publish.sh"
    [ ! -f ${publish_script} ] && { echo "Could not find publish script (${publish_script})"; exit 1; }
    chmod +x ${publish_script}
    echo "Executing publish script ${publish_script}..."
    ${publish_script} ${TARGET_IMAGE}
}

publish
