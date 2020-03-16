#!/usr/bin/env bash

usage() {
    echo "Usage:"
    echo "    ${0}"
}

download_release_file () {
  if [[ ! -f $3 ]]; then
      local token=$(git config --get github.token)
      local url=$(curl --silent \
                       --header "Authorization: token $token" \
                       --header "Accept: application.vnd.github.v3.raw" \
                       https://api.github.com/repos/miradatv/$1/releases \
                  | jq ".[] | select(.name == \"$2\")" \
                  | jq ".assets[] | select(.name == \"$3\")" \
                  | jq -cr ".url")
      wget -q \
           --continue \
           --show-progress \
           --auth-no-challenge \
           --header="Accept: application/octet-stream" \
           $(echo $url | sed "s%https://%https://${token}:@%") \
           -O $3
  else
      echo "Already downloaded file: $3, not downloading again"
  fi
}

MIRADA_REVISION=5
IMAGE_NAME=apache-drill
IMAGE_TAG=1.16.0-$MIRADA_REVISION
MIRADA_UDF_VERSION=0.9


ECR_URN=docker-registry.mirada.lab:5000/logiq
echo Downloading binaries...


download_release_file tvmetrix-drill-udf $MIRADA_UDF_VERSION tvmetrix-drill-udf-$MIRADA_UDF_VERSION.jar
download_release_file tvmetrix-drill-udf $MIRADA_UDF_VERSION tvmetrix-drill-udf-${MIRADA_UDF_VERSION}-sources.jar


docker build \
    --build-arg MIRADA_UDF_VERSION=$MIRADA_UDF_VERSION \
    -t $IMAGE_NAME:$IMAGE_TAG .


docker tag $IMAGE_NAME:$IMAGE_TAG $ECR_URN/$IMAGE_NAME:$IMAGE_TAG
docker push $ECR_URN/$IMAGE_NAME:$IMAGE_TAG
