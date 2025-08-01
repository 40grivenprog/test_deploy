# 🚀 Test Deploy - Go API с Kubernetes и ArgoCD

Минимальная настройка деплоя Go API с использованием:
- **AWS EKS** (2x t3.small ноды)
- **ArgoCD** для GitOps
- **Helm** для управления приложением
- **GitHub Actions** для CI/CD
- **ECR** для Docker образов

## 📋 Быстрый старт

### 1. Доступ к приложению

```bash
# Port-forward для Go API
kubectl port-forward svc/go-app 8080:8080

# Приложение будет доступно по адресу:
# http://localhost:8080
```

**Эндпоинты:**
- `GET /` - главная страница
- `GET /api/health` - проверка здоровья
- `GET /api/hello` - приветствие

### 2. Доступ к ArgoCD UI

```bash
# Port-forward для ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443

# ArgoCD будет доступен по адресу:
# https://localhost:8080
```

**Credentials для ArgoCD:**
- **Username:** `admin`
- **Password:** `tVzwi7bZf2gsw8Uy`

> 💡 **Получить пароль заново:**
> ```bash
> kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
> ```

## 🏗️ Архитектура

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │    │   GitHub Actions│    │   AWS ECR       │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │   PR with   │ │───▶│ │ Build Image │ │───▶│ │ Docker      │ │
│ │   Labels    │ │    │ │ & Push      │ │    │ │ Images      │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                        │
                                ▼                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   ArgoCD        │    │   EKS Cluster   │    │   Go API       │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ GitOps      │ │◀───│ │ 2x t3.small │ │    │ │ Running on  │ │
│ │ Sync        │ │    │ │ Nodes       │ │    │ │ Port 30081  │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔄 CI/CD Pipeline

### Workflow с семантическим версионированием:

1. **Создание PR** с лейблом (`major`, `minor`, `patch`)
2. **Мерж в main** → автоматическое создание draft release
3. **Публикация release** → сборка и пушинг Docker образа в ECR
4. **Обновление Helm values** → ручное обновление тега образа
5. **ArgoCD синхронизация** → автоматический деплой новой версии

### GitHub Actions Workflows:

- **`.github/workflows/check-release.yml`** - проверка наличия версионного лейбла
- **`.github/workflows/create-release.yml`** - создание draft release
- **`.github/workflows/build-image.yml`** - сборка и пушинг образа
- **`.github/workflows/setup-branch-protection.yml`** - настройка защиты ветки

## 🛠️ Команды для управления

### Проверка статуса

```bash
# Статус кластера
kubectl get nodes

# Статус ArgoCD
kubectl get pods -n argocd
kubectl get application -n argocd

# Статус приложения
kubectl get pods -l app.kubernetes.io/name=go-app
kubectl get svc -l app.kubernetes.io/name=go-app
```

### Логи и отладка

```bash
# Логи приложения
kubectl logs -l app.kubernetes.io/name=go-app

# Логи ArgoCD
kubectl logs -n argocd deployment/argocd-server

# Описание приложения ArgoCD
kubectl describe application go-app -n argocd
```

### Обновление приложения

```bash
# Обновить тег образа в values.yaml
./scripts/update-image-tag.sh v1.0.0

# Применить изменения
git add helm/go-app/values.yaml
git commit -m "Update image to v1.0.0"
git push
```

## 📁 Структура проекта

```
test_deploy/
├── app/                    # Go приложение
│   └── main.go
├── infra/                  # Terraform конфигурация
│   ├── main.tf
│   ├── ecr.tf
│   └── variables.tf
├── helm/                   # Helm чарты
│   └── go-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
├── scripts/                # Скрипты
│   ├── setup.sh
│   └── update-image-tag.sh
├── .github/workflows/      # GitHub Actions
│   ├── check-release.yml
│   ├── create-release.yml
│   ├── build-image.yml
│   └── setup-branch-protection.yml
├── argocd-app.yaml         # ArgoCD Application
└── DEPLOYMENT_GUIDE.md     # Подробное руководство
```

## 💰 Стоимость

**AWS Free Tier (первый месяц):**
- EKS: бесплатно
- 2x t3.small: бесплатно
- ECR: бесплатно

**После Free Tier (ежемесячно):**
- 2x t3.small: ~$20
- EKS: ~$10
- ECR: ~$1-5 (зависит от использования)

**Итого:** ~$30-35/месяц

## 🔧 Требования

- **AWS CLI** настроен
- **kubectl** установлен
- **helm** установлен
- **terraform** установлен
- **docker** установлен

## 🚨 Troubleshooting

### ArgoCD не синхронизируется
```bash
# Проверить статус
kubectl get application -n argocd

# Проверить логи
kubectl logs -n argocd deployment/argocd-application-controller

# Принудительная синхронизация
kubectl patch application go-app -n argocd --type='merge' -p='{"spec":{"syncPolicy":{"automated":{"prune":true,"selfHeal":true}}}}'
```

### Приложение не отвечает
```bash
# Проверить поды
kubectl get pods -l app.kubernetes.io/name=go-app

# Проверить логи
kubectl logs -l app.kubernetes.io/name=go-app

# Проверить сервис
kubectl get svc -l app.kubernetes.io/name=go-app
```

### Проблемы с EKS
```bash
# Обновить kubeconfig
aws eks update-kubeconfig --region eu-central-1 --name test-deploy-cluster

# Проверить статус кластера
aws eks describe-cluster --name test-deploy-cluster --region eu-central-1
```

## 📚 Полезные ссылки

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [EKS Documentation](https://docs.aws.amazon.com/eks/)
- [GitHub Actions](https://docs.github.com/en/actions)

## 🤝 Contributing

1. Создайте PR с лейблом (`major`, `minor`, `patch`)
2. Дождитесь проверок
3. После мержа создастся draft release
4. Опубликуйте release для сборки образа
5. Обновите `helm/go-app/values.yaml` с новым тегом

---

**🎯 Цель проекта:** Демонстрация минимальной, но полнофункциональной CI/CD pipeline с использованием современных инструментов DevOps. 