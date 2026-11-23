-- ============================================================
-- Purpose:
-- Verify that the profiles table correctly enforces its primary key,
-- foreign keys, required fields, and case-insensitive uniqueness.
--
-- Test IDs:
-- PRO-01: Insert a profile with valid data
-- PRO-02: Profile ID is automatically generated
-- PRO-03: Profile image is optional
-- PRO-04: Reject nonexistent account ID
-- PRO-05: Reject nonexistent age category ID
-- PRO-06: Reject duplicate profile name within the same account
-- PRO-07: Reject profile names differing only by capitalization
-- PRO-08: Allow the same profile name for different accounts
-- PRO-09: Reject NULL profile name
-- PRO-10: Reject NULL account ID
-- PRO-11: Reject NULL age category ID
--
-- All test data is rolled back at the end.
-- ============================================================

BEGIN;

DO $$
    DECLARE
        test_account_1 BIGINT;
        test_account_2 BIGINT;
        test_account_3 BIGINT;
        test_age_category BIGINT;
        generated_profile_id BIGINT;
    BEGIN

        -- ========================================================
        -- TEST FIXTURES
        -- Create temporary test accounts and age category.
        -- ========================================================

        INSERT INTO accounts (email, password_hash)
        VALUES ('profiles_test_1@example.com', 'test_hash')
        RETURNING account_id INTO test_account_1;

        INSERT INTO accounts (email, password_hash)
        VALUES ('profiles_test_2@example.com', 'test_hash')
        RETURNING account_id INTO test_account_2;

        INSERT INTO accounts (email, password_hash)
        VALUES ('profiles_test_3@example.com', 'test_hash')
        RETURNING account_id INTO test_account_3;

        INSERT INTO age_categories (category_name, minimum_age)
        VALUES ('AL', 0)
        RETURNING age_category_id INTO test_age_category;


        -- ========================================================
        -- PRO-01: Insert a profile with valid data
        -- ========================================================

        INSERT INTO profiles (
            account_id,
            profile_name,
            age_category_id,
            profile_image
        )
        VALUES (
                   test_account_1,
                   'Test Profile',
                   test_age_category,
                   'test_profile_image.png'
               );

        RAISE NOTICE 'PRO-01 PASSED: Profile with valid data was created.';


        -- ========================================================
        -- PRO-02: Profile ID is automatically generated
        -- ========================================================

        INSERT INTO profiles (
            account_id,
            profile_name,
            age_category_id
        )
        VALUES (
                   test_account_1,
                   'Second Profile',
                   test_age_category
               )
        RETURNING profile_id INTO generated_profile_id;

        IF generated_profile_id IS NOT NULL THEN
            RAISE NOTICE 'PRO-02 PASSED: Profile ID was automatically generated.';
        ELSE
            RAISE EXCEPTION 'PRO-02 FAILED: Profile ID was not generated.';
        END IF;


        -- ========================================================
        -- PRO-03: Profile image is optional
        -- ========================================================

        INSERT INTO profiles (
            account_id,
            profile_name,
            age_category_id
        )
        VALUES (
                   test_account_1,
                   'Profile Without Image',
                   test_age_category
               );

        RAISE NOTICE 'PRO-03 PASSED: Profile without an image was created.';


        -- ========================================================
        -- PRO-04: Reject nonexistent account ID
        -- ========================================================

        BEGIN
            INSERT INTO profiles (
                account_id,
                profile_name,
                age_category_id
            )
            VALUES (
                       -999999,
                       'Invalid Account Profile',
                       test_age_category
                   );

            RAISE EXCEPTION 'PRO-04 FAILED: Nonexistent account ID was accepted.';
        EXCEPTION
            WHEN foreign_key_violation THEN
                RAISE NOTICE 'PRO-04 PASSED: Nonexistent account ID was rejected.';
        END;


        -- ========================================================
        -- PRO-05: Reject nonexistent age category ID
        -- ========================================================

        BEGIN
            INSERT INTO profiles (
                account_id,
                profile_name,
                age_category_id
            )
            VALUES (
                       test_account_1,
                       'Invalid Age Category Profile',
                       -999999
                   );

            RAISE EXCEPTION 'PRO-05 FAILED: Nonexistent age category ID was accepted.';
        EXCEPTION
            WHEN foreign_key_violation THEN
                RAISE NOTICE 'PRO-05 PASSED: Nonexistent age category ID was rejected.';
        END;


        -- ========================================================
        -- PRO-06: Reject duplicate profile name within same account
        -- ========================================================

        BEGIN
            INSERT INTO profiles (
                account_id,
                profile_name,
                age_category_id
            )
            VALUES (
                       test_account_1,
                       'Test Profile',
                       test_age_category
                   );

            RAISE EXCEPTION 'PRO-06 FAILED: Duplicate profile name was accepted.';
        EXCEPTION
            WHEN unique_violation THEN
                RAISE NOTICE 'PRO-06 PASSED: Duplicate profile name was rejected.';
        END;


        -- ========================================================
        -- PRO-07: Reject profile names differing only by capitalization
        -- ========================================================

        BEGIN
            INSERT INTO profiles (
                account_id,
                profile_name,
                age_category_id
            )
            VALUES (
                       test_account_1,
                       'test profile',
                       test_age_category
                   );

            RAISE EXCEPTION 'PRO-07 FAILED: Case-insensitive duplicate name was accepted.';
        EXCEPTION
            WHEN unique_violation THEN
                RAISE NOTICE 'PRO-07 PASSED: Case-insensitive duplicate name was rejected.';
        END;


        -- ========================================================
        -- PRO-08: Allow the same profile name for different accounts
        -- ========================================================

        INSERT INTO profiles (
            account_id,
            profile_name,
            age_category_id
        )
        VALUES (
                   test_account_2,
                   'Test Profile',
                   test_age_category
               );

        RAISE NOTICE 'PRO-08 PASSED: Same profile name was allowed for a different account.';


        -- ========================================================
        -- PRO-09: Reject NULL profile name
        -- ========================================================

        BEGIN
            INSERT INTO profiles (
                account_id,
                profile_name,
                age_category_id
            )
            VALUES (
                       test_account_1,
                       NULL,
                       test_age_category
                   );

            RAISE EXCEPTION 'PRO-09 FAILED: NULL profile name was accepted.';
        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE 'PRO-09 PASSED: NULL profile name was rejected.';
        END;


        -- ========================================================
        -- PRO-10: Reject NULL account ID
        -- ========================================================

        BEGIN
            INSERT INTO profiles (
                account_id,
                profile_name,
                age_category_id
            )
            VALUES (
                       NULL,
                       'Null Account Profile',
                       test_age_category
                   );

            RAISE EXCEPTION 'PRO-10 FAILED: NULL account ID was accepted.';
        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE 'PRO-10 PASSED: NULL account ID was rejected.';
        END;


        -- ========================================================
        -- PRO-11: Reject NULL age category ID
        -- ========================================================

        BEGIN
            INSERT INTO profiles (
                account_id,
                profile_name,
                age_category_id
            )
            VALUES (
                       test_account_1,
                       'Null Age Category Profile',
                       NULL
                   );

            RAISE EXCEPTION 'PRO-11 FAILED: NULL age category ID was accepted.';
        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE 'PRO-11 PASSED: NULL age category ID was rejected.';
        END;


    END $$;

ROLLBACK;