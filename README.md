# 🚀 Минимальный EKS деплой с ArgoCD

Дешёвое решение для деплоя приложений на AWS EKS с использованием Terraform, Helm, ArgoCD и GitOps.

## 💰 Стоимость: ~$12/месяц

- **EKS**: $10/месяц (1 нода t3.micro)
- **ECR**: $2/месяц (хранение образов)
- **NAT Gateway**: $0/месяц (только публичные подсети)

## 🏗️ Архитектура

```
┌─────────────────────────────────────────────────────────────┐
│                    AWS Infrastructure                       │
├─────────────────────────────────────────────────────────────┤
│  VPC (10.0.0.0/16)                                          │
│  ├── Public Subnet (10.0.1.0/24) - eu-central-1a           │
│  │   └── EKS Cluster + 1 Node (t3.micro)                   │
│  └── Internet Gateway                                       │
│      └── Route Table (0.0.0.0/0 → IGW)                     │
├─────────────────────────────────────────────────────────────┤
│  ECR Repository                                             │
│  └── Docker Images                                          │
├─────────────────────────────────────────────────────────────┤
│  EKS Cluster                                                │
│  ├── 1 Worker Node (t3.micro)                              │
│  ├── ArgoCD (GitOps)                                       │
│  └── Nginx (Helm Chart)                                    │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Быстрый старт

### 1. Развернуть инфраструктуру

```bash
cd infra
terraform init
terraform apply
```

### 2. Настроить kubectl и установить ArgoCD

```bash
./scripts/setup.sh
```

### 3. Создать ArgoCD Application

```bash
# Обновите repoURL в argocd-app.yaml
kubectl apply -f argocd-app.yaml
```

### 4. Настроить GitHub Secrets

В настройках репозитория добавьте:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### 5. Деплой

```bash
git push origin main
```

## 📁 Структура проекта

```
test_deploy/
├── app/
│   └── main.go                 # Go приложение
├── infra/
│   ├── main.tf                 # VPC + EKS
│   ├── ecr.tf                  # ECR репозиторий
│   ├── variables.tf            # Переменные
│   └── outputs.tf              # Outputs
├── helm/
│   └── nginx/
│       ├── Chart.yaml          # Helm чарт
│       ├── values.yaml         # Конфигурация
│       └── templates/
│           ├── deployment.yaml # K8s deployment
│           ├── service.yaml    # K8s service
│           └── _helpers.tpl    # Helper templates
├── scripts/
│   └── setup.sh               # Настройка kubectl + ArgoCD
├── .github/
│   └── workflows/
│       └── deploy.yml         # CI/CD pipeline
├── argocd-app.yaml            # ArgoCD Application
├── Dockerfile                 # Docker образ
└── README.md                  # Документация
```

## 🎛️ Управление через ArgoCD

### Доступ к ArgoCD UI

```bash
# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Открыть в браузере
# https://localhost:8080
# Username: admin
# Password: [получить через setup.sh]
```

### Основные действия в ArgoCD

- **Sync** - принудительная синхронизация
- **Refresh** - обновление состояния
- **Rollback** - откат к предыдущей версии
- **Edit** - изменение конфигурации

## 🌐 Доступ к приложению

```bash
# Получить IP ноды
kubectl get nodes -o wide

# Доступ к nginx
# http://[NODE_IP]:30080
```

## 🔧 Настройка

### Изменение региона

```bash
# В infra/variables.tf
variable "aws_region" {
  default = "us-east-1"  # Измените на нужный регион
}
```

### Масштабирование

```bash
# В helm/nginx/values.yaml
replicaCount: 3  # Увеличьте количество реплик
```

### Добавление новых приложений

1. Создайте новый Helm чарт в `helm/`
2. Создайте ArgoCD Application
3. Примените через `kubectl apply -f`

## 🛠️ Устранение неполадок

### Проверка статуса кластера

```bash
kubectl cluster-info
kubectl get nodes
```

### Проверка ArgoCD

```bash
kubectl get pods -n argocd
kubectl logs -n argocd deployment/argocd-server
```

### Проверка приложения

```bash
kubectl get pods
kubectl logs deployment/nginx-nginx
```

## 🧹 Очистка

```bash
# Удалить ArgoCD Application
kubectl delete -f argocd-app.yaml

# Удалить ArgoCD
helm uninstall argocd -n argocd

# Удалить инфраструктуру
cd infra
terraform destroy
```

## 📚 Полезные команды

```bash
# Получить ArgoCD пароль
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Просмотр логов ArgoCD
kubectl logs -n argocd deployment/argocd-server

# Список приложений ArgoCD
kubectl get applications -n argocd

# Синхронизация приложения
kubectl patch application nginx-app -n argocd --type='merge' -p='{"spec":{"syncPolicy":{"automated":{"prune":true,"selfHeal":true}}}}'
```

## 🎯 Преимущества

✅ **Дёшево**: $12/месяц вместо $60+  
✅ **Просто**: Минимальная настройка  
✅ **GitOps**: Автоматический деплой  
✅ **Масштабируемо**: Легко добавить ноды  
✅ **Безопасно**: Security Groups защищают  

## 📞 Поддержка

При возникновении проблем:
1. Проверьте логи: `kubectl logs`
2. Проверьте статус: `kubectl get all`
3. Проверьте ArgoCD: `kubectl get applications -n argocd` 