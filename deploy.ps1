#!/usr/bin/env powershell

Write-Host "🚀 Запуск деплоя проекта rosatom..." -ForegroundColor Green

# Проверяем что Docker запущен
try {
    docker ps | Out-Null
    Write-Host "✅ Docker запущен" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker не запущен. Запустите Docker Desktop" -ForegroundColor Red
    exit 1
}

# Останавливаем существующие контейнеры
Write-Host "🛑 Останавливаем существующие контейнеры..." -ForegroundColor Yellow
docker-compose down --remove-orphans

# Удаляем старые образы
Write-Host "🗑️ Удаляем старые образы..." -ForegroundColor Yellow
docker system prune -f

# Собираем и запускаем
Write-Host "🔨 Собираем и запускаем контейнеры..." -ForegroundColor Yellow
docker-compose up --build -d

# Ждем запуска PostgreSQL
Write-Host "⏳ Ждем запуска PostgreSQL..." -ForegroundColor Yellow
$retries = 30
for ($i = 1; $i -le $retries; $i++) {
    try {
        docker-compose exec -T postgres pg_isready -U rosatom -d rosatom | Out-Null
        Write-Host "✅ PostgreSQL готов" -ForegroundColor Green
        break
    } catch {
        if ($i -eq $retries) {
            Write-Host "❌ PostgreSQL не запустился за $retries попыток" -ForegroundColor Red
            exit 1
        }
        Write-Host "⏳ Ждем PostgreSQL... попытка $i/$retries" -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
}

# Запускаем миграции SSO
Write-Host "📦 Запускаем миграции SSO..." -ForegroundColor Yellow
try {
    docker-compose exec -T sso sh -c "export DSN='postgres://rosatom:rosatom@postgres:5432/rosatom?sslmode=disable' && go run ./cmd/migrator/postgres/main.go -migrations-path=./migrations/postgresql"
    Write-Host "✅ Миграции SSO выполнены" -ForegroundColor Green
} catch {
    Write-Host "❌ Ошибка миграций SSO" -ForegroundColor Red
    docker-compose logs sso
    exit 1
}

# Запускаем миграции telephone_book
Write-Host "📦 Запускаем миграции telephone_book..." -ForegroundColor Yellow
try {
    docker-compose exec -T telephone-book sh -c "export DSN='postgresql://rosatom:rosatom@postgres:5432/rosatom?sslmode=disable' && go run ./cmd/migrator/main.go -migrations-path=./migrations"
    Write-Host "✅ Миграции telephone_book выполнены" -ForegroundColor Green
} catch {
    Write-Host "❌ Ошибка миграций telephone_book" -ForegroundColor Red
    docker-compose logs telephone-book
    exit 1
}

# Проверяем что таблицы созданы
Write-Host "🔍 Проверяем созданные таблицы..." -ForegroundColor Cyan
docker-compose exec -T postgres psql -U rosatom -d rosatom -c "\dt"
docker-compose exec -T postgres psql -U rosatom -d rosatom -c "\dt grafit.*"
docker-compose exec -T postgres psql -U rosatom -d rosatom -c "\dt giredmet.*"

# Проверяем статус контейнеров
Write-Host "📊 Статус контейнеров:" -ForegroundColor Cyan
docker-compose ps

Write-Host ""
Write-Host "🎉 Деплой завершен успешно!" -ForegroundColor Green
Write-Host "📱 Приложение доступно по адресу: http://localhost" -ForegroundColor Cyan
Write-Host "📚 Swagger документация: http://localhost/swagger/" -ForegroundColor Cyan
Write-Host "🗄️ PostgreSQL: localhost:5432 (rosatom/rosatom)" -ForegroundColor Cyan 