#!/bin/bash

# Скрипт для обновления тега образа в values.yaml
# Использование: ./scripts/update-image-tag.sh <tag> [dev|prod]

if [ $# -eq 0 ]; then
    echo "❌ Ошибка: Укажите тег образа"
    echo "Использование: ./scripts/update-image-tag.sh <tag> [dev|prod]"
    echo "Пример: ./scripts/update-image-tag.sh v1.0.0 prod"
    echo "Пример: ./scripts/update-image-tag.sh v1.0.0 dev"
    exit 1
fi

TAG=$1
ENVIRONMENT=${2:-prod}  # По умолчанию prod

if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
    echo "❌ Ошибка: Окружение должно быть 'dev' или 'prod'"
    exit 1
fi

VALUES_FILE="helm/go-app/values-${ENVIRONMENT}.yaml"

echo "🔄 Обновляю тег образа на: $TAG в окружении: $ENVIRONMENT"

# Обновляем тег в values файле
sed -i.bak "s|tag: \".*\"|tag: \"$TAG\"|" $VALUES_FILE

# Проверяем изменения
echo "📝 Изменения в $VALUES_FILE:"
git diff $VALUES_FILE

echo ""
echo "✅ Тег обновлен!"
echo "📋 Следующие шаги:"
echo "1. git add $VALUES_FILE"
echo "2. git commit -m \"Update $ENVIRONMENT image to $TAG\""
echo "3. git push"
echo "4. ArgoCD ApplicationSet автоматически синхронизирует изменения в namespace $ENVIRONMENT" 