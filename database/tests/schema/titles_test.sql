-- ============================================================
-- Test IDs: TIT-01 to TIT-10
-- ============================================================

BEGIN;

-- ============================================================
-- TIT-01: Insert a valid film title
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
           'Test Film',
           'Test film description',
           '2025-01-01',
           'FILM',
           (SELECT age_category_id
            FROM age_categories
            WHERE category_name = '12')
       );

DO $$
    BEGIN
        RAISE NOTICE 'TIT-01 PASS: Valid film title inserted successfully.';
    END $$;


-- ============================================================
-- TIT-02: Insert a valid series title
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
           'Test Series',
           'Test series description',
           '2024-01-01',
           'SERIES',
           (SELECT age_category_id
            FROM age_categories
            WHERE category_name = 'AL')
       );

DO $$
    BEGIN
        RAISE NOTICE 'TIT-02 PASS: Valid series title inserted successfully.';
    END $$;


-- ============================================================
-- TIT-03: Verify title_id is automatically generated
-- Expected: title_id is not NULL
-- ============================================================

DO $$
    DECLARE
        generated_id BIGINT;
    BEGIN
        SELECT title_id
        INTO generated_id
        FROM titles
        WHERE name = 'Test Film';

        IF generated_id IS NULL THEN
            RAISE EXCEPTION 'TIT-03 FAIL: title_id was not generated.';
        END IF;

        RAISE NOTICE 'TIT-03 PASS: title_id was automatically generated.';
    END $$;


-- ============================================================
-- TIT-04: Description can be NULL
-- Expected: INSERT succeeds
-- ============================================================

INSERT INTO titles (
    name,
    title_type,
    age_category_id
)
VALUES (
           'Test Title Without Description',
           'FILM',
           (SELECT age_category_id
            FROM age_categories
            WHERE category_name = 'AL')
       );

DO $$
    BEGIN
        RAISE NOTICE 'TIT-04 PASS: NULL description is allowed.';
    END $$;


-- ============================================================
-- TIT-05: Release date can be NULL
-- Expected: INSERT succeeds
-- ============================================================

INSERT INTO titles (
    name,
    description,
    title_type,
    age_category_id
)
VALUES (
           'Test Title Without Release Date',
           'Title with no release date',
           'SERIES',
           (SELECT age_category_id
            FROM age_categories
            WHERE category_name = '6')
       );

DO $$
    BEGIN
        RAISE NOTICE 'TIT-05 PASS: NULL release_date is allowed.';
    END $$;


-- ============================================================
-- TIT-06: Reject NULL name
-- Expected: INSERT fails
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
                       NULL,
                       'FILM',
                       (SELECT age_category_id
                        FROM age_categories
                        WHERE category_name = 'AL')
                   );

            RAISE EXCEPTION 'TIT-06 FAIL: NULL name was accepted.';

        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE 'TIT-06 PASS: NULL name was rejected.';
        END;
    END $$;


-- ============================================================
-- TIT-07: Reject NULL title_type
-- Expected: INSERT fails
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO titles (
                name,
                age_category_id
            )
            VALUES (
                       'Test Title Without Type',
                       (SELECT age_category_id
                        FROM age_categories
                        WHERE category_name = 'AL')
                   );

            RAISE EXCEPTION 'TIT-07 FAIL: NULL title_type was accepted.';

        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE 'TIT-07 PASS: NULL title_type was rejected.';
        END;
    END $$;

-- ============================================================
-- TIT-08: Reject invalid title_type
-- Expected: INSERT fails because of CHECK constraint
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
                       'Test Invalid Type',
                       'ANIMATION',
                       (SELECT age_category_id
                        FROM age_categories
                        WHERE category_name = 'AL')
                   );

            RAISE EXCEPTION 'TIT-08 FAIL: Invalid title_type was accepted.';

        EXCEPTION
            WHEN check_violation THEN
                RAISE NOTICE 'TIT-08 PASS: Invalid title_type was rejected.';
        END;
    END $$;

-- ============================================================
-- TIT-09: Reject NULL age_category_id
-- Expected: INSERT fails
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO titles (
                name,
                title_type
            )
            VALUES (
                       'Test Title Without Age Category',
                       'FILM'
                   );

            RAISE EXCEPTION 'TIT-09 FAIL: NULL age_category_id was accepted.';

        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE 'TIT-09 PASS: NULL age_category_id was rejected.';
        END;
    END $$;


-- ============================================================
-- TIT-10: Reject nonexistent age_category_id
-- Expected: INSERT fails
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
                       'Test Invalid Age Category',
                       'FILM',
                       -999999
                   );

            RAISE EXCEPTION 'TIT-10 FAIL: Invalid age_category_id was accepted.';

        EXCEPTION
            WHEN foreign_key_violation THEN
                RAISE NOTICE 'TIT-10 PASS: Invalid age_category_id was rejected.';
        END;
    END $$;


-- ============================================================
-- ROLLBACK TEST DATA
-- ============================================================

ROLLBACK;