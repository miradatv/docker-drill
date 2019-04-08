#!/usr/bin/env bash

usage() {
    echo "Usage:"
    echo "        ${0}  -e ENVIRONMENT -p AWS_PROFILE"
    echo "Example:"
    echo "        ${0}  -e tvi -p perfil-pruebas"
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

MIRADA_REVISION=3
IMAGE_NAME=apache-drill
IMAGE_TAG=1.15.0-$MIRADA_REVISION
MIRADA_UDF_VERSION=0.6

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -e|--environment)
    TARGET_ENVIRONMENT="$2"
    shift ; shift ;;
    -p|--profile)
    AWS_PROFILE="$2"
    shift ; shift ;;
    -h|--help)
    usage
    exit 0 ;;  
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ -z "$TARGET_ENVIRONMENT" ]] || [[ -z "$AWS_PROFILE" ]]; then
    usage
    exit 127
fi

if [[ "$TARGET_ENVIRONMENT" == "tvi" ]]; then
    AWS_REGION=us-east-1
    ECR_URN=606039442951.dkr.ecr.$AWS_REGION.amazonaws.com
elif [[ "$TARGET_ENVIRONMENT" == "dgtv" ]]; then
    AWS_REGION=us-east-1
    ECR_URN=258349028160.dkr.ecr.$AWS_REGION.amazonaws.com/mirada/logiq
elif [[ "$TARGET_ENVIRONMENT" == "one" ]] || [[ "$TARGET_ENVIRONMENT" == "viya" ]]; then
    AWS_REGION=us-east-1
    ECR_URN=891435880877.dkr.ecr.$AWS_REGION.amazonaws.com/mirada/logiq
elif [[ "$TARGET_ENVIRONMENT" == "izzi" ]]; then
    AWS_REGION=us-west-2
    ECR_URN=628220405432.dkr.ecr.$AWS_REGION.amazonaws.com
else
    echo "ERROR: Invalid target environment. Valid are: tvi, dgtv, viya, one, izzi"
    usage
    exit 127
fi
echo Downloading binaries...

download_release_file tvmetrix-drill-udf $MIRADA_UDF_VERSION tvmetrix-drill-udf-$MIRADA_UDF_VERSION.jar
download_release_file tvmetrix-drill-udf $MIRADA_UDF_VERSION tvmetrix-drill-udf-${MIRADA_UDF_VERSION}-sources.jar

docker build \
    --build-arg MIRADA_UDF_VERSION=$MIRADA_UDF_VERSION \
    -t $IMAGE_NAME:$IMAGE_TAG .

$(aws ecr get-login --no-include-email --region $AWS_REGION --profile $AWS_PROFILE)
docker tag $IMAGE_NAME:$IMAGE_TAG $ECR_URN/$IMAGE_NAME:$IMAGE_TAG
docker push $ECR_URN/$IMAGE_NAME:$IMAGE_TAG
