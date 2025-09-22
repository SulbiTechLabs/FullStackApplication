#!/bin/bash

# Get OpenSearch endpoint
OPENSEARCH_ENDPOINT=$(terraform output -raw opensearch_endpoint 2>/dev/null || echo "")

if [ -z "$OPENSEARCH_ENDPOINT" ]; then
    echo "Getting OpenSearch endpoint from Terraform state..."
    OPENSEARCH_ENDPOINT=$(terraform show -json | jq -r '.values.outputs.opensearch_endpoint.value // empty')
fi

if [ -z "$OPENSEARCH_ENDPOINT" ]; then
    echo "Could not find OpenSearch endpoint. Please check your Terraform deployment."
    exit 1
fi

echo "Using OpenSearch endpoint: $OPENSEARCH_ENDPOINT"

# Update the OTEL collector config with the actual OpenSearch endpoint
sed "s|OPENSEARCH_ENDPOINT|https://$OPENSEARCH_ENDPOINT|g" otel-demo-app.yaml > otel-demo-app-configured.yaml

# Configure kubectl
echo "Configuring kubectl..."
aws eks --region us-east-1 update-kubeconfig --name src-eks-cluster

# Deploy the application
echo "Deploying OTEL demo application..."
kubectl apply -f otel-demo-app-configured.yaml

# Wait for pods to be ready
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=otel-collector -n otel --timeout=300s
kubectl wait --for=condition=ready pod -l app=flask-app -n demoapp --timeout=300s

# Get the LoadBalancer URL
echo "Getting application URL..."
kubectl get svc flask-app -n demoapp

echo ""
echo "Deployment complete!"
echo "OpenSearch Dashboard: https://$OPENSEARCH_ENDPOINT/_dashboards"
echo ""
echo "To check application logs:"
echo "kubectl logs -l app=flask-app -n demoapp"
echo "kubectl logs -l app=otel-collector -n otel"
echo ""
echo "To generate more traffic:"
echo "kubectl get svc flask-app -n demoapp"
echo "Then access the LoadBalancer URL"