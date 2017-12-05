#!/bin/bash
if [ -z "$1" ]
  then
    echo "Usage:"
    echo "------"
    echo "build.sh <ECR URL> <FILENAME> <AWS PROFILE> <REGION>"
    echo
    echo "build.sh 903337876794.dkr.ecr.us-east-1.amazonaws.com 1.8.0-TEST izziWorkbench us-east-1"
    exit;
fi

export ECR=$1
export VERSION=$2
export PROFILE=$3
export REGION=$4

HADOOP_VERSION=2.8.0-SNAPSHOT
DRILL_VERSION=1.8.0-SNAPSHOT
ALLUXIO_VERSION=1.3.1-SNAPSHOT
MIRADA_UDF_VERSION=0.4

# Download tarballs and jars from github releases (needs personal token in ~/.gitconfig)
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

echo Downloading binaries...
download_release_file hadoop $HADOOP_VERSION hadoop-$HADOOP_VERSION.tar.gz
download_release_file drill $DRILL_VERSION apache-drill-$DRILL_VERSION.tar.gz
download_release_file alluxio $ALLUXIO_VERSION alluxio-$ALLUXIO_VERSION.tar.gz
download_release_file alluxio $ALLUXIO_VERSION alluxio-core-common-$ALLUXIO_VERSION.jar
download_release_file alluxio $ALLUXIO_VERSION alluxio-core-client-$ALLUXIO_VERSION.jar
download_release_file alluxio $ALLUXIO_VERSION alluxio-underfs-s3a-$ALLUXIO_VERSION.jar
download_release_file tvmetrix-drill-udf $MIRADA_UDF_VERSION tvmetrix-drill-udf-$MIRADA_UDF_VERSION.jar
download_release_file tvmetrix-drill-udf $MIRADA_UDF_VERSION tvmetrix-drill-udf-${MIRADA_UDF_VERSION}-sources.jar

# Build docker image
docker build \
  --build-arg HADOOP_VERSION=$HADOOP_VERSION \
  --build-arg DRILL_VERSION=$DRILL_VERSION \
  --build-arg ALLUXIO_CLIENT_VERSION=$ALLUXIO_VERSION \
  --build-arg MIRADA_UDF_VERSION=$MIRADA_UDF_VERSION \
  -t apache-drill .

# Tag & Push in Amazon ECR
$(aws --profile $PROFILE ecr get-login --region $REGION --no-include-email)
docker tag apache-drill:latest $ECR/apache-drill:$VERSION
#docker tag apache-drill:latest $ECR/apache-drill:latest
docker push $ECR/apache-drill:$VERSION
#docker push $ECR/apache-drill:latest

