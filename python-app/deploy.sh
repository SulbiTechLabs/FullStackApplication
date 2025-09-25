#!/bin/bash

echo "Deploying Python Full Stack Application to EKS..."

# Apply Kubernetes manifests
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/python-app -n fullstack-app

echo "Getting service information..."
kubectl get svc python-app-service -n fullstack-app

echo "Deployment complete!"
echo "Check pods: kubectl get pods -n fullstack-app"
echo "Check service: kubectl get svc -n fullstack-app"