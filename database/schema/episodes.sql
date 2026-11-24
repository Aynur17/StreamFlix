CREATE TABLE episodes (
    episode_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    season_id BIGINT NOT NULL REFERENCES seasons(season_id),
    episode_number INTEGER NOT NULL
        CONSTRAINT episode_number_check
        CHECK (episode_number > 0),
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    duration_in_seconds INTEGER NOT NULL
        CONSTRAINT duration_in_seconds_check
        CHECK (duration_in_seconds > 0),

    UNIQUE (season_id, episode_number)
);