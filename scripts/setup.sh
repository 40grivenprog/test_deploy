#!/bin/bash

set -e

echo "🚀 Setting up minimal EKS deployment..."

# Get cluster info
CLUSTER_NAME=$(cd infra && terraform output -raw cluster_name)
AWS_REGION=$(cd infra && terraform output -raw aws_region 2>/dev/null || echo "eu-central-1")

echo "📡 Configuring kubectl for cluster: $CLUSTER_NAME"

# Update kubeconfig
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

# Verify connection
kubectl cluster-info

echo "✅ kubectl configured successfully!"

# Install ArgoCD
echo "📦 Installing ArgoCD..."

# Add ArgoCD Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Create ArgoCD namespace
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
helm install argocd argo/argo-cd \
  --namespace argocd \
  --set server.extraArgs="{--insecure}" \
  --set server.ingress.enabled=false \
  --wait

echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

# Get ArgoCD admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "🎉 Setup complete!"
echo ""
echo "📋 ArgoCD Admin Password: $ARGOCD_PASSWORD"
echo ""
echo "💡 To access ArgoCD:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   Then visit: https://localhost:8080"
echo "   Username: admin"
echo "   Password: $ARGOCD_PASSWORD"
echo ""
echo "🌐 To access nginx:"
echo "   kubectl get nodes -o wide"
echo "   Then visit: http://[NODE_IP]:30080"
echo ""
echo "📝 Next steps:"
echo "   1. Create ArgoCD Application for nginx"
echo "   2. Set up CI/CD pipeline"
echo "   3. Deploy your application" 