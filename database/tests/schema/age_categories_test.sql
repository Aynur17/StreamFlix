-- ============================================================
-- AGE CATEGORIES TABLE TEST SUITE
-- ============================================================
-- Purpose:
-- Verify the constraints and expected behaviour of age_categories.
--
-- Test data is temporary and will be rolled back at the end.
-- ============================================================

BEGIN;


-- ============================================================
-- AGE-01: Age category creation and ID generation
-- ============================================================

DO $$
    DECLARE
        generated_id BIGINT;
    BEGIN
        INSERT INTO age_categories (category_name, minimum_age)
        VALUES ('AGE01_Test_Category', 12)
        RETURNING age_category_id INTO generated_id;

        IF generated_id IS NULL THEN
            RAISE EXCEPTION 'AGE-01 FAILED: ID was not generated.';
        END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM age_categories
            WHERE age_category_id = generated_id
              AND category_name = 'AGE01_Test_Category'
              AND minimum_age = 12
        ) THEN
            RAISE EXCEPTION 'AGE-01 FAILED: Inserted category was not found or values were incorrect.';
        END IF;

        RAISE NOTICE 'AGE-01 PASSED: Age category creation and ID generation verified.';
    END $$;


-- ============================================================
-- AGE-02: Multiple age categories with distinct IDs
-- ============================================================

DO $$
    DECLARE
        first_id BIGINT;
        second_id BIGINT;
    BEGIN
        INSERT INTO age_categories (category_name, minimum_age)
        VALUES ('AGE02_Test_Category_A', 0)
        RETURNING age_category_id INTO first_id;

        INSERT INTO age_categories (category_name, minimum_age)
        VALUES ('AGE02_Test_Category_B', 18)
        RETURNING age_category_id INTO second_id;

        IF first_id = second_id THEN
            RAISE EXCEPTION 'AGE-02 FAILED: Generated IDs are not distinct.';
        END IF;

        RAISE NOTICE 'AGE-02 PASSED: Multiple categories received distinct IDs.';
    END $$;


-- ============================================================
-- AGE-03: Reject duplicate category names
-- ============================================================

DO $$
    BEGIN
        INSERT INTO age_categories (category_name, minimum_age)
        VALUES ('AGE03_Duplicate_Category', 10);

        BEGIN
            INSERT INTO age_categories (category_name, minimum_age)
            VALUES ('AGE03_Duplicate_Category', 18);

            RAISE EXCEPTION 'AGE-03 FAILED: Duplicate category name was accepted.';
        EXCEPTION
            WHEN unique_violation THEN
                RAISE NOTICE 'AGE-03 PASSED: Duplicate category name was rejected.';
        END;
    END $$;


-- ============================================================
-- AGE-04: Reject NULL category name
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO age_categories (category_name, minimum_age)
            VALUES (NULL, 12);

            RAISE EXCEPTION 'AGE-04 FAILED: NULL category name was accepted.';
        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE 'AGE-04 PASSED: NULL category name was rejected.';
        END;
    END $$;


-- ============================================================
-- AGE-05: Reject NULL minimum age
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO age_categories (category_name, minimum_age)
            VALUES ('AGE05_Test_Category', NULL);

            RAISE EXCEPTION 'AGE-05 FAILED: NULL minimum age was accepted.';
        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE 'AGE-05 PASSED: NULL minimum age was rejected.';
        END;
    END $$;


-- ============================================================
-- AGE-06: Reject negative minimum age
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO age_categories (category_name, minimum_age)
            VALUES ('AGE06_Test_Category', -1);

            RAISE EXCEPTION 'AGE-06 FAILED: Negative minimum age was accepted.';
        EXCEPTION
            WHEN check_violation THEN
                RAISE NOTICE 'AGE-06 PASSED: Negative minimum age was rejected.';
        END;
    END $$;


-- ============================================================
-- AGE-07: Accept minimum age of zero
-- ============================================================

DO $$
    DECLARE
        inserted_age INTEGER;
    BEGIN
        INSERT INTO age_categories (category_name, minimum_age)
        VALUES ('AGE07_Test_Category', 0)
        RETURNING minimum_age INTO inserted_age;

        IF inserted_age <> 0 THEN
            RAISE EXCEPTION 'AGE-07 FAILED: Minimum age of zero was not stored correctly.';
        END IF;

        RAISE NOTICE 'AGE-07 PASSED: Minimum age of zero was accepted.';
    END $$;


-- ============================================================
-- AGE-08: Accept valid positive minimum age
-- ============================================================

DO $$
    DECLARE
        inserted_age INTEGER;
    BEGIN
        INSERT INTO age_categories (category_name, minimum_age)
        VALUES ('AGE08_Test_Category', 18)
        RETURNING minimum_age INTO inserted_age;

        IF inserted_age <> 18 THEN
            RAISE EXCEPTION 'AGE-08 FAILED: Positive minimum age was not stored correctly.';
        END IF;

        RAISE NOTICE 'AGE-08 PASSED: Valid positive minimum age was accepted.';
    END $$;


-- ============================================================
-- ROLLBACK TEST DATA
-- ============================================================

ROLLBACK;