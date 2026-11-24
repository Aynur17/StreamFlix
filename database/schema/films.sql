CREATE TABLE films (
    title_id BIGINT PRIMARY KEY REFERENCES titles(title_id),
    duration_in_seconds INTEGER NOT NULL
        CONSTRAINT duration_in_seconds_check
        CHECK (duration_in_seconds > 0)
);