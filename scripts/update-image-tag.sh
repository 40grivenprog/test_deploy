#!/bin/bash

# Скрипт для обновления тега образа в values.yaml
# Использование: ./scripts/update-image-tag.sh <tag>

if [ $# -eq 0 ]; then
    echo "❌ Ошибка: Укажите тег образа"
    echo "Использование: ./scripts/update-image-tag.sh <tag>"
    echo "Пример: ./scripts/update-image-tag.sh v1.0.0"
    exit 1
fi

TAG=$1
VALUES_FILE="helm/go-app/values.yaml"

echo "🔄 Обновляю тег образа на: $TAG"

# Обновляем тег в values.yaml
sed -i.bak "s|tag: \".*\"|tag: \"$TAG\"|" $VALUES_FILE

# Проверяем изменения
echo "📝 Изменения в $VALUES_FILE:"
git diff $VALUES_FILE

echo ""
echo "✅ Тег обновлен!"
echo "📋 Следующие шаги:"
echo "1. git add helm/go-app/values.yaml"
echo "2. git commit -m \"Update image to $TAG\""
echo "3. git push"
echo "4. ArgoCD автоматически синхронизирует изменения" 