-- Подключаемся к базе rosatom (создается автоматически через POSTGRES_DB)
-- Создаем схемы для разных институтов
CREATE DATABASE IF NOT EXISTS rosatom;
\c rosatom  
CREATE SCHEMA IF NOT EXISTS grafit;
CREATE SCHEMA IF NOT EXISTS giredmet;

-- Устанавливаем права на схемы
GRANT ALL ON SCHEMA grafit TO rosatom;
GRANT ALL ON SCHEMA giredmet TO rosatom;
GRANT ALL ON SCHEMA public TO rosatom;

-- Устанавливаем права на базу
GRANT ALL PRIVILEGES ON DATABASE rosatom TO rosatom; 