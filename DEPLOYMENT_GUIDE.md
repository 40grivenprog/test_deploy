# 🚀 Deployment Guide

## 📋 **Как деплоить новую версию:**

### **1. Создание PR с изменениями**
```bash
git checkout -b feature/new-feature
# Внесите изменения в код
git add .
git commit -m "Add new feature"
git push origin feature/new-feature
```

### **2. Добавление лейбла к PR (ОБЯЗАТЕЛЬНО)**
В GitHub добавьте один из лейблов к PR:
- **`patch`** - для исправлений багов (0.0.1 → 0.0.2)
- **`minor`** - для новых функций (0.0.1 → 0.1.0)
- **`major`** - для breaking changes (0.0.1 → 1.0.0)

**⚠️ Важно:** PR не может быть смержен без версионного лейбла!

**🔒 Branch Protection:** Ветка `main` защищена и требует:
- Успешного прохождения проверки "Check Version Label"
- Минимум 1 approval от ревьюера

### **3. Мерж PR в main**
После мержа PR в main автоматически создается draft release с новой версией.

### **4. Публикация Release**
1. Перейдите в **Releases** в GitHub
2. Найдите draft release
3. Нажмите **"Publish release"**

### **5. Автоматическая сборка образа**
После публикации release автоматически:
- Собирается Docker образ
- Пушится в ECR с тегом версии
- Добавляется комментарий с информацией об образе

### **6. Обновление тега в values.yaml**
```bash
# Используйте скрипт для обновления тега
./scripts/update-image-tag.sh v1.0.0

# Или вручную обновите helm/go-app/values.yaml
# Измените tag: "v1.0.0"
```

### **7. Создание PR для деплоя**
```bash
git add helm/go-app/values.yaml
git commit -m "Update image to v1.0.0"
git push origin feature/deploy-v1.0.0
```

### **8. Автоматический деплой**
После мержа PR ArgoCD автоматически синхронизирует новую версию.

## 🔧 **Полезные команды:**

### **Проверка статуса:**
```bash
# Статус ArgoCD приложений
kubectl get applications -n argocd

# Статус подов
kubectl get pods

# Логи приложения
kubectl logs -f deployment/go-app
```

### **Доступ к приложению:**
```bash
# Port-forward для локального доступа
kubectl port-forward service/go-app 8080:8080

# Тестирование API
curl http://localhost:8080/api/hello
```

## 📊 **Мониторинг:**
- **ArgoCD UI**: `kubectl port-forward service/argocd-server -n argocd 8080:443`
- **Логи**: `kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller`

## 🏷️ **Версионирование:**
- **patch**: исправления багов (0.0.1 → 0.0.2)
- **minor**: новые функции (0.0.1 → 0.1.0)  
- **major**: breaking changes (0.0.1 → 1.0.0) 