# 🚀 Деплой проекта Rosatom на Linux VM

## Архитектура

```
┌─── nginx:80 (фронтенд + proxy) 
├─── telephone-book:8080 (основное API)
├─── sso:44044 (gRPC аутентификация)  
└─── postgres:5432 (одна база rosatom с разными схемами)
```

**База данных `rosatom` содержит:**
- Схема `public` - таблицы SSO (users, apps, admins)
- Схема `grafit` - данные института Графит  
- Схема `giredmet` - данные института Гиредмет
- Таблица `main` в public - справочник экстренных служб

## Быстрый деплой

1. **Загрузи проект на VM:**
```bash
# Архивируй проект на винде
tar -czf rosatom.tar.gz . --exclude=.git

# На Linux VM
scp rosatom.tar.gz user@vm_ip:/home/user/
ssh user@vm_ip
tar -xzf rosatom.tar.gz
cd rosatom/
```

2. **Запусти автоматический деплой:**
```bash
sudo ./deploy.sh
```

Все! Сайт будет доступен на `http://IP_VM`

## Ручной деплой

### 1. Установка Docker (если нужно)
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl enable docker
sudo systemctl start docker

# Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. Сборка и запуск
```bash
# Собрать образы
sudo docker-compose build

# Запустить все сервисы  
sudo docker-compose up -d

# Посмотреть статус
sudo docker-compose ps
```

### 3. Применение миграций
```bash
# Ждем поднятия PostgreSQL
sleep 15

# SSO миграции (схема public)
sudo docker-compose exec sso sh -c "export DSN='postgres://rosatom:rosatom@postgres:5432/rosatom?sslmode=disable' && go run ./cmd/migrator/postgres/main.go -migrations-path=./migrations/postgresql"

# Telephone book миграции (схемы grafit, giredmet)
sudo docker-compose exec telephone-book sh -c "export DSN='postgresql://rosatom:rosatom@postgres:5432/rosatom?sslmode=disable' && go run ./cmd/migrator/main.go -migrations-path=./migrations"
```

## Конфигурация

### Продакшн настройки
- **SSO:** `sso/config/prod.yaml` → БД `rosatom`, схема `public`
- **Main App:** `telephone_book/config/prod.yaml` → БД `rosatom`, схемы `grafit`/`giredmet`
- **Nginx:** `nginx.conf`

### Переменные окружения
```yaml
# В docker-compose.yml уже настроено:
CONFIG_PATH: /app/config/prod.yaml
POSTGRES_DB: rosatom
POSTGRES_USER: rosatom  
POSTGRES_PASSWORD: rosatom
```

## Управление

### Логи
```bash
# Все сервисы
sudo docker-compose logs -f

# Конкретный сервис
sudo docker-compose logs -f sso
sudo docker-compose logs -f telephone-book
sudo docker-compose logs -f postgres
sudo docker-compose logs -f nginx
```

### Перезапуск
```bash
# Перезапуск конкретного сервиса
sudo docker-compose restart sso

# Полный перезапуск
sudo docker-compose down
sudo docker-compose up -d
```

### Обновление кода
```bash
# Остановить
sudo docker-compose down

# Пересобрать
sudo docker-compose build --no-cache

# Запустить
sudo docker-compose up -d
```

## Доступ

После успешного деплоя:

- **Фронтенд:** http://VM_IP
- **API:** http://VM_IP:8080  
- **Swagger:** http://VM_IP/swagger/
- **SSO gRPC:** VM_IP:44044 (внутренний)

## Проблемы и решения

### 1. Контейнер не стартует
```bash
sudo docker-compose logs service_name
```

### 2. Проблемы с БД
```bash
# Подключиться к postgres
sudo docker-compose exec postgres psql -U rosatom -d rosatom

# Посмотреть схемы
\dn

# Переключиться на схему
SET search_path TO grafit;
\dt

# Пересоздать БД
sudo docker-compose down -v  # удалит данные!
sudo docker-compose up -d
```

### 3. Проблемы с портами
```bash
# Проверить занятые порты
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :8080

# Изменить порты в docker-compose.yml если нужно
```

### 4. Права доступа
```bash
# Если проблемы с файлами
sudo chown -R $(whoami): .
sudo chmod +x deploy.sh
```

## Мониторинг

### Ресурсы
```bash
sudo docker stats
```

### Здоровье сервисов  
```bash
sudo docker-compose ps
curl http://localhost:8080/swagger/  # должен отвечать
```

### Бэкапы БД
```bash
# Создать бэкап
sudo docker-compose exec postgres pg_dump -U rosatom rosatom > backup.sql

# Восстановить
sudo docker-compose exec -T postgres psql -U rosatom rosatom < backup.sql
```

## Безопасность

1. **Смени пароли в prod.yaml**
2. **Настрой firewall:**
```bash
sudo ufw allow 80
sudo ufw allow 443  
sudo ufw enable
```
3. **SSL/HTTPS:** добавь сертификаты в nginx конфиг

## Производительность

### Для продакшена на больших нагрузках:
- Увеличь `worker_connections` в nginx.conf
- Добавь репликацию PostgreSQL  
- Используй Redis для кэширования
- Настрой горизонтальное масштабирование с docker swarm

---

**Если что-то не работает - гони логи, разберемся!** 🔧 