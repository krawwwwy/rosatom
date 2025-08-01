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

# Проверяем что Docker запущен
if ! docker ps &> /dev/null; then
    echo "❌ Docker не запущен. Запустите Docker."
    exit 1
fi

# Останавливаем существующие контейнеры
echo "🛑 Останавливаем существующие контейнеры..."
docker-compose down -v

# Удаляем старые образы
echo "🗑️ Удаляем старые образы..."
docker system prune -f

# Собираем и запускаем контейнеры
echo "🔨 Собираем и запускаем контейнеры..."
docker-compose up --build -d

# Ждем запуска PostgreSQL
echo "⏳ Ждем запуска PostgreSQL..."
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
    echo "⏳ Ждем PostgreSQL... попытка $i/$retries"
    sleep 2
done

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

echo "Перезапуск контейнера чтобы добавить тестового админа krawy"
docker-compose up --build -d telephone-book

echo ""
echo "🎉 Деплой завершен успешно!"
echo "📱 Приложение доступно по адресу: http://localhost"
echo "📚 Swagger документация: http://localhost/swagger/"
echo "🗄️ PostgreSQL: localhost:5432 (rosatom/rosatom)"
echo "👤 Тестовый пользователь: admin@example.com / admin"
