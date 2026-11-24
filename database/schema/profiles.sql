CREATE TABLE profiles (
    profile_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_id BIGINT NOT NULL REFERENCES accounts(account_id),                      profile_name VARCHAR(100) NOT NULL,
    age_category_id BIGINT NOT NULL REFERENCES age_categories(age_category_id),
    profile_image TEXT
);

-- Enforce case-insensitive profile name uniqueness per account
CREATE UNIQUE INDEX profiles_account_name_unique
    ON profiles (account_id, LOWER(profile_name));