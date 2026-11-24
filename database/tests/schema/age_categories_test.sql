BEGIN;

-- ============================================================
-- AGE-01: Valid Kijkwijzer categories
-- ============================================================
-- Purpose:
-- Verify that all seven official categories can be inserted
-- using their correct minimum ages.
-- ============================================================

DO $$
    DECLARE
        inserted_count INTEGER;
    BEGIN
        INSERT INTO age_categories (category_name, minimum_age)
        VALUES
            ('AL', 0),
            ('6', 6),
            ('9', 9),
            ('12', 12),
            ('14', 14),
            ('16', 16),
            ('18', 18);

        GET DIAGNOSTICS inserted_count = ROW_COUNT;

        IF inserted_count <> 7 THEN
            RAISE EXCEPTION
                'AGE-01 FAILED: Expected 7 categories, inserted %',
                inserted_count;
        END IF;

        RAISE NOTICE 'AGE-01 PASSED: All seven valid Kijkwijzer categories were inserted.';

        -- Remove test data so later tests can reuse the categories.
        DELETE FROM age_categories
        WHERE category_name IN ('AL', '6', '9', '12', '14', '16', '18');

    END $$;


-- ============================================================
-- AGE-02: Automatic ID generation
-- ============================================================
-- Purpose:
-- Verify that age_category_id is automatically generated
-- when a category is inserted.
-- ============================================================

DO $$
    DECLARE
        generated_id BIGINT;
    BEGIN
        INSERT INTO age_categories (category_name, minimum_age)
        VALUES ('AL', 0)
        RETURNING age_category_id INTO generated_id;

        IF generated_id IS NULL THEN
            RAISE EXCEPTION
                'AGE-02 FAILED: The category ID was not generated.';
        END IF;

        RAISE NOTICE
            'AGE-02 PASSED: ID % was automatically generated.',
            generated_id;

        DELETE FROM age_categories
        WHERE age_category_id = generated_id;

    END $$;


-- ============================================================
-- AGE-03: Duplicate category rejection
-- ============================================================
-- Purpose:
-- Verify that the UNIQUE constraint prevents duplicate
-- category names.
-- ============================================================

DO $$
    DECLARE
        duplicate_rejected BOOLEAN := FALSE;
    BEGIN
        -- Insert the original category.
        INSERT INTO age_categories (category_name, minimum_age)
        VALUES ('6', 6);

        -- Attempt to insert the same category again.
        BEGIN
            INSERT INTO age_categories (category_name, minimum_age)
            VALUES ('6', 6);

        EXCEPTION
            WHEN unique_violation THEN
                duplicate_rejected := TRUE;
        END;

        IF NOT duplicate_rejected THEN
            RAISE EXCEPTION
                'AGE-03 FAILED: Duplicate category was accepted.';
        END IF;

        RAISE NOTICE
            'AGE-03 PASSED: Duplicate category names are rejected.';

        DELETE FROM age_categories
        WHERE category_name = '6';

    END $$;


-- ============================================================
-- AGE-04: Invalid category name rejection
-- ============================================================
-- Purpose:
-- Verify that category names outside the Kijkwijzer system
-- are rejected.
-- ============================================================

DO $$
    DECLARE
        invalid_category_rejected BOOLEAN := FALSE;
    BEGIN
        BEGIN
            INSERT INTO age_categories (category_name, minimum_age)
            VALUES ('Banana', 0);

        EXCEPTION
            WHEN check_violation THEN
                invalid_category_rejected := TRUE;
        END;

        IF NOT invalid_category_rejected THEN
            RAISE EXCEPTION
                'AGE-04 FAILED: Invalid category name was accepted.';
        END IF;

        RAISE NOTICE
            'AGE-04 PASSED: Invalid category names are rejected.';

    END $$;


-- ============================================================
-- AGE-05: Invalid minimum age rejection
-- ============================================================
-- Purpose:
-- Verify that unsupported minimum ages are rejected.
-- ============================================================

DO $$
    DECLARE
        invalid_age_rejected BOOLEAN := FALSE;
    BEGIN
        BEGIN
            INSERT INTO age_categories (category_name, minimum_age)
            VALUES ('6', 7);

        EXCEPTION
            WHEN check_violation THEN
                invalid_age_rejected := TRUE;
        END;

        IF NOT invalid_age_rejected THEN
            RAISE EXCEPTION
                'AGE-05 FAILED: Unsupported minimum age was accepted.';
        END IF;

        RAISE NOTICE
            'AGE-05 PASSED: Unsupported minimum ages are rejected.';

    END $$;


-- ============================================================
-- AGE-06: Category and minimum age mismatch rejection
-- ============================================================
-- Purpose:
-- Verify that a valid category cannot be paired with
-- an incorrect minimum age.
-- ============================================================

DO $$
    DECLARE
        mismatch_rejected BOOLEAN := FALSE;
    BEGIN
        BEGIN
            INSERT INTO age_categories (category_name, minimum_age)
            VALUES ('6', 18);

        EXCEPTION
            WHEN check_violation THEN
                mismatch_rejected := TRUE;
        END;

        IF NOT mismatch_rejected THEN
            RAISE EXCEPTION
                'AGE-06 FAILED: Incorrect category-age combination was accepted.';
        END IF;

        RAISE NOTICE
            'AGE-06 PASSED: Category and minimum age must match.';

    END $$;


-- ============================================================
-- AGE-07: NULL category name rejection
-- ============================================================
-- Purpose:
-- Verify that category_name cannot be NULL.
-- ============================================================

DO $$
    DECLARE
        null_category_rejected BOOLEAN := FALSE;
    BEGIN
        BEGIN
            INSERT INTO age_categories (category_name, minimum_age)
            VALUES (NULL, 0);

        EXCEPTION
            WHEN not_null_violation THEN
                null_category_rejected := TRUE;
        END;

        IF NOT null_category_rejected THEN
            RAISE EXCEPTION
                'AGE-07 FAILED: NULL category name was accepted.';
        END IF;

        RAISE NOTICE
            'AGE-07 PASSED: NULL category names are rejected.';

    END $$;


-- ============================================================
-- AGE-08: NULL minimum age rejection
-- ============================================================
-- Purpose:
-- Verify that minimum_age cannot be NULL.
-- ============================================================

DO $$
    DECLARE
        null_age_rejected BOOLEAN := FALSE;
    BEGIN
        BEGIN
            INSERT INTO age_categories (category_name, minimum_age)
            VALUES ('18', NULL);

        EXCEPTION
            WHEN not_null_violation THEN
                null_age_rejected := TRUE;
        END;

        IF NOT null_age_rejected THEN
            RAISE EXCEPTION
                'AGE-08 FAILED: NULL minimum age was accepted.';
        END IF;

        RAISE NOTICE
            'AGE-08 PASSED: NULL minimum ages are rejected.';

    END $$;


-- ============================================================
-- Final cleanup
-- ============================================================
-- Roll back all test data and changes made during this suite.
-- ============================================================

ROLLBACK;