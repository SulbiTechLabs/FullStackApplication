#!/bin/bash

# Build and push Docker image
APP_NAME="python-fullstack-app"
VERSION="v1.0.0"
REGISTRY="sulbiraj"

echo "Building Docker image..."
docker build -t ${APP_NAME}:${VERSION} .
docker tag ${APP_NAME}:${VERSION} ${REGISTRY}/${APP_NAME}:${VERSION}
docker tag ${APP_NAME}:${VERSION} ${REGISTRY}/${APP_NAME}:latest

echo "Pushing to registry..."
docker push ${REGISTRY}/${APP_NAME}:${VERSION}
docker push ${REGISTRY}/${APP_NAME}:latest

echo "Build complete!"
echo "Image: ${REGISTRY}/${APP_NAME}:${VERSION}"