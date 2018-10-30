#!/bin/bash

IMGPATH=`dirname "$(readlink -f "$0")"`/../drill-img

docker build -t drill-img $IMGPATH
