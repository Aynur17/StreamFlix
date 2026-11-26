package com.example.demo.dto;

/**
 * Request body for creating or replacing a profile.
 * Validation happens in ProfileService so every rule lives in one place.
 */
public record ProfileRequest(
        String profileName,
        Long ageCategoryId,
        String profileImage
) {
}
