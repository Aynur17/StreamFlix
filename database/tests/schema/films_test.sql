-- ============================================================
-- Test IDs: FIL-01 to FIL-08
-- ============================================================

BEGIN;


-- ============================================================
-- FIL-01: Insert a valid film
-- Expected: INSERT succeeds
-- ============================================================

INSERT INTO titles (
    name,
    description,
    release_date,
    title_type,
    age_category_id
)
VALUES (
           'Test Film 1',
           'Film used for testing the films table',
           '2025-01-01',
           'FILM',
           (SELECT age_category_id
            FROM age_categories
            WHERE category_name = '12')
       );

INSERT INTO films (
    title_id,
    duration_in_seconds
)
VALUES (
           (SELECT title_id
            FROM titles
            WHERE name = 'Test Film 1'),
           7200
       );

DO $$
    BEGIN
        RAISE NOTICE 'FIL-01 PASS: Valid film inserted successfully.';
    END $$;


-- ============================================================
-- FIL-02: Accept a positive duration
-- Expected: INSERT succeeds
-- ============================================================

INSERT INTO titles (
    name,
    title_type,
    age_category_id
)
VALUES (
           'Test Film 2',
           'FILM',
           (SELECT age_category_id
            FROM age_categories
            WHERE category_name = 'AL')
       );

INSERT INTO films (
    title_id,
    duration_in_seconds
)
VALUES (
           (SELECT title_id
            FROM titles
            WHERE name = 'Test Film 2'),
           3600
       );

DO $$
    BEGIN
        RAISE NOTICE 'FIL-02 PASS: Positive duration was accepted.';
    END $$;


-- ============================================================
-- FIL-03: Reject duration of zero
-- Expected: INSERT fails because duration must be greater than 0
-- ============================================================

INSERT INTO titles (
    name,
    title_type,
    age_category_id
)
VALUES (
           'Test Film Zero Duration',
           'FILM',
           (SELECT age_category_id
            FROM age_categories
            WHERE category_name = 'AL')
       );

DO $$
    BEGIN
        BEGIN
            INSERT INTO films (
                title_id,
                duration_in_seconds
            )
            VALUES (
                       (SELECT title_id
                        FROM titles
                        WHERE name = 'Test Film Zero Duration'),
                       0
                   );

            RAISE EXCEPTION 'FIL-03 FAIL: Zero duration was accepted.';

        EXCEPTION
            WHEN check_violation THEN
                RAISE NOTICE 'FIL-03 PASS: Zero duration was rejected.';
        END;
    END $$;


-- ============================================================
-- FIL-04: Reject negative duration
-- Expected: INSERT fails because duration must be greater than 0
-- ============================================================

INSERT INTO titles (
    name,
    title_type,
    age_category_id
)
VALUES (
           'Test Film Negative Duration',
           'FILM',
           (SELECT age_category_id
            FROM age_categories
            WHERE category_name = 'AL')
       );

DO $$
    BEGIN
        BEGIN
            INSERT INTO films (
                title_id,
                duration_in_seconds
            )
            VALUES (
                       (SELECT title_id
                        FROM titles
                        WHERE name = 'Test Film Negative Duration'),
                       -3600
                   );

            RAISE EXCEPTION 'FIL-04 FAIL: Negative duration was accepted.';

        EXCEPTION
            WHEN check_violation THEN
                RAISE NOTICE 'FIL-04 PASS: Negative duration was rejected.';
        END;
    END $$;


-- ============================================================
-- FIL-05: Reject nonexistent title_id
-- Expected: INSERT fails because of foreign key constraint
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO films (
                title_id,
                duration_in_seconds
            )
            VALUES (
                       -999999,
                       7200
                   );

            RAISE EXCEPTION 'FIL-05 FAIL: Nonexistent title_id was accepted.';

        EXCEPTION
            WHEN foreign_key_violation THEN
                RAISE NOTICE 'FIL-05 PASS: Nonexistent title_id was rejected.';
        END;
    END $$;


-- ============================================================
-- FIL-06: Reject duplicate title_id
-- Expected: INSERT fails because title_id is the primary key
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO films (
                title_id,
                duration_in_seconds
            )
            VALUES (
                       (SELECT title_id
                        FROM titles
                        WHERE name = 'Test Film 1'),
                       5400
                   );

            RAISE EXCEPTION 'FIL-06 FAIL: Duplicate title_id was accepted.';

        EXCEPTION
            WHEN unique_violation THEN
                RAISE NOTICE 'FIL-06 PASS: Duplicate title_id was rejected.';
        END;
    END $$;


-- ============================================================
-- FIL-07: Reject NULL title_id
-- Expected: INSERT fails because title_id is the primary key
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO films (
                title_id,
                duration_in_seconds
            )
            VALUES (
                       NULL,
                       7200
                   );

            RAISE EXCEPTION 'FIL-07 FAIL: NULL title_id was accepted.';

        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE 'FIL-07 PASS: NULL title_id was rejected.';
        END;
    END $$;


-- ============================================================
-- FIL-08: Reject NULL duration
-- Expected: INSERT fails because duration_in_seconds is NOT NULL
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO titles (
                name,
                title_type,
                age_category_id
            )
            VALUES (
                       'Test Film NULL Duration',
                       'FILM',
                       (SELECT age_category_id
                        FROM age_categories
                        WHERE category_name = 'AL')
                   );

            INSERT INTO films (
                title_id,
                duration_in_seconds
            )
            VALUES (
                       (SELECT title_id
                        FROM titles
                        WHERE name = 'Test Film NULL Duration'),
                       NULL
                   );

            RAISE EXCEPTION 'FIL-08 FAIL: NULL duration was accepted.';

        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE 'FIL-08 PASS: NULL duration was rejected.';
        END;
    END $$;


-- ============================================================
-- ROLLBACK TEST DATA
-- ============================================================

ROLLBACK;