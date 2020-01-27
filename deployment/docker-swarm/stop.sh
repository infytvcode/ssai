#!/bin/bash -e

DIR=$(dirname $(readlink -f "$0"))

yml="$DIR/docker-compose.$(hostname).yml"
test -f "$yml" || yml="$DIR/docker-compose.yml"
case "$1" in
docker_compose)
    dcv="$(docker-compose --version | cut -f3 -d' ' | cut -f1 -d',')"
    mdcv="$(printf '%s\n' $dcv 1.10 | sort -r -V | head -n 1)"
    if test "$mdcv" = "1.10"; then
        echo ""
        echo "docker-compose >=1.10 is required."
        echo "Please upgrade docker-compose at https://docs.docker.com/compose/install."
        echo ""
        exit 0
    fi
    docker-compose -f "$yml" -p adi --compatibility down
    ;;
*)
    docker stack services adi
    echo "Shutting down stack adi..."
    while test -z "$(docker stack rm adi 2>&1 | grep 'Nothing found in stack')"; do
        sleep 2
    done
    ;;
esac

docker container prune -f
docker volume prune -f
docker network prune -f
