CREATE TABLE seasons (
    season_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    series_id BIGINT NOT NULL REFERENCES series(title_id),
    season_number INTEGER NOT NULL
        CONSTRAINT season_number_check
        CHECK (season_number > 0),

    UNIQUE (series_id, season_number)
);