package com.example.demo.dto;

import com.example.demo.model.Profile;

/**
 * Response body for a profile. Keeps the API shape independent of the database model.
 */
public record ProfileResponse(
        long id,
        long accountId,
        String name,
        long ageCategoryId,
        String ageCategory,
        int minimumAge,
        String image
) {

    public static ProfileResponse from(Profile profile) {
        return new ProfileResponse(
                profile.profileId(),
                profile.accountId(),
                profile.profileName(),
                profile.ageCategoryId(),
                profile.ageCategoryName(),
                profile.minimumAge(),
                profile.profileImage()
        );
    }
}
