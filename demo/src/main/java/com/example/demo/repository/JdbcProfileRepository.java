package com.example.demo.repository;

import com.example.demo.model.Profile;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * JDBC implementation of ProfileRepository using Spring's JdbcTemplate.
 */
@Repository
public class JdbcProfileRepository implements ProfileRepository {

    private static final String SELECT_PROFILE = """
            SELECT p.profile_id, p.account_id, p.profile_name, p.age_category_id, p.profile_image,
                   ac.category_name, ac.minimum_age
            FROM profiles p
            JOIN age_categories ac ON ac.age_category_id = p.age_category_id
            """;

    private static final RowMapper<Profile> PROFILE_ROW_MAPPER = (resultSet, rowNumber) -> new Profile(
            resultSet.getLong("profile_id"),
            resultSet.getLong("account_id"),
            resultSet.getString("profile_name"),
            resultSet.getLong("age_category_id"),
            resultSet.getString("category_name"),
            resultSet.getInt("minimum_age"),
            resultSet.getString("profile_image")
    );

    private final JdbcTemplate jdbcTemplate;

    public JdbcProfileRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public List<Profile> findAllByAccountId(long accountId) {
        return jdbcTemplate.query(
                SELECT_PROFILE + "WHERE p.account_id = ? ORDER BY p.profile_id",
                PROFILE_ROW_MAPPER,
                accountId);
    }

    @Override
    public Optional<Profile> findByIdAndAccountId(long profileId, long accountId) {
        List<Profile> profiles = jdbcTemplate.query(
                SELECT_PROFILE + "WHERE p.profile_id = ? AND p.account_id = ?",
                PROFILE_ROW_MAPPER,
                profileId, accountId);
        return profiles.stream().findFirst();
    }

    @Override
    public long create(long accountId, String profileName, long ageCategoryId, String profileImage) {
        Long id = jdbcTemplate.queryForObject("""
                        INSERT INTO profiles (account_id, profile_name, age_category_id, profile_image)
                        VALUES (?, ?, ?, ?)
                        RETURNING profile_id
                        """,
                Long.class,
                accountId, profileName, ageCategoryId, profileImage);
        if (id == null) {
            throw new IllegalStateException("The database did not return a profile id.");
        }
        return id;
    }

    @Override
    public boolean update(long profileId, long accountId, String profileName, long ageCategoryId,
                          String profileImage) {
        int rows = jdbcTemplate.update("""
                        UPDATE profiles
                        SET profile_name = ?, age_category_id = ?, profile_image = ?
                        WHERE profile_id = ? AND account_id = ?
                        """,
                profileName, ageCategoryId, profileImage, profileId, accountId);
        return rows > 0;
    }

    @Override
    public boolean delete(long profileId, long accountId) {
        int rows = jdbcTemplate.update(
                "DELETE FROM profiles WHERE profile_id = ? AND account_id = ?",
                profileId, accountId);
        return rows > 0;
    }

    @Override
    public boolean accountExists(long accountId) {
        return exists("SELECT EXISTS (SELECT 1 FROM accounts WHERE account_id = ?)", accountId);
    }

    @Override
    public boolean ageCategoryExists(long ageCategoryId) {
        return exists("SELECT EXISTS (SELECT 1 FROM age_categories WHERE age_category_id = ?)", ageCategoryId);
    }

    @Override
    public boolean isNameTaken(long accountId, String profileName, Long excludeProfileId) {
        // Identity ids start at 1, so 0 never matches a real profile.
        long excludedId = excludeProfileId == null ? 0L : excludeProfileId;
        return exists("""
                        SELECT EXISTS (
                            SELECT 1 FROM profiles
                            WHERE account_id = ? AND LOWER(profile_name) = LOWER(?) AND profile_id <> ?
                        )
                        """,
                accountId, profileName, excludedId);
    }

    private boolean exists(String sql, Object... arguments) {
        Boolean result = jdbcTemplate.queryForObject(sql, Boolean.class, arguments);
        return Boolean.TRUE.equals(result);
    }
}
