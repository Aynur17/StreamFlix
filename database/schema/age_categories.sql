CREATE TABLE age_categories (
    age_category_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    minimum_age INTEGER NOT NULL
        CHECK (minimum_age >= 0)
);