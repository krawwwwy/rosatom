-- ===========================================
-- ОБЩИЕ МИГРАЦИИ ДЛЯ ПРОЕКТА ROSATOM (ИСПРАВЛЕННЫЕ)
-- ===========================================

-- SSO таблицы
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

-- Главная таблица экстренных служб
CREATE TABLE IF NOT EXISTS main (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    phone_number TEXT NOT NULL,
    email TEXT UNIQUE
);

-- Создаем схемы
CREATE SCHEMA IF NOT EXISTS grafit;
CREATE SCHEMA IF NOT EXISTS giredmet;

-- ===========================================
-- СХЕМА GRAFIT
-- ===========================================

CREATE TABLE IF NOT EXISTS grafit.departments (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS grafit.sections (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    parent_id INT NULL,
    FOREIGN KEY (parent_id) REFERENCES grafit.departments(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS grafit.workers (
    id SERIAL PRIMARY KEY,
    surname TEXT NOT NULL,
    name TEXT NOT NULL,
    middle_name TEXT,
    email TEXT NOT NULL UNIQUE,
    phone_number TEXT NOT NULL,
    cabinet TEXT,
    position TEXT,
    department TEXT NOT NULL,
    section TEXT,
    birth_date DATE,
    description TEXT,
    photo BYTEA,
    photo_filename TEXT
);

-- ===========================================
-- СХЕМА GIREDMET
-- ===========================================

CREATE TABLE IF NOT EXISTS giredmet.departments (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS giredmet.sections (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    parent_id INT NULL,
    FOREIGN KEY (parent_id) REFERENCES giredmet.departments(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS giredmet.workers (
    id SERIAL PRIMARY KEY,
    surname TEXT NOT NULL,
    name TEXT NOT NULL,
    middle_name TEXT,
    email TEXT NOT NULL UNIQUE,
    phone_number TEXT NOT NULL,
    cabinet TEXT,
    position TEXT,
    department TEXT NOT NULL,
    section TEXT,
    birth_date DATE,
    description TEXT,
    photo BYTEA,
    photo_filename TEXT
);

-- ===========================================
-- ТЕСТОВЫЕ ДАННЫЕ
-- ===========================================

-- SSO данные
INSERT INTO apps (name, secret) VALUES ('telephone-book', 'telephone-book-secret');
INSERT INTO users (email, pass_hash) VALUES ('admin@example.com', '\x24326124313024484a6e47676336707965684e7734367059417562654f69424b656b524658546a35665a43326b524c31455a4756497765586564567736');

-- Экстренные службы
INSERT INTO main (name, phone_number, email) VALUES ('Служба безопасности', '+7(495)123-01-01', 'security@rosatom.ru');
INSERT INTO main (name, phone_number, email) VALUES ('Пожарная служба', '+7(495)123-01-02', 'fire@rosatom.ru');
INSERT INTO main (name, phone_number, email) VALUES ('Медицинская служба', '+7(495)123-01-03', 'medical@rosatom.ru');
INSERT INTO main (name, phone_number, email) VALUES ('Техническая поддержка', '+7(495)123-01-04', 'tech@rosatom.ru');
INSERT INTO main (name, phone_number, email) VALUES ('Дежурный инженер', '+7(495)123-01-05', 'duty@rosatom.ru');

-- Данные для GIREDMET
INSERT INTO giredmet.departments (name) VALUES ('Отдел разработки');
INSERT INTO giredmet.departments (name) VALUES ('Отдел тестирования');
INSERT INTO giredmet.departments (name) VALUES ('Отдел аналитики');
INSERT INTO giredmet.departments (name) VALUES ('Административный отдел');

INSERT INTO giredmet.sections (name, parent_id) VALUES ('Группа backend', 1);
INSERT INTO giredmet.sections (name, parent_id) VALUES ('Группа frontend', 1);
INSERT INTO giredmet.sections (name, parent_id) VALUES ('Группа QA', 2);
INSERT INTO giredmet.sections (name, parent_id) VALUES ('Группа бизнес-аналитики', 3);

INSERT INTO giredmet.workers (surname, name, middle_name, email, phone_number, cabinet, position, department, section, birth_date) VALUES ('Иванов', 'Иван', 'Иванович', 'ivanov@giredmet.ru', '+7(999)123-45-67', '101', 'Ведущий разработчик', 'Отдел разработки', 'Группа backend', '1990-07-28');
INSERT INTO giredmet.workers (surname, name, middle_name, email, phone_number, cabinet, position, department, section, birth_date) VALUES ('Петрова', 'Мария', 'Сергеевна', 'petrova@giredmet.ru', '+7(999)234-56-78', '102', 'Frontend разработчик', 'Отдел разработки', 'Группа frontend', '1992-07-29');
INSERT INTO giredmet.workers (surname, name, middle_name, email, phone_number, cabinet, position, department, section, birth_date) VALUES ('Сидоров', 'Петр', 'Алексеевич', 'sidorov@giredmet.ru', '+7(999)345-67-89', '201', 'QA инженер', 'Отдел тестирования', 'Группа QA', '1988-08-01');
INSERT INTO giredmet.workers (surname, name, middle_name, email, phone_number, cabinet, position, department, section, birth_date) VALUES ('Кузнецова', 'Анна', 'Владимировна', 'kuznetsova@giredmet.ru', '+7(999)456-78-90', '301', 'Бизнес-аналитик', 'Отдел аналитики', 'Группа бизнес-аналитики', '1995-07-28');

-- Данные для GRAFIT
INSERT INTO grafit.departments (name) VALUES ('Исследовательский отдел');
INSERT INTO grafit.departments (name) VALUES ('Производственный отдел');
INSERT INTO grafit.departments (name) VALUES ('Отдел контроля качества');
INSERT INTO grafit.departments (name) VALUES ('Лаборатория');

INSERT INTO grafit.sections (name, parent_id) VALUES ('Группа исследований', 1);
INSERT INTO grafit.sections (name, parent_id) VALUES ('Группа разработки', 1);
INSERT INTO grafit.sections (name, parent_id) VALUES ('Производственная линия 1', 2);
INSERT INTO grafit.sections (name, parent_id) VALUES ('Лаборатория анализа', 4);

INSERT INTO grafit.workers (surname, name, middle_name, email, phone_number, cabinet, position, department, section, birth_date) VALUES ('Смирнов', 'Алексей', 'Петрович', 'smirnov@grafit.ru', '+7(999)567-89-01', '101', 'Старший исследователь', 'Исследовательский отдел', 'Группа исследований', '1985-07-28');
INSERT INTO grafit.workers (surname, name, middle_name, email, phone_number, cabinet, position, department, section, birth_date) VALUES ('Волкова', 'Екатерина', 'Дмитриевна', 'volkova@grafit.ru', '+7(999)678-90-12', '102', 'Инженер-технолог', 'Производственный отдел', 'Производственная линия 1', '1993-07-29');
INSERT INTO grafit.workers (surname, name, middle_name, email, phone_number, cabinet, position, department, section, birth_date) VALUES ('Морозов', 'Дмитрий', 'Сергеевич', 'morozov@grafit.ru', '+7(999)789-01-23', '201', 'Специалист по качеству', 'Отдел контроля качества', NULL, '1991-08-01');
INSERT INTO grafit.workers (surname, name, middle_name, email, phone_number, cabinet, position, department, section, birth_date) VALUES ('Лебедева', 'Ольга', 'Александровна', 'lebedeva@grafit.ru', '+7(999)890-12-34', '301', 'Лаборант', 'Лаборатория', 'Лаборатория анализа', '1994-07-28'); 