#!/bin/bash
CONTAINER_VERSION=1.0
cd demo
sed -i '' "s/version SED_VERSION_NUM/version ${CONTAINER_VERSION}/g" app/index.html
sed -i '' "s/profile-SED_VERSION_NUM/profile-${CONTAINER_VERSION}/g" app/server.js

if [[ $(uname -m) == "arm64" ]] && [[ $(uname) == "Darwin" ]]
then
     echo "OS: Mac Silicon detected"
     docker buildx create --name mybuilder
     docker buildx use mybuilder
     docker buildx build --platform linux/amd64,linux/arm64 --push -t habhabhabs/alex-interview:${CONTAINER_VERSION} .
     docker buildx build --platform linux/amd64,linux/arm64 --push -t habhabhabs/alex-interview:latest .
else
    echo "OS: Non-Mac Silicon detected"
    docker build -t alex-interview:${CONTAINER_VERSION} .
    docker image tag alex-interview:${CONTAINER_VERSION} habhabhabs/alex-interview:${CONTAINER_VERSION}
    docker image tag alex-interview:${CONTAINER_VERSION} habhabhabs/alex-interview:latest
    docker image push --all-tags habhabhabs/alex-interview
fi
sed -i '' "s/version ${CONTAINER_VERSION}/version SED_VERSION_NUM/g" app/index.html
sed -i '' "s/profile-${CONTAINER_VERSION}/profile-SED_VERSION_NUM/g" app/server.js
cd ..