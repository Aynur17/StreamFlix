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
├── schema/
│   ├── accounts_test.sql
│   ├── age_categories_test.sql
│   ├── profiles_test.sql
│   ├── titles_test.sql
│   ├── films_test.sql
│   ├── series_test.sql
│   ├── seasons_test.sql
│   └── episodes_test.sql
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
- Conditional checks are used to verify expected results.
- Expected constraint violations are handled explicitly.
- Successful tests report their results using `RAISE NOTICE`.
- Temporary test data is rolled back whenever possible.
- Tests should be reproducible and should not depend on previously created test data.

### Test ID conventions

| Prefix | Component |
|---|---|
| `ACC` | Accounts |
| `AGE` | Age Categories |
| `PRO` | Profiles |
| `TIT` | Titles |
| `FIL` | Films |
| `SER` | Series |
| `SEA` | Seasons |
| `EPI` | Episodes |
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

Tests use `RAISE NOTICE` to report successful test execution and conditional checks to verify expected results.

Expected database errors are handled explicitly within individual test blocks. If an unexpected result occurs, the test raises an exception indicating that the test failed.

---

## 5. Test results

The following sections document the tests that have been executed and verified successfully.

### Accounts table

**Test file:** `schema/accounts_test.sql`

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

### Age Categories table

**Test file:** `schema/age_categories_test.sql`

The Age Categories table uses the Dutch Kijkwijzer age classification system. The database restricts category names and minimum ages to the supported categories and ensures that each category is paired with its corresponding minimum age.

| Category | Minimum age |
|---|---:|
| AL | 0 |
| 6 | 6 |
| 9 | 9 |
| 12 | 12 |
| 14 | 14 |
| 16 | 16 |
| 18 | 18 |

#### Test cases

| Test ID | Description | Expected result | Status |
|---|---|---|---|
| AGE-01 | Valid Kijkwijzer categories | All seven valid categories accepted | PASS |
| AGE-02 | Automatic ID generation | Category ID generated automatically | PASS |
| AGE-03 | Duplicate category names | Duplicate category rejected | PASS |
| AGE-04 | Invalid category name | Invalid category rejected | PASS |
| AGE-05 | Invalid minimum age | Unsupported minimum age rejected | PASS |
| AGE-06 | Category and minimum age mismatch | Incorrect category-age combination rejected | PASS |
| AGE-07 | NULL category name | NULL category name rejected | PASS |
| AGE-08 | NULL minimum age | NULL minimum age rejected | PASS |

**Result:** 8/8 tests passed, 0 failures.

Date executed: 23 November 2026

All test data was removed using transaction rollback.

---

### Profiles table

**Test file:** `schema/profiles_test.sql`

The Profiles table stores individual user profiles associated with an account. Each profile is linked to an account and an age category. Profile images are optional.

Profile names must be unique within the same account, regardless of capitalization. However, different accounts are allowed to use the same profile name.

#### Test cases

| Test ID | Description | Expected result | Status |
|---|---|---|---|
| PRO-01 | Valid profile creation | Profile created successfully | PASS |
| PRO-02 | Automatic profile ID generation | Profile ID generated automatically | PASS |
| PRO-03 | Optional profile image | Profile without image accepted | PASS |
| PRO-04 | Nonexistent account ID | Invalid account reference rejected | PASS |
| PRO-05 | Nonexistent age category ID | Invalid age category reference rejected | PASS |
| PRO-06 | Duplicate profile name within the same account | Duplicate name rejected | PASS |
| PRO-07 | Case-insensitive duplicate profile name | Name differing only by capitalization rejected | PASS |
| PRO-08 | Same profile name for different accounts | Duplicate name allowed for another account | PASS |
| PRO-09 | NULL profile name | NULL profile name rejected | PASS |
| PRO-10 | NULL account ID | NULL account ID rejected | PASS |
| PRO-11 | NULL age category ID | NULL age category ID rejected | PASS |

**Result:** 11/11 tests passed, 0 failures.

Date executed: 23 November 2026

All test data was removed using transaction rollback.

---

### Titles table

**Test file:** `schema/titles_test.sql`

The Titles table acts as the central entity for all content available in StreamFlix. It stores general information shared by films and series, including the title name, description, release date, title type, and age category.

The `title_type` column determines whether a title is classified as a `FILM` or a `SERIES`. Each title must also be associated with an existing age category.

#### Test cases

| Test ID | Description | Expected result | Status |
|---|---|---|---|
| TIT-01 | Valid film title | Film title inserted successfully | PASS |
| TIT-02 | Valid series title | Series title inserted successfully | PASS |
| TIT-03 | Automatic title ID generation | Title ID generated automatically | PASS |
| TIT-04 | NULL description | Title without description accepted | PASS |
| TIT-05 | NULL release date | Title without release date accepted | PASS |
| TIT-06 | NULL title name | NULL title name rejected | PASS |
| TIT-07 | NULL title type | NULL title type rejected | PASS |
| TIT-08 | Invalid title type | Unsupported title type rejected | PASS |
| TIT-09 | NULL age category | NULL age category rejected | PASS |
| TIT-10 | Nonexistent age category ID | Invalid age category reference rejected | PASS |

**Result:** 10/10 tests passed, 0 failures.

Date executed: 24 November 2026

All test data was removed using transaction rollback.

---

### Films table

**Test file:** `schema/films_test.sql`

The Films table stores film-specific information. Each film is connected to an existing record in the Titles table and stores its duration in seconds.

Film durations must be greater than zero. The `title_id` also acts as the primary key, ensuring that the same title cannot be registered more than once in the Films table.

#### Test cases

| Test ID | Description | Expected result | Status |
|---|---|---|---|
| FIL-01 | Valid film creation | Film created successfully | PASS |
| FIL-02 | Positive duration | Film with valid duration accepted | PASS |
| FIL-03 | Zero duration | Duration of zero rejected | PASS |
| FIL-04 | Negative duration | Negative duration rejected | PASS |
| FIL-05 | Nonexistent title ID | Invalid title reference rejected | PASS |
| FIL-06 | Duplicate title ID | Duplicate film rejected | PASS |
| FIL-07 | NULL title ID | NULL title ID rejected | PASS |
| FIL-08 | NULL duration | NULL duration rejected | PASS |

**Result:** 8/8 tests passed, 0 failures.

Date executed: 24 November 2026

All test data was removed using transaction rollback.

---

### Series table

**Test file:** `schema/series_test.sql`

The Series table stores the series-specific classification of content. Each series is linked to an existing record in the Titles table, with the `title_id` serving as both the primary key and a foreign key.

This ensures that a series record cannot exist without a corresponding title record.

#### Test cases

| Test ID | Description | Expected result | Status |
|---|---|---|---|
| SER-01 | Valid series creation | Series created successfully | PASS |
| SER-02 | Nonexistent title ID | Invalid title reference rejected | PASS |
| SER-03 | Duplicate title ID | Duplicate series rejected | PASS |
| SER-04 | NULL title ID | NULL title ID rejected | PASS |

**Result:** 4/4 tests passed, 0 failures.

Date executed: 24 November 2026

All test data was removed using transaction rollback.

---

### Seasons table

**Test file:** `schema/seasons_test.sql`

The Seasons table stores the seasons belonging to a series. Each season is linked to an existing series through the `series_id` foreign key.

Season numbers must be greater than zero. A unique constraint on `(series_id, season_number)` ensures that a series cannot contain duplicate season numbers while allowing different series to have seasons with the same number.

#### Test cases

| Test ID | Description | Expected result | Status |
|---|---|---|---|
| SEA-01 | Valid season creation | Season created successfully | PASS |
| SEA-02 | Automatic season ID generation | Season ID generated automatically | PASS |
| SEA-03 | Season number zero | Season number of zero rejected | PASS |
| SEA-04 | Negative season number | Negative season number rejected | PASS |
| SEA-05 | Nonexistent series ID | Invalid series reference rejected | PASS |
| SEA-06 | Duplicate season number within the same series | Duplicate season rejected | PASS |
| SEA-07 | Same season number in different series | Same season number allowed for another series | PASS |
| SEA-08 | NULL series ID | NULL series ID rejected | PASS |
| SEA-09 | NULL season number | NULL season number rejected | PASS |

**Result:** 9/9 tests passed, 0 failures.

Date executed: 24 November 2026

All test data was removed using transaction rollback.

---

### Episodes table

**Test file:** `schema/episodes_test.sql`

The Episodes table stores individual episodes belonging to a season. Each episode is connected to an existing season through the `season_id` foreign key.

Episodes have a required episode number, name, and duration. Descriptions are optional. Episode numbers and durations must be greater than zero.

The unique constraint on `(season_id, episode_number)` prevents duplicate episode numbers within the same season while allowing episode numbering to restart in a different season.

#### Test cases

| Test ID | Description | Expected result | Status |
|---|---|---|---|
| EPI-01 | Valid episode creation | Episode created successfully | PASS |
| EPI-02 | Automatic episode ID generation | Episode ID generated automatically | PASS |
| EPI-03 | Optional episode description | Episode without description accepted | PASS |
| EPI-04 | Episode number zero | Episode number of zero rejected | PASS |
| EPI-05 | Negative episode number | Negative episode number rejected | PASS |
| EPI-06 | Nonexistent season ID | Invalid season reference rejected | PASS |
| EPI-07 | Duplicate episode number within the same season | Duplicate episode rejected | PASS |
| EPI-08 | Same episode number in different seasons | Same episode number allowed in another season | PASS |
| EPI-09 | NULL season ID | NULL season ID rejected | PASS |
| EPI-10 | NULL episode number | NULL episode number rejected | PASS |
| EPI-11 | NULL episode name | NULL episode name rejected | PASS |
| EPI-12 | NULL duration | NULL duration rejected | PASS |

**Result:** 12/12 tests passed, 0 failures.

Date executed: 24 November 2026

All test data was removed using transaction rollback.

---

### Overall test results

The following tables have been tested so far:

| Table | Tests performed | Passed | Failed |
|---|---:|---:|---:|
| Accounts | 8 | 8 | 0 |
| Age Categories | 8 | 8 | 0 |
| Profiles | 11 | 11 | 0 |
| Titles | 10 | 10 | 0 |
| Films | 8 | 8 | 0 |
| Series | 4 | 4 | 0 |
| Seasons | 9 | 9 | 0 |
| Episodes | 12 | 12 | 0 |
| **Total** | **70** | **70** | **0** |

**Overall result: 70/70 tests passed.**

All currently completed schema tests have passed. Testing will continue as additional database components are implemented.

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