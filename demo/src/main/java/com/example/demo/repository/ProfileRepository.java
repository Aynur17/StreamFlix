package com.example.demo.repository;

import com.example.demo.model.Profile;

import java.util.List;
import java.util.Optional;

/**
 * Data access for profiles.
 * Kept as an interface so the JDBC implementation can later be switched to views and
 * stored procedures (required for the API_user_account) without touching the service.
 */
public interface ProfileRepository {

    List<Profile> findAllByAccountId(long accountId);

    Optional<Profile> findByIdAndAccountId(long profileId, long accountId);

    /**
     * @return the generated profile id
     */
    long create(long accountId, String profileName, long ageCategoryId, String profileImage);

    /**
     * @return true if a profile was updated, false if it did not exist in this account
     */
    boolean update(long profileId, long accountId, String profileName, long ageCategoryId, String profileImage);

    /**
     * @return true if a profile was deleted, false if it did not exist in this account
     */
    boolean delete(long profileId, long accountId);

    boolean accountExists(long accountId);

    boolean ageCategoryExists(long ageCategoryId);

    /**
     * Checks case-insensitively whether another profile in the account already uses this name.
     *
     * @param excludeProfileId profile to ignore (the one being updated), or null when creating
     */
    boolean isNameTaken(long accountId, String profileName, Long excludeProfileId);
}
