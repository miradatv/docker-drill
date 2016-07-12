#!/bin/sh

VERSION=1.8.0-SNAPSHOT

docker build -t miradatv/apache-drill .
docker tag miradatv/apache-drill:latest miradatv/apache-drill:$VERSION
docker push miradatv/apache-drill:$VERSION
docker push miradatv/apache-drill:latest

