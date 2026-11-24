CREATE TABLE series (
    title_id BIGINT PRIMARY KEY REFERENCES titles(title_id)
);