-- ===========================================
-- SSO МИГРАЦИИ (из sso/migrations/postgresql/)
-- ===========================================

CREATE TABLE IF NOT EXISTS users
(
    id        SERIAL PRIMARY KEY,
    email     TEXT NOT NULL UNIQUE,
    pass_hash BYTEA NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_email ON users (email);

CREATE TABLE IF NOT EXISTS apps
(
    id     SERIAL PRIMARY KEY,
    name   TEXT NOT NULL UNIQUE,
    secret TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS admins
(
    user_id INTEGER PRIMARY KEY,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- SSO моковые данные
INSERT INTO apps (id, name, secret)
VALUES (1, 'test', 'test-secret')
ON CONFLICT DO NOTHING;

INSERT INTO users (id, email, pass_hash)
VALUES (1, 'admin@mail.ru', 'admin123')
ON CONFLICT DO NOTHING;

INSERT INTO admins (user_id)
VALUES (1)
ON CONFLICT DO NOTHING;

-- ===========================================
-- TELEPHONE_BOOK МИГРАЦИИ (из telephone_book/migrations/)
-- ===========================================

CREATE TABLE IF NOT EXISTS main
(
    id           SERIAL PRIMARY KEY,
    name         TEXT NOT NULL UNIQUE,
    phone_number TEXT NOT NULL,
    email        TEXT  UNIQUE
);

CREATE SCHEMA IF NOT EXISTS grafit;
SET search_path TO grafit;

CREATE TABLE IF NOT EXISTS workers
(
    id           SERIAL PRIMARY KEY,
    surname      TEXT NOT NULL,
    name         TEXT NOT NULL,
    middle_name  TEXT,
    email        TEXT NOT NULL UNIQUE,
    phone_number TEXT NOT NULL,
    cabinet      TEXT,
    position     TEXT,
    department   TEXT NOT NULL,
    section     TEXT,
    birth_date   DATE,
    description  TEXT,
    photo        BYTEA,
    photo_filename TEXT
);

CREATE TABLE IF NOT EXISTS departments 
(
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS sections
(
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    parent_id INT NULL,
    FOREIGN KEY (parent_id) REFERENCES departments(id) ON DELETE CASCADE
);

CREATE SCHEMA IF NOT EXISTS giredmet;
SET search_path TO giredmet;

CREATE TABLE IF NOT EXISTS workers
(
    id           SERIAL PRIMARY KEY,
    surname      TEXT NOT NULL,
    name         TEXT NOT NULL,
    middle_name  TEXT,
    email        TEXT NOT NULL UNIQUE,
    phone_number TEXT NOT NULL,
    cabinet      TEXT,
    position     TEXT,
    department   TEXT NOT NULL,
    section     TEXT,
    birth_date   DATE,
    description  TEXT,
    photo        BYTEA,
    photo_filename TEXT
);

CREATE TABLE IF NOT EXISTS departments 
(
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

create table if not exists sections
(
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    parent_id INT NULL,
    FOREIGN KEY (parent_id) REFERENCES departments(id) ON DELETE CASCADE
);

-- ===========================================
-- ТЕСТОВЫЕ ДАННЫЕ TELEPHONE_BOOK
-- ===========================================

-- Вставка экстренных служб
SET search_path TO public;

INSERT INTO main (name, phone_number, email) VALUES 
    ('Служба безопасности', '+7(495)123-01-01', 'security@rosatom.ru'),
    ('Пожарная служба', '+7(495)123-01-02', 'fire@rosatom.ru'),
    ('Медицинская служба', '+7(495)123-01-03', 'medical@rosatom.ru'),
    ('Техническая поддержка', '+7(495)123-01-04', 'tech@rosatom.ru'),
    ('Дежурный инженер', '+7(495)123-01-05', 'duty@rosatom.ru');

-- Вставка тестовых данных для Гиредмет
SET search_path TO giredmet;

-- Создание отделов
INSERT INTO departments (name) VALUES 
    ('Отдел разработки'),
    ('Отдел тестирования'),
    ('Отдел аналитики'),
    ('Административный отдел');

-- Создание секций
INSERT INTO sections (name, parent_id) VALUES
    ('Группа backend', 1),
    ('Группа frontend', 1),
    ('Группа QA', 2),
    ('Группа бизнес-аналитики', 3);

-- Создание работников
INSERT INTO workers (surname, name, middle_name, email, phone_number, cabinet, position, department, section, birth_date) VALUES
    ('Иванов', 'Иван', 'Иванович', 'ivanov@giredmet.ru', '+7(999)123-45-67', '101', 'Ведущий разработчик', 'Отдел разработки', 'Группа backend', '1990-07-28'),
    ('Петрова', 'Мария', 'Сергеевна', 'petrova@giredmet.ru', '+7(999)234-56-78', '102', 'Frontend разработчик', 'Отдел разработки', 'Группа frontend', '1992-07-29'),
    ('Сидоров', 'Петр', 'Алексеевич', 'sidorov@giredmet.ru', '+7(999)345-67-89', '201', 'QA инженер', 'Отдел тестирования', 'Группа QA', '1988-08-01'),
    ('Кузнецова', 'Анна', 'Владимировна', 'kuznetsova@giredmet.ru', '+7(999)456-78-90', '301', 'Бизнес-аналитик', 'Отдел аналитики', 'Группа бизнес-аналитики', '1995-07-28');

-- Вставка тестовых данных для Графит
SET search_path TO grafit;

-- Создание отделов
INSERT INTO departments (name) VALUES 
    ('Исследовательский отдел'),
    ('Производственный отдел'),
    ('Отдел контроля качества'),
    ('Лаборатория');

-- Создание секций
INSERT INTO sections (name, parent_id) VALUES
    ('Группа исследований', 1),
    ('Группа разработки', 1),
    ('Производственная линия 1', 2),
    ('Лаборатория анализа', 4);

-- Создание работников
INSERT INTO workers (surname, name, middle_name, email, phone_number, cabinet, position, department, section, birth_date) VALUES
    ('Смирнов', 'Алексей', 'Петрович', 'smirnov@grafit.ru', '+7(999)567-89-01', '101', 'Старший исследователь', 'Исследовательский отдел', 'Группа исследований', '1985-07-28'),
    ('Волкова', 'Екатерина', 'Дмитриевна', 'volkova@grafit.ru', '+7(999)678-90-12', '102', 'Инженер-технолог', 'Производственный отдел', 'Производственная линия 1', '1993-07-29'),
    ('Морозов', 'Дмитрий', 'Сергеевич', 'morozov@grafit.ru', '+7(999)789-01-23', '201', 'Специалист по качеству', 'Отдел контроля качества', null, '1991-08-01'),
    ('Лебедева', 'Ольга', 'Александровна', 'lebedeva@grafit.ru', '+7(999)890-12-34', '301', 'Лаборант', 'Лаборатория', 'Лаборатория анализа', '1994-07-28');

-- Возвращаем путь к public
SET search_path TO public; 