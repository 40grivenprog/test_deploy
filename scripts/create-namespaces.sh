#!/bin/bash

# Создание namespace для dev и prod
echo "🔧 Создаю namespace dev и prod..."

kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -

# Добавляем лейблы
kubectl label namespace dev environment=development project=test-deploy
kubectl label namespace prod environment=production project=test-deploy

echo "✅ Namespace созданы!"
echo "📋 Список namespace:"
kubectl get namespaces --show-labels | grep -E "(dev|prod)" 