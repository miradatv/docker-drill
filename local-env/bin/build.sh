#!/bin/bash


IMGPATH=`dirname "$(readlink -f "$0")"`/../drill-img

echo $IMGPATH


docker build -t drill-img $IMGPATH
