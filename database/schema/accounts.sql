-- "GENERATED ALWAYS AS IDENTITY" is the same as "AUTO_INCREMENT" but it's simply the correct way to communicate with
-- PostgreSQL while the latter is more for MySQL and so on.

-- PostgreSQL automatically passes all namings to lowercase, to not over-complicate things we have decided that table names are in the plural in snake_case patterns, while columns are singular in snake_case patters.
CREATE TABLE accounts (
    account_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_activated BOOLEAN NOT NULL DEFAULT FALSE,
    account_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
        CHECK (account_status IN ('ACTIVE', 'SUSPENDED', 'CLOSED')),
    failed_login_attempts INTEGER NOT NULL DEFAULT 0
        CHECK (failed_login_attempts >= 0),
    blocked_until TIMESTAMPTZ -- We chose this data type because it stores a timestamp with timezone awareness, which is useful when dealing with timestamps across different locations. It can be NULL, because it only means an account is not currently subject to a timed block
);