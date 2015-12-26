#!/bin/sh

APPDIR=/var/tests
CURDIR=`pwd`

# =======================

IMAGES=(
    "stouts/centos7"
    "stouts/ubuntu14.04"
    "stouts/debian8"
)

tests () {
    assert $DOCKER ansible-playbook -c local --syntax-check test.yml || return 1
    assert $DOCKER ansible-playbook -c local test.yml || return 1
}

# =======================


docker info 1>/dev/null || exit 1

assert () {
    echo RUN: $@
    eval "$@" || { echo "\nFAILED: $@"; return 1; }
}


for IMAGE in "${IMAGES[@]}"
do

    ENV=`docker run -v $CURDIR:$APPDIR -w $APPDIR -dit $IMAGE /bin/bash`
    DOCKER="docker exec -it $ENV"

    echo "\n================="
    echo "START TESTS: $IMAGE"
    echo "=================\n"

    tests

    docker stop $ENV

    if [ "$?" -ne 0 ]; then
        echo FAILED
        exit 1
    fi

    echo SUCCESS

done
