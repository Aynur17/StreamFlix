-- ============================================================
-- Test IDs: EPI-01 to EPI-12
-- ============================================================

BEGIN;


-- ============================================================
-- TEST SETUP
-- Create a series and two seasons for testing
-- ============================================================

INSERT INTO titles (
    name,
    description,
    release_date,
    title_type,
    age_category_id
)
VALUES (
           'Test Episode Series',
           'Series used for episodes testing',
           '2025-01-01',
           'SERIES',
           (SELECT age_category_id
            FROM age_categories
            WHERE category_name = 'AL')
       );

INSERT INTO series (
    title_id
)
VALUES (
           (SELECT title_id
            FROM titles
            WHERE name = 'Test Episode Series')
       );


-- Create Season 1

INSERT INTO seasons (
    series_id,
    season_number
)
VALUES (
           (SELECT title_id
            FROM titles
            WHERE name = 'Test Episode Series'),
           1
       );


-- Create Season 2

INSERT INTO seasons (
    series_id,
    season_number
)
VALUES (
           (SELECT title_id
            FROM titles
            WHERE name = 'Test Episode Series'),
           2
       );


-- ============================================================
-- EPI-01: Insert a valid episode
-- Expected: INSERT succeeds
-- ============================================================

INSERT INTO episodes (
    season_id,
    episode_number,
    name,
    description,
    duration_in_seconds
)
VALUES (
           (SELECT season_id
            FROM seasons
            WHERE series_id = (
                SELECT title_id
                FROM titles
                WHERE name = 'Test Episode Series'
            )
              AND season_number = 1),
           1,
           'Test Episode 1',
           'Episode used for testing the episodes table',
           1800
       );

DO $$
    BEGIN
        RAISE NOTICE 'EPI-01 PASS: Valid episode inserted successfully.';
    END $$;


-- ============================================================
-- EPI-02: Verify episode_id is automatically generated
-- Expected: episode_id is not NULL
-- ============================================================

DO $$
    DECLARE
        generated_id BIGINT;
    BEGIN
        SELECT episode_id
        INTO generated_id
        FROM episodes
        WHERE season_id = (
            SELECT season_id
            FROM seasons
            WHERE series_id = (
                SELECT title_id
                FROM titles
                WHERE name = 'Test Episode Series'
            )
              AND season_number = 1
        )
          AND episode_number = 1;

        IF generated_id IS NULL THEN
            RAISE EXCEPTION 'EPI-02 FAIL: episode_id was not generated.';
        END IF;

        RAISE NOTICE 'EPI-02 PASS: episode_id was automatically generated.';
    END $$;


-- ============================================================
-- EPI-03: Allow NULL description
-- Expected: INSERT succeeds
-- ============================================================

INSERT INTO episodes (
    season_id,
    episode_number,
    name,
    duration_in_seconds
)
VALUES (
           (SELECT season_id
            FROM seasons
            WHERE series_id = (
                SELECT title_id
                FROM titles
                WHERE name = 'Test Episode Series'
            )
              AND season_number = 1),
           2,
           'Test Episode Without Description',
           1800
       );

DO $$
    BEGIN
        RAISE NOTICE 'EPI-03 PASS: NULL description was allowed.';
    END $$;


-- ============================================================
-- EPI-04: Reject episode number 0
-- Expected: INSERT fails because episode_number must be > 0
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO episodes (
                season_id,
                episode_number,
                name,
                duration_in_seconds
            )
            VALUES (
                       (SELECT season_id
                        FROM seasons
                        WHERE series_id = (
                            SELECT title_id
                            FROM titles
                            WHERE name = 'Test Episode Series'
                        )
                          AND season_number = 1),
                       0,
                       'Test Episode Zero',
                       1800
                   );

            RAISE EXCEPTION 'EPI-04 FAIL: Episode number 0 was accepted.';

        EXCEPTION
            WHEN check_violation THEN
                RAISE NOTICE 'EPI-04 PASS: Episode number 0 was rejected.';
        END;
    END $$;


-- ============================================================
-- EPI-05: Reject negative episode number
-- Expected: INSERT fails because episode_number must be > 0
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO episodes (
                season_id,
                episode_number,
                name,
                duration_in_seconds
            )
            VALUES (
                       (SELECT season_id
                        FROM seasons
                        WHERE series_id = (
                            SELECT title_id
                            FROM titles
                            WHERE name = 'Test Episode Series'
                        )
                          AND season_number = 1),
                       -1,
                       'Test Episode Negative Number',
                       1800
                   );

            RAISE EXCEPTION 'EPI-05 FAIL: Negative episode number was accepted.';

        EXCEPTION
            WHEN check_violation THEN
                RAISE NOTICE 'EPI-05 PASS: Negative episode number was rejected.';
        END;
    END $$;


-- ============================================================
-- EPI-06: Reject nonexistent season_id
-- Expected: INSERT fails because of foreign key constraint
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO episodes (
                season_id,
                episode_number,
                name,
                duration_in_seconds
            )
            VALUES (
                       -999999,
                       1,
                       'Test Episode Invalid Season',
                       1800
                   );

            RAISE EXCEPTION 'EPI-06 FAIL: Nonexistent season_id was accepted.';

        EXCEPTION
            WHEN foreign_key_violation THEN
                RAISE NOTICE 'EPI-06 PASS: Nonexistent season_id was rejected.';
        END;
    END $$;


-- ============================================================
-- EPI-07: Reject duplicate episode number within the same season
-- Expected: INSERT fails because of UNIQUE constraint
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO episodes (
                season_id,
                episode_number,
                name,
                duration_in_seconds
            )
            VALUES (
                       (SELECT season_id
                        FROM seasons
                        WHERE series_id = (
                            SELECT title_id
                            FROM titles
                            WHERE name = 'Test Episode Series'
                        )
                          AND season_number = 1),
                       1,
                       'Test Duplicate Episode',
                       1800
                   );

            RAISE EXCEPTION 'EPI-07 FAIL: Duplicate episode number was accepted.';

        EXCEPTION
            WHEN unique_violation THEN
                RAISE NOTICE 'EPI-07 PASS: Duplicate episode number within the same season was rejected.';
        END;
    END $$;


-- ============================================================
-- EPI-08: Allow the same episode number in a different season
-- Expected: INSERT succeeds
-- ============================================================

INSERT INTO episodes (
    season_id,
    episode_number,
    name,
    duration_in_seconds
)
VALUES (
           (SELECT season_id
            FROM seasons
            WHERE series_id = (
                SELECT title_id
                FROM titles
                WHERE name = 'Test Episode Series'
            )
              AND season_number = 2),
           1,
           'Test Season 2 Episode 1',
           1800
       );

DO $$
    BEGIN
        RAISE NOTICE 'EPI-08 PASS: Same episode number was allowed in a different season.';
    END $$;


-- ============================================================
-- EPI-09: Reject NULL season_id
-- Expected: INSERT fails because season_id is NOT NULL
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO episodes (
                season_id,
                episode_number,
                name,
                duration_in_seconds
            )
            VALUES (
                       NULL,
                       1,
                       'Test Episode NULL Season',
                       1800
                   );

            RAISE EXCEPTION 'EPI-09 FAIL: NULL season_id was accepted.';

        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE 'EPI-09 PASS: NULL season_id was rejected.';
        END;
    END $$;


-- ============================================================
-- EPI-10: Reject NULL episode_number
-- Expected: INSERT fails because episode_number is NOT NULL
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO episodes (
                season_id,
                episode_number,
                name,
                duration_in_seconds
            )
            VALUES (
                       (SELECT season_id
                        FROM seasons
                        WHERE series_id = (
                            SELECT title_id
                            FROM titles
                            WHERE name = 'Test Episode Series'
                        )
                          AND season_number = 1),
                       NULL,
                       'Test Episode NULL Number',
                       1800
                   );

            RAISE EXCEPTION 'EPI-10 FAIL: NULL episode_number was accepted.';

        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE 'EPI-10 PASS: NULL episode_number was rejected.';
        END;
    END $$;


-- ============================================================
-- EPI-11: Reject NULL episode name
-- Expected: INSERT fails because name is NOT NULL
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO episodes (
                season_id,
                episode_number,
                name,
                duration_in_seconds
            )
            VALUES (
                       (SELECT season_id
                        FROM seasons
                        WHERE series_id = (
                            SELECT title_id
                            FROM titles
                            WHERE name = 'Test Episode Series'
                        )
                          AND season_number = 1),
                       3,
                       NULL,
                       1800
                   );

            RAISE EXCEPTION 'EPI-11 FAIL: NULL episode name was accepted.';

        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE 'EPI-11 PASS: NULL episode name was rejected.';
        END;
    END $$;


-- ============================================================
-- EPI-12: Reject NULL duration
-- Expected: INSERT fails because duration_in_seconds is NOT NULL
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO episodes (
                season_id,
                episode_number,
                name,
                duration_in_seconds
            )
            VALUES (
                       (SELECT season_id
                        FROM seasons
                        WHERE series_id = (
                            SELECT title_id
                            FROM titles
                            WHERE name = 'Test Episode Series'
                        )
                          AND season_number = 1),
                       4,
                       'Test Episode NULL Duration',
                       NULL
                   );

            RAISE EXCEPTION 'EPI-12 FAIL: NULL duration was accepted.';

        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE 'EPI-12 PASS: NULL duration was rejected.';
        END;
    END $$;


-- ============================================================
-- ROLLBACK TEST DATA
-- ============================================================

ROLLBACK;