-- Purpose:
-- Verify account creation, default values, and database constraints.
--
-- All tests use temporary data inside a transaction.
-- The transaction is rolled back at the end to prevent test data
-- from permanently modifying the database.
-- ============================================================
-- Test IDs:
-- ACC-01: Account creation and default values
-- ACC-02: Reject invalid account status
-- ACC-03: Reject negative failed login attempts
-- ACC-04: Reject duplicate email
-- ACC-05: Reject NULL email
-- ACC-06: Reject NULL password hash
-- ACC-07: Accept valid account statuses
-- ACC-08: Accept valid failed login attempt values
-- ============================================================


BEGIN;


-- ============================================================
-- ACC-01: Account creation and default values
-- ============================================================
-- Expected:
-- - account_id is automatically generated.
-- - is_activated defaults to FALSE.
-- - account_status defaults to ACTIVE.
-- - failed_login_attempts defaults to 0.
-- - blocked_until defaults to NULL.
-- ============================================================

DO $$
    DECLARE
        test_account_id BIGINT;
        test_account RECORD;
    BEGIN
        INSERT INTO accounts (email, password_hash)
        VALUES ('acc01_test@example.com', 'test_hash')
        RETURNING account_id INTO test_account_id;

        SELECT *
        INTO test_account
        FROM accounts
        WHERE account_id = test_account_id;

        ASSERT test_account_id IS NOT NULL,
            'ACC-01 FAILED: account_id was not generated';

        ASSERT test_account.is_activated = FALSE,
            'ACC-01 FAILED: is_activated should default to FALSE';

        ASSERT test_account.account_status = 'ACTIVE',
            'ACC-01 FAILED: account_status should default to ACTIVE';

        ASSERT test_account.failed_login_attempts = 0,
            'ACC-01 FAILED: failed_login_attempts should default to 0';

        ASSERT test_account.blocked_until IS NULL,
            'ACC-01 FAILED: blocked_until should default to NULL';

        RAISE NOTICE 'ACC-01 PASSED: Account creation and default values verified.';
    END $$;


-- ============================================================
-- ACC-02: Reject invalid account status
-- ============================================================
-- Expected:
-- An account with an invalid status must be rejected by the
-- account_status CHECK constraint.
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO accounts (email, password_hash, account_status)
            VALUES ('acc02_test@example.com', 'test_hash', 'BANNED');

            RAISE EXCEPTION
                'ACC-02 FAILED: Invalid account status was accepted';

        EXCEPTION
            WHEN check_violation THEN
                RAISE NOTICE
                    'ACC-02 PASSED: Invalid account status was rejected.';
        END;
    END $$;


-- ============================================================
-- ACC-03: Reject negative failed login attempts
-- ============================================================
-- Expected:
-- failed_login_attempts must not accept negative values.
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO accounts (email, password_hash, failed_login_attempts)
            VALUES ('acc03_test@example.com', 'test_hash', -1);

            RAISE EXCEPTION
                'ACC-03 FAILED: Negative failed login attempts were accepted';

        EXCEPTION
            WHEN check_violation THEN
                RAISE NOTICE
                    'ACC-03 PASSED: Negative failed login attempts were rejected.';
        END;
    END $$;


-- ============================================================
-- ACC-04: Reject duplicate email
-- ============================================================
-- Expected:
-- The accounts table must not allow two accounts with the
-- same email address.
-- ============================================================

DO $$
    BEGIN
        -- Create the first account.
        INSERT INTO accounts (email, password_hash)
        VALUES ('acc04_test@example.com', 'test_hash');

        BEGIN
            -- Attempt to create another account using the same email.
            INSERT INTO accounts (email, password_hash)
            VALUES ('acc04_test@example.com', 'another_test_hash');

            RAISE EXCEPTION
                'ACC-04 FAILED: Duplicate email was accepted';

        EXCEPTION
            WHEN unique_violation THEN
                RAISE NOTICE
                    'ACC-04 PASSED: Duplicate email was rejected.';
        END;
    END $$;


-- ============================================================
-- ACC-05: Reject NULL email
-- ============================================================
-- Expected:
-- An account cannot be created without an email address.
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO accounts (email, password_hash)
            VALUES (NULL, 'test_hash');

            RAISE EXCEPTION
                'ACC-05 FAILED: NULL email was accepted';

        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE
                    'ACC-05 PASSED: NULL email was rejected.';
        END;
    END $$;


-- ============================================================
-- ACC-06: Reject NULL password hash
-- ============================================================
-- Expected:
-- An account cannot be created without a password hash.
-- ============================================================

DO $$
    BEGIN
        BEGIN
            INSERT INTO accounts (email, password_hash)
            VALUES ('acc06_test@example.com', NULL);

            RAISE EXCEPTION
                'ACC-06 FAILED: NULL password hash was accepted';

        EXCEPTION
            WHEN not_null_violation THEN
                RAISE NOTICE
                    'ACC-06 PASSED: NULL password hash was rejected.';
        END;
    END $$;


-- ============================================================
-- ACC-07: Accept valid account statuses
-- ============================================================
-- Expected:
-- ACTIVE, SUSPENDED, and CLOSED must all be accepted.
-- ============================================================

DO $$
    DECLARE
        inserted_accounts INTEGER;
    BEGIN
        INSERT INTO accounts (email, password_hash, account_status)
        VALUES
            ('acc07_active@example.com', 'test_hash', 'ACTIVE'),
            ('acc07_suspended@example.com', 'test_hash', 'SUSPENDED'),
            ('acc07_closed@example.com', 'test_hash', 'CLOSED');

        GET DIAGNOSTICS inserted_accounts = ROW_COUNT;

        ASSERT inserted_accounts = 3,
            'ACC-07 FAILED: Expected three accounts to be inserted';

        RAISE NOTICE
            'ACC-07 PASSED: All permitted account statuses were accepted.';
    END $$;


-- ============================================================
-- ACC-08: Accept valid failed login attempt values
-- ============================================================
-- Expected:
-- Zero and positive failed login attempt values must be accepted.
-- ============================================================

DO $$
    DECLARE
        inserted_accounts INTEGER;
    BEGIN
        INSERT INTO accounts (email, password_hash, failed_login_attempts)
        VALUES
            ('acc08_zero@example.com', 'test_hash', 0),
            ('acc08_positive@example.com', 'test_hash', 3);

        GET DIAGNOSTICS inserted_accounts = ROW_COUNT;

        ASSERT inserted_accounts = 2,
            'ACC-08 FAILED: Expected two accounts to be inserted';

        RAISE NOTICE
            'ACC-08 PASSED: Valid failed login attempt values were accepted.';
    END $$;


-- ============================================================
-- CLEANUP
-- ============================================================
-- Roll back all test data created by this test file.
-- ============================================================

ROLLBACK;