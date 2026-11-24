-- ============================================================
-- Test IDs: SEA-01 to SEA-09
-- ============================================================

BEGIN;


-- ============================================================
-- TEST SETUP
-- Create two temporary series for testing
-- ============================================================

INSERT INTO titles (
    name,
    description,
    release_date,
    title_type,
    age_category_id
)
VALUES (
           'Test Season Series 1',
           'Series used for seasons testing',
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
            WHERE name = 'Test Season Series 1')
       );


INSERT INTO titles (
    name,
    description,
    release_date,
    title_type,
    age_category_id
)
VALUES (
           'Test Season Series 2',
           'Second series used for seasons testing',
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
            WHERE name = 'Test Season Series 2')
       );


-- ============================================================
-- SEA-01: Insert a valid season
-- Expected: INSERT succeeds
-- ============================================================

INSERT INTO seasons (
    series_id,
    season_number
)
VALUES (
           (SELECT title_id
            FROM titles
            WHERE name = 'Test Season Series 1'),
           1
       );

DO $$
    BEGIN
        RAISE NOTICE 'SEA-01 PASS: Valid season inserted successfully.';
    END $$;


-- ============================================================
-- SEA-02: Verify season_id is automatically generated
-- Expected: season_id is not NULL
-- ============================================================

DO $$
    DECLARE
        generated_id BIGINT;
    BEGIN
        SELECT season_id
        INTO generated_id
        FROM seasons
        WHERE series_id = (
            SELECT title_id
            FROM titles
            WHERE name = 'Test Season Series 1'
        )
          AND season_number = 1;

        IF generated_id IS NULL THEN
            RAISE EXCEPTION 'SEA-02 FAIL: season_id was not generated.';
        END IF;

        RAISE NOTICE 'SEA-02 PASS: season_id was automatically generated.';
    END $$;


-- ============================================================
-- SEA-03: Reject season number 0
-- Expected: INSERT fails because season_number must be > 0
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO seasons (
                series_id,
                season_number
            )
            VALUES (
                       (SELECT title_id
                        FROM titles
                        WHERE name = 'Test Season Series 1'),
                       0
                   );

            RAISE EXCEPTION 'SEA-03 FAIL: Season number 0 was accepted.';

        EXCEPTION
            WHEN check_violation THEN
                RAISE NOTICE 'SEA-03 PASS: Season number 0 was rejected.';
        END;
    END $$;


-- ============================================================
-- SEA-04: Reject negative season number
-- Expected: INSERT fails because season_number must be > 0
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO seasons (
                series_id,
                season_number
            )
            VALUES (
                       (SELECT title_id
                        FROM titles
                        WHERE name = 'Test Season Series 1'),
                       -1
                   );

            RAISE EXCEPTION 'SEA-04 FAIL: Negative season number was accepted.';

        EXCEPTION
            WHEN check_violation THEN
                RAISE NOTICE 'SEA-04 PASS: Negative season number was rejected.';
        END;
    END $$;


-- ============================================================
-- SEA-05: Reject nonexistent series_id
-- Expected: INSERT fails because of foreign key constraint
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO seasons (
                series_id,
                season_number
            )
            VALUES (
                       -999999,
                       1
                   );

            RAISE EXCEPTION 'SEA-05 FAIL: Nonexistent series_id was accepted.';

        EXCEPTION
            WHEN foreign_key_violation THEN
                RAISE NOTICE 'SEA-05 PASS: Nonexistent series_id was rejected.';
        END;
    END $$;


-- ============================================================
-- SEA-06: Reject duplicate season number within the same series
-- Expected: INSERT fails because of UNIQUE constraint
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO seasons (
                series_id,
                season_number
            )
            VALUES (
                       (SELECT title_id
                        FROM titles
                        WHERE name = 'Test Season Series 1'),
                       1
                   );

            RAISE EXCEPTION 'SEA-06 FAIL: Duplicate season number was accepted.';

        EXCEPTION
            WHEN unique_violation THEN
                RAISE NOTICE 'SEA-06 PASS: Duplicate season number within the same series was rejected.';
        END;
    END $$;


-- ============================================================
-- SEA-07: Allow the same season number in a different series
-- Expected: INSERT succeeds
-- ============================================================

INSERT INTO seasons (
    series_id,
    season_number
)
VALUES (
           (SELECT title_id
            FROM titles
            WHERE name = 'Test Season Series 2'),
           1
       );

DO $$
    BEGIN
        RAISE NOTICE 'SEA-07 PASS: Same season number was allowed in a different series.';
    END $$;


-- ============================================================
-- SEA-08: Reject NULL series_id
-- Expected: INSERT fails because series_id is NOT NULL
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO seasons (
                series_id,
                season_number
            )
            VALUES (
                       NULL,
                       1
                   );

            RAISE EXCEPTION 'SEA-08 FAIL: NULL series_id was accepted.';

        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE 'SEA-08 PASS: NULL series_id was rejected.';
        END;
    END $$;


-- ============================================================
-- SEA-09: Reject NULL season_number
-- Expected: INSERT fails because season_number is NOT NULL
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO seasons (
                series_id,
                season_number
            )
            VALUES (
                       (SELECT title_id
                        FROM titles
                        WHERE name = 'Test Season Series 1'),
                       NULL
                   );

            RAISE EXCEPTION 'SEA-09 FAIL: NULL season_number was accepted.';

        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE 'SEA-09 PASS: NULL season_number was rejected.';
        END;
    END $$;


-- ============================================================
-- ROLLBACK TEST DATA
-- ============================================================

ROLLBACK;