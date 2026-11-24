-- ============================================================
-- Test IDs: SER-01 to SER-04
-- ============================================================

BEGIN;


-- ============================================================
-- SER-01: Insert a valid series
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
           'Test Series 1',
           'Series used for testing the series table',
           '2025-01-01',
           'SERIES',
           (SELECT age_category_id
            FROM age_categories
            WHERE category_name = '12')
       );

INSERT INTO series (
    title_id
)
VALUES (
           (SELECT title_id
            FROM titles
            WHERE name = 'Test Series 1')
       );

DO $$
    BEGIN
        RAISE NOTICE 'SER-01 PASS: Valid series inserted successfully.';
    END $$;


-- ============================================================
-- SER-02: Reject nonexistent title_id
-- Expected: INSERT fails because of foreign key constraint
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO series (
                title_id
            )
            VALUES (
                       -999999
                   );

            RAISE EXCEPTION 'SER-02 FAIL: Nonexistent title_id was accepted.';

        EXCEPTION
            WHEN foreign_key_violation THEN
                RAISE NOTICE 'SER-02 PASS: Nonexistent title_id was rejected.';
        END;
    END $$;


-- ============================================================
-- SER-03: Reject duplicate title_id
-- Expected: INSERT fails because title_id is the primary key
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO series (
                title_id
            )
            VALUES (
                       (SELECT title_id
                        FROM titles
                        WHERE name = 'Test Series 1')
                   );

            RAISE EXCEPTION 'SER-03 FAIL: Duplicate title_id was accepted.';

        EXCEPTION
            WHEN unique_violation THEN
                RAISE NOTICE 'SER-03 PASS: Duplicate title_id was rejected.';
        END;
    END $$;


-- ============================================================
-- SER-04: Reject NULL title_id
-- Expected: INSERT fails because title_id is the primary key
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO series (
                title_id
            )
            VALUES (
                       NULL
                   );

            RAISE EXCEPTION 'SER-04 FAIL: NULL title_id was accepted.';

        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE 'SER-04 PASS: NULL title_id was rejected.';
        END;
    END $$;


-- ============================================================
-- ROLLBACK TEST DATA
-- ============================================================

ROLLBACK;