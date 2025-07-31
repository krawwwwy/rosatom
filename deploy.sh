#!/bin/bash

set -e

echo "🚀 Запуск деплоя проекта rosatom..."

# Проверяем что Docker установлен
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен. Устанавливаем..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
    usermod -aG docker $USER
    echo "✅ Docker установлен. Перелогиньтесь для применения прав"
fi

# Проверяем что Docker Compose установлен
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose не установлен. Устанавливаем..."
    curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

echo "✅ Docker и Docker Compose готовы"

# Останавливаем существующие контейнеры
echo "🛑 Останавливаем существующие контейнеры..."
docker-compose down --remove-orphans || true

# Удаляем старые образы
echo "🗑️ Удаляем старые образы..."
docker system prune -f || true

# Собираем и запускаем контейнеры
echo "🔨 Собираем и запускаем контейнеры..."
docker-compose up --build -d

# Ждем запуска PostgreSQL
echo "⏳ Ждем запуска PostgreSQL..."
for i in {1..30}; do
    if docker-compose exec -T postgres pg_isready -U rosatom -d rosatom > /dev/null 2>&1; then
        echo "✅ PostgreSQL готов"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ PostgreSQL не запустился за 30 попыток"
        docker-compose logs postgres
        exit 1
    fi
    echo "⏳ Ждем PostgreSQL... попытка $i/30"
    sleep 2
done

# Запускаем миграции SSO
echo "📦 Запускаем миграции SSO..."
if docker-compose exec -T sso sh -c "export DSN='postgres://rosatom:rosatom@postgres:5432/rosatom?sslmode=disable' && go run ./cmd/migrator/postgres/main.go -migrations-path=./migrations/postgresql"; then
    echo "✅ Миграции SSO выполнены"
else
    echo "❌ Ошибка миграций SSO"
    docker-compose logs sso
    exit 1
fi

# Запускаем миграции telephone_book
echo "📦 Запускаем миграции telephone_book..."
if docker-compose exec -T telephone-book sh -c "export DSN='postgresql://rosatom:rosatom@postgres:5432/rosatom?sslmode=disable' && go run ./cmd/migrator/main.go -migrations-path=./migrations"; then
    echo "✅ Миграции telephone_book выполнены"
else
    echo "❌ Ошибка миграций telephone_book"
    docker-compose logs telephone-book
    exit 1
fi

# Проверяем что таблицы созданы
echo "🔍 Проверяем созданные таблицы..."
echo "=== Основные таблицы ==="
docker-compose exec -T postgres psql -U rosatom -d rosatom -c "\\dt"
echo "=== Схема grafit ==="
docker-compose exec -T postgres psql -U rosatom -d rosatom -c "\\dt grafit.*"
echo "=== Схема giredmet ==="
docker-compose exec -T postgres psql -U rosatom -d rosatom -c "\\dt giredmet.*"

# Проверяем статус контейнеров
echo "📊 Статус контейнеров:"
docker-compose ps

echo ""
echo "🎉 Деплой завершен успешно!"
echo "📱 Приложение доступно по адресу: http://localhost"
echo "📚 Swagger документация: http://localhost/swagger/"
echo "🗄️ PostgreSQL: localhost:5432 (rosatom/rosatom)" 