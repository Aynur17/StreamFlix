CREATE TABLE age_categories (
    age_category_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
        CHECK (category_name IN ('AL', '6', '9', '12', '14', '16', '18')),
    minimum_age INTEGER NOT NULL
        CHECK (minimum_age IN (0, 6, 9, 12, 14, 16, 18)),
    CHECK ((category_name = 'AL' AND minimum_age = 0)
               OR (category_name = '6' AND minimum_age = 6)
               OR (category_name = '9' AND minimum_age = 9)
               OR (category_name = '12' AND minimum_age = 12)
               OR (category_name = '14' AND minimum_age = 14)
               OR (category_name = '16' AND minimum_age = 16)
               OR (category_name = '18' AND minimum_age = 18)
        )
);