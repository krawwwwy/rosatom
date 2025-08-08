#!/bin/bash
set -e
echo "🚀 Запуск деплоя проекта rosatom..."

# Проверка наличия Docker
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

# Проверка наличия Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose не установлен. Устанавливаем..."
    curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

echo "✅ Docker и Docker Compose готовы"

# Проверка, что Docker запущен
if ! docker ps &> /dev/null; then
    echo "❌ Docker не запущен. Запустите Docker."
    exit 1
fi

# Останавливаем контейнеры
echo "🛑 Останавливаем существующие контейнеры..."
docker-compose down -v

# Чистим старые образы
echo "🗑️ Удаляем старые образы..."
docker system prune -f

# Запускаем все контейнеры КРОМЕ telephone-book
echo "🔨 Запускаем основные контейнеры (без telephone-book)..."
docker-compose up --build -d postgres sso

# Ждём PostgreSQL
echo "⏳ Ждём запуска PostgreSQL..."
retries=30
for ((i=1; i<=$retries; i++)); do
    if docker-compose exec -T postgres pg_isready -U rosatom -d rosatom &> /dev/null; then
        echo "✅ PostgreSQL готов"
        break
    fi
    if [ $i -eq $retries ]; then
        echo "❌ PostgreSQL не запустился за $retries попыток"
        exit 1
    fi
    echo "⏳ Ждём PostgreSQL... попытка $i/$retries"
    sleep 2
done

# Ждём SSO
echo "⏳ Ждём запуска SSO..."
for ((i=1; i<=$retries; i++)); do
    if docker-compose exec -T sso bash -c "nc -z localhost 44044" &> /dev/null; then
        echo "✅ SSO готов"
        break
    fi
    if [ $i -eq $retries ]; then
        echo "❌ SSO не запустился за $retries попыток"
        exit 1
    fi
    echo "⏳ Ждём SSO... попытка $i/$retries"
    sleep 2
done

# Проверка таблиц
echo "🔍 Проверяем созданные таблицы..."
docker-compose exec -T postgres psql -U rosatom -d rosatom -c "\\dt"
docker-compose exec -T postgres psql -U rosatom -d rosatom -c "\\dt grafit.*"
docker-compose exec -T postgres psql -U rosatom -d rosatom -c "\\dt giredmet.*"

# Запускаем telephone-book
echo "📞 Запускаем telephone-book..."
docker-compose up --build -d telephone-book

# Статус контейнеров
echo "📊 Статус контейнеров:"
docker-compose ps

echo ""
echo "🎉 Деплой завершен успешно!"
echo "📱 Приложение: http://localhost"
echo "📚 Swagger: http://localhost/swagger/"
echo "🗄️ PostgreSQL: localhost:5432 (rosatom/rosatom)"
echo "👤 Тестовый пользователь: krawy@krawy.ru / krawy"
