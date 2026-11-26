package com.example.demo.model;

/**
 * A viewing profile within an account (e.g. one per family member).
 * Includes the age category details so the API never has to look them up separately.
 */
public record Profile(
        long profileId,
        long accountId,
        String profileName,
        long ageCategoryId,
        String ageCategoryName,
        int minimumAge,
        String profileImage
) {
}
