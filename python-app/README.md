# Python Full Stack Application

A scalable Python Flask application deployed on EKS with RDS PostgreSQL backend.

## Features

- **REST API** with user management endpoints
- **Database Integration** with PostgreSQL (RDS)
- **Health Checks** for Kubernetes probes
- **LoadBalancer Service** for external access
- **Production Ready** with Gunicorn WSGI server

## API Endpoints

- `GET /` - Welcome message
- `GET /health` - Health check endpoint
- `GET /api/users` - List all users
- `POST /api/users` - Create new user

## Quick Start

### 1. Build Docker Image
```bash
./build.sh
```

### 2. Update Image in Deployment
Edit `k8s/deployment.yaml` and replace `your-registry/python-app:latest` with your actual image.

### 3. Update Database Configuration
Edit `k8s/configmap.yaml` with your RDS endpoint and credentials.

### 4. Deploy to EKS
```bash
./deploy.sh
```

## Environment Variables

- `DB_HOST` - PostgreSQL host (from ConfigMap)
- `DB_NAME` - Database name (from ConfigMap)
- `DB_USER` - Database user (from ConfigMap)
- `DB_PASSWORD` - Database password (from Secret)
- `DB_PORT` - Database port (from ConfigMap)

## Scaling

To scale the application:
```bash
kubectl scale deployment python-app --replicas=5 -n fullstack-app
```

## Monitoring

Check application status:
```bash
kubectl get pods -n fullstack-app
kubectl get svc -n fullstack-app
kubectl logs -f deployment/python-app -n fullstack-app
```