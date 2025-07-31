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
docker system prune -f

# Собираем и запускаем
echo "🏗️ Собираем образы..."
docker-compose build --no-cache

echo "🚀 Запускаем сервисы..."
docker-compose up -d

# Ждем поднятия PostgreSQL
echo "⏳ Ждем готовности PostgreSQL..."
sleep 15

# Проверяем что PostgreSQL готов
echo "🔍 Проверяем подключение к PostgreSQL..."
docker-compose exec postgres pg_isready -U rosatom -d rosatom || sleep 10

# Запускаем миграции
echo "📋 Применяем миграции..."

# Миграции для SSO (в схему public)
echo "   - SSO миграции..."
docker-compose exec -T sso sh -c "export DSN='postgres://rosatom:rosatom@postgres:5432/rosatom?sslmode=disable' && go run ./cmd/migrator/postgres/main.go -migrations-path=./migrations/postgresql" || echo "❌ Ошибка SSO миграций"

# Миграции для telephone_book (в схемы grafit и giredmet)
echo "   - Telephone book миграции..."
docker-compose exec -T telephone-book sh -c "export DSN='postgresql://rosatom:rosatom@postgres:5432/rosatom?sslmode=disable' && go run ./cmd/migrator/main.go -migrations-path=./migrations" || echo "❌ Ошибка telephone_book миграций"

echo "✅ Деплой завершен!"
echo ""
echo "🌐 Сервисы доступны по адресам:"
echo "   - Фронтенд: http://$(hostname -I | awk '{print $1}')"
echo "   - API: http://$(hostname -I | awk '{print $1}'):8080"
echo "   - Swagger: http://$(hostname -I | awk '{print $1}')/swagger/"
echo "   - SSO gRPC: $(hostname -I | awk '{print $1}'):44044"
echo ""
echo "📊 Проверить что все работает:"
echo "   curl http://$(hostname -I | awk '{print $1}')/swagger/ # должен отвечать"
echo "   docker-compose ps  # статус сервисов"
echo ""
echo "📊 Логи сервисов:"
echo "   docker-compose logs -f [sso|telephone-book|postgres|nginx]"
echo ""
echo "🔧 Управление:"
echo "   docker-compose ps      # статус сервисов"
echo "   docker-compose restart # перезапуск"
echo "   docker-compose down    # остановка" 