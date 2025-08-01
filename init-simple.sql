-- Простые миграции для отладки
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    pass_hash BYTEA NOT NULL
);

CREATE TABLE IF NOT EXISTS apps (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    secret VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS main (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    phone_number TEXT NOT NULL,
    email TEXT UNIQUE
);

-- Тестовые данные
INSERT INTO apps (name, secret) VALUES ('telephone-book', 'telephone-book-secret');
INSERT INTO users (email, pass_hash) VALUES ('admin@example.com', '\x24326124313024484a6e47676336707965684e7734367059417562654f69424b656b524658546a35665a43326b524c31455a4756497765586564567736');
INSERT INTO main (name, phone_number, email) VALUES 
    ('Служба безопасности', '+7(495)123-01-01', 'security@rosatom.ru'),
    ('Пожарная служба', '+7(495)123-01-02', 'fire@rosatom.ru'); 