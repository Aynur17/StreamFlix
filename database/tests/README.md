# StreamFlix Database Testing

## 1. Purpose

This directory contains tests used to verify the correctness, integrity, and expected behaviour of the StreamFlix database.

Testing is performed during database development to identify problems early and to verify that database constraints and implemented functionality behave as expected.

The tests are designed to cover:

- Valid data insertion
- Invalid data rejection
- Default values
- Primary keys and unique constraints
- Foreign key relationships
- Check constraints
- Database functions and procedures
- Triggers
- Views
- Database permissions and security

Tests use temporary data whenever possible. Transactions and rollback operations are used to prevent test data from unnecessarily modifying the development database.

---

## 2. Test Directory Structure

```text
tests/
├── README.md
└── schema/
    └── accounts_test.sql
```

### Directory responsibilities

| Directory | Purpose |
|---|---|
| `schema/` | Tests related to table structures, data types, defaults, constraints, and data integrity. |
| `functions/` | Tests for database functions and stored procedures. |
| `triggers/` | Tests for automated database behaviour triggered by data changes. |
| `views/` | Tests for database views and the information they expose. |
| `security/` | Tests for roles, privileges, and access restrictions. |

Additional test directories will be created as the database implementation progresses and when they are needed.

---

## 3. Testing conventions

The following conventions are used when creating database tests:

- Tests are grouped by database table or major database component rather than creating a separate file for every individual test case.
- Each test case receives a unique identifier.
- Test cases are separated and documented using SQL comments.
- Both valid and invalid inputs are tested where applicable.
- Assertions are used to verify expected results.
- Expected constraint violations are handled explicitly.
- Temporary test data is rolled back whenever possible.
- Tests should be reproducible and should not depend on previously created test data.

### Test ID conventions

| Prefix | Component |
|---|---|
| `ACC` | Accounts |
| `PRO` | Profiles |
| `TIT` | Titles |
| `GEN` | Genres |
| `SUB` | Subscriptions |

Prefixes will be expanded as additional database components are implemented.

---

## 4. Executing SQL tests

Tests are executed against the PostgreSQL database running through Docker Compose.

### Database connection

| Setting | Value |
|---|---|
| DBMS | PostgreSQL 17 |
| Host | `localhost` |
| Port | `5432` |
| Database | `streamflix` |
| Schema | `public` |

### Execution through IntelliJ IDEA

1. Open the relevant SQL test file.
2. Ensure the execution target is connected to `streamflix.public`.
3. Select the test script.
4. Execute it using the SQL editor's execution command.
5. Review the execution output.
6. Verify that the expected success messages are present and that the script completes successfully.

Tests use `RAISE NOTICE` to report successful test execution and `ASSERT` statements to verify expected conditions.

---

## 5. Test results

### Accounts table

Test file: `schema/accounts_test.sql`

| Test ID | Description | Expected result | Status |
|---|---|---|---|
| ACC-01 | Account creation and default values | Account is created and defaults are applied correctly | PASS |
| ACC-02 | Invalid account status | Invalid status rejected | PASS |
| ACC-03 | Negative failed login attempts | Negative value rejected | PASS |
| ACC-04 | Duplicate email | Duplicate email rejected | PASS |
| ACC-05 | NULL email | NULL email rejected | PASS |
| ACC-06 | NULL password hash | NULL password hash rejected | PASS |
| ACC-07 | Valid account statuses | All permitted statuses accepted | PASS |
| ACC-08 | Valid failed login attempts | Valid values accepted | PASS |

**Result:** 8/8 tests passed.

Date executed: 23 November 2026

---

## 6. Test safety

Test data should not unnecessarily remain in the development database.

Whenever possible, tests are executed within a transaction and concluded with `ROLLBACK`. This removes test data created during the test execution.

Database sequence values may still advance after rollback. Gaps in generated IDs are therefore expected and do not indicate missing records or database corruption.

Tests should not use real user credentials or sensitive personal data.

---

## 7. Future testing

Testing will expand alongside database implementation.

Planned coverage includes:

- Table and relationship integrity
- Profile age restrictions and preferences
- Content and genre relationships
- Viewing history and playback progress
- Watchlist behaviour
- Subscription and payment relationships
- Referral discount logic
- Trigger behaviour
- Stored procedures and functions
- Employee access and API database permissions
- View correctness and access restrictions

The testing documentation will be updated as new database components are implemented and verified.