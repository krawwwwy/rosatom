#!/usr/bin/env powershell

Write-Host "Zapusk deploya proekta rosatom..." -ForegroundColor Green

# Proveryaem chto Docker zapushen
try {
    docker ps | Out-Null
    Write-Host "Docker zapushen" -ForegroundColor Green
} catch {
    Write-Host "Docker ne zapushen. Zapustite Docker Desktop" -ForegroundColor Red
    exit 1
}

# Ostanavlivaem sushhestvuyushhie kontejnery
Write-Host "Ostanavlivaem sushhestvuyushhie kontejnery..." -ForegroundColor Yellow
docker-compose down -v

# Udalyaem starye obrazy
Write-Host "Udalyaem starye obrazy..." -ForegroundColor Yellow
docker system prune -f

# Sobiraem i zapuskaem
Write-Host "Sobiraem i zapuskaem kontejnery..." -ForegroundColor Yellow
docker-compose up --build -d

# Zhdem zapuska PostgreSQL
Write-Host "Zhdem zapuska PostgreSQL..." -ForegroundColor Yellow
$retries = 30
for ($i = 1; $i -le $retries; $i++) {
    try {
        docker-compose exec -T postgres pg_isready -U rosatom -d rosatom | Out-Null
        Write-Host "PostgreSQL gotov" -ForegroundColor Green
        break
    } catch {
        if ($i -eq $retries) {
            Write-Host "PostgreSQL ne zapustilsya za $retries popytok" -ForegroundColor Red
            exit 1
        }
        Write-Host "Zhdem PostgreSQL... popytka $i/$retries" -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
}

# Proveryaem chto tablicy sozdany
Write-Host "Proveryaem sozdannye tablicy..." -ForegroundColor Cyan
Write-Host "=== SSO tablicy (public schema) ===" -ForegroundColor Cyan
docker-compose exec -T postgres psql -U rosatom -d rosatom -c "\dt"
Write-Host "=== Grafit schema ===" -ForegroundColor Cyan
docker-compose exec -T postgres psql -U rosatom -d rosatom -c "\dt grafit.*"
Write-Host "=== Giredmet schema ===" -ForegroundColor Cyan
docker-compose exec -T postgres psql -U rosatom -d rosatom -c "\dt giredmet.*"

# Proveryaem status kontejnerov
Write-Host "Status kontejnerov:" -ForegroundColor Cyan
docker-compose ps

Write-Host ""
Write-Host "Deploj zavershen uspeshno!" -ForegroundColor Green
Write-Host "Prilozhenie dostupno po adresu: http://localhost" -ForegroundColor Cyan
Write-Host "Swagger dokumentaciya: http://localhost/swagger/" -ForegroundColor Cyan
Write-Host "PostgreSQL: localhost:5432 (rosatom/rosatom)" -ForegroundColor Cyan
Write-Host "Test user: admin@example.com / admin" -ForegroundColor Yellow 