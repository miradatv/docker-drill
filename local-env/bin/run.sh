#!/bin/bash

usage() {
    echo "Usage:"
    echo "    ./run.sh DRILL_STORAGE_DIR"
}

if [ -z "$1" ]; then
    usage
    exit 1
fi

if [ ! -d "$1" ]; then
    mkdir -p "'"$1"'"
    echo "Created directory "$1

fi

docker run -idt --rm \
	--name drill \
	--hostname drill \
	--volume $1:/drill-data \
	drill-img
	
