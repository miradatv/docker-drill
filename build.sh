#!/bin/sh

VERSION=1.9.0-SNAPSHOT-pr-455

docker build -t miradatv/apache-drill .
docker tag miradatv/apache-drill:latest miradatv/apache-drill:$VERSION
docker push miradatv/apache-drill:$VERSION
docker push miradatv/apache-drill:latest

