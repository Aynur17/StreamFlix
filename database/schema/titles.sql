CREATE TABLE titles (
    title_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    release_date DATE NULL,
    title_type VARCHAR(10) NOT NULL
        CONSTRAINT titles_type_check
        CHECK (title_type in ('FILM', 'SERIES')),
    age_category_id BIGINT NOT NULL REFERENCES age_categories(age_category_id)
);