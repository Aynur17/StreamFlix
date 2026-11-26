package com.example.demo.service;

import com.example.demo.dto.ProfileRequest;
import com.example.demo.exception.ConflictException;
import com.example.demo.exception.InvalidInputException;
import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.model.Profile;
import com.example.demo.repository.ProfileRepository;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Business logic for profiles: validation, ownership checks and duplicate-name rules.
 */
@Service
public class ProfileService {

    static final int MAX_NAME_LENGTH = 100;
    static final int MAX_IMAGE_LENGTH = 2048;

    private final ProfileRepository profileRepository;

    public ProfileService(ProfileRepository profileRepository) {
        this.profileRepository = profileRepository;
    }

    public List<Profile> getProfiles(long accountId) {
        requireAccount(accountId);
        return profileRepository.findAllByAccountId(accountId);
    }

    public Profile getProfile(long accountId, long profileId) {
        requireAccount(accountId);
        return findProfile(accountId, profileId);
    }

    public Profile createProfile(long accountId, ProfileRequest request) {
        requireAccount(accountId);
        ValidProfileData data = validate(request);
        requireNameAvailable(accountId, data.name(), null);

        long profileId;
        try {
            profileId = profileRepository.create(accountId, data.name(), data.ageCategoryId(), data.image());
        } catch (DuplicateKeyException exception) {
            // Another request created the same name between our check and the insert.
            throw duplicateName(data.name());
        }
        return findProfile(accountId, profileId);
    }

    public Profile updateProfile(long accountId, long profileId, ProfileRequest request) {
        requireAccount(accountId);
        findProfile(accountId, profileId);
        ValidProfileData data = validate(request);
        requireNameAvailable(accountId, data.name(), profileId);

        boolean updated;
        try {
            updated = profileRepository.update(profileId, accountId, data.name(), data.ageCategoryId(), data.image());
        } catch (DuplicateKeyException exception) {
            throw duplicateName(data.name());
        }
        if (!updated) {
            throw profileNotFound(accountId, profileId);
        }
        return findProfile(accountId, profileId);
    }

    public void deleteProfile(long accountId, long profileId) {
        requireAccount(accountId);
        boolean deleted;
        try {
            deleted = profileRepository.delete(profileId, accountId);
        } catch (DataIntegrityViolationException exception) {
            throw new ConflictException("Profile " + profileId
                    + " cannot be deleted because other data still refers to it.");
        }
        if (!deleted) {
            throw profileNotFound(accountId, profileId);
        }
    }

    private void requireAccount(long accountId) {
        if (!profileRepository.accountExists(accountId)) {
            throw new ResourceNotFoundException("Account " + accountId + " does not exist.");
        }
    }

    private Profile findProfile(long accountId, long profileId) {
        return profileRepository.findByIdAndAccountId(profileId, accountId)
                .orElseThrow(() -> profileNotFound(accountId, profileId));
    }

    private void requireNameAvailable(long accountId, String name, Long excludeProfileId) {
        if (profileRepository.isNameTaken(accountId, name, excludeProfileId)) {
            throw duplicateName(name);
        }
    }

    /**
     * Checks every field and reports all problems together instead of stopping at the first one.
     */
    private ValidProfileData validate(ProfileRequest request) {
        if (request == null) {
            throw new InvalidInputException(Map.of("body", "A request body is required."));
        }
        Map<String, String> errors = new LinkedHashMap<>();

        String name = request.profileName() == null ? "" : request.profileName().trim();
        if (name.isEmpty()) {
            errors.put("profileName", "Profile name is required.");
        } else if (name.length() > MAX_NAME_LENGTH) {
            errors.put("profileName", "Profile name can be at most " + MAX_NAME_LENGTH + " characters.");
        }

        Long ageCategoryId = request.ageCategoryId();
        if (ageCategoryId == null) {
            errors.put("ageCategoryId", "Age category is required.");
        } else if (ageCategoryId <= 0 || !profileRepository.ageCategoryExists(ageCategoryId)) {
            errors.put("ageCategoryId", "Age category " + ageCategoryId + " does not exist.");
        }

        String image = request.profileImage() == null || request.profileImage().isBlank()
                ? null
                : request.profileImage().trim();
        if (image != null && image.length() > MAX_IMAGE_LENGTH) {
            errors.put("profileImage", "Profile image can be at most " + MAX_IMAGE_LENGTH + " characters.");
        }

        if (!errors.isEmpty()) {
            throw new InvalidInputException(errors);
        }
        return new ValidProfileData(name, ageCategoryId, image);
    }

    private ResourceNotFoundException profileNotFound(long accountId, long profileId) {
        return new ResourceNotFoundException(
                "Profile " + profileId + " does not exist in account " + accountId + ".");
    }

    private ConflictException duplicateName(String name) {
        return new ConflictException("This account already has a profile named '" + name + "'.");
    }

    private record ValidProfileData(String name, long ageCategoryId, String image) {
    }
}
