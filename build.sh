#!/usr/bin/env bash

usage() {
    echo "Usage:"
    echo "        ${0}  -e ENVIRONMENT -p AWS_PROFILE"
    echo "Example:"
    echo "        ${0}  -e tvi -p perfil-pruebas"
}

MIRADA_REVISION=2
IMAGE_NAME=apache-drill
IMAGE_TAG=1.15.0-$MIRADA_REVISION

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

docker build -t $IMAGE_NAME:$IMAGE_TAG .

$(aws ecr get-login --no-include-email --region $AWS_REGION --profile $AWS_PROFILE)
docker tag $IMAGE_NAME:$IMAGE_TAG $ECR_URN/$IMAGE_NAME:$IMAGE_TAG
docker push $ECR_URN/$IMAGE_NAME:$IMAGE_TAG
