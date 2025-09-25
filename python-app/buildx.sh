#!/bin/bash
# Login to Docker Hub before running this script
# Build and push Docker image for x86_64 architecture using buildx
APP_NAME="python-fullstack-app"
VERSION="v1.0.6"
REGISTRY="sulbiraj"

echo "Setting up buildx builder..."
docker buildx create --name multiarch --use 2>/dev/null || docker buildx use multiarch

echo "Building and pushing Docker image for x86_64 architecture..."
docker buildx build \
  --platform linux/amd64 \
  --tag ${REGISTRY}/${APP_NAME}:${VERSION} \
  --tag ${REGISTRY}/${APP_NAME}:latest \
  --push \
  .

echo "Build complete!"
echo "Image: ${REGISTRY}/${APP_NAME}:${VERSION}"
echo "Architecture: linux/amd64 (x86_64)"