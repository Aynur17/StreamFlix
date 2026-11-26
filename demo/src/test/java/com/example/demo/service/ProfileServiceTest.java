package com.example.demo.service;

import com.example.demo.dto.ProfileRequest;
import com.example.demo.exception.ConflictException;
import com.example.demo.exception.InvalidInputException;
import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.model.Profile;
import com.example.demo.repository.ProfileRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.DuplicateKeyException;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ProfileServiceTest {

    private static final long ACCOUNT_ID = 1L;
    private static final long PROFILE_ID = 10L;
    private static final long AGE_CATEGORY_ID = 3L;

    @Mock
    private ProfileRepository profileRepository;

    @InjectMocks
    private ProfileService profileService;

    private static Profile profile(String name) {
        return new Profile(PROFILE_ID, ACCOUNT_ID, name, AGE_CATEGORY_ID, "9", 9, null);
    }

    // --- Reading ---

    @Test
    void getProfiles_unknownAccount_throwsNotFound() {
        when(profileRepository.accountExists(99L)).thenReturn(false);

        assertThatThrownBy(() -> profileService.getProfiles(99L))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessageContaining("Account 99");
    }

    @Test
    void getProfiles_existingAccount_returnsProfiles() {
        when(profileRepository.accountExists(ACCOUNT_ID)).thenReturn(true);
        when(profileRepository.findAllByAccountId(ACCOUNT_ID)).thenReturn(List.of(profile("Kids")));

        assertThat(profileService.getProfiles(ACCOUNT_ID))
                .extracting(Profile::profileName)
                .containsExactly("Kids");
    }

    @Test
    void getProfile_profileOfOtherAccount_throwsNotFound() {
        when(profileRepository.accountExists(ACCOUNT_ID)).thenReturn(true);
        when(profileRepository.findByIdAndAccountId(PROFILE_ID, ACCOUNT_ID)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> profileService.getProfile(ACCOUNT_ID, PROFILE_ID))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessageContaining("Profile 10");
    }

    // --- Creating ---

    @Test
    void createProfile_validRequest_trimsNameAndDropsBlankImage() {
        when(profileRepository.accountExists(ACCOUNT_ID)).thenReturn(true);
        when(profileRepository.ageCategoryExists(AGE_CATEGORY_ID)).thenReturn(true);
        when(profileRepository.isNameTaken(ACCOUNT_ID, "Kids", null)).thenReturn(false);
        when(profileRepository.create(ACCOUNT_ID, "Kids", AGE_CATEGORY_ID, null)).thenReturn(PROFILE_ID);
        when(profileRepository.findByIdAndAccountId(PROFILE_ID, ACCOUNT_ID)).thenReturn(Optional.of(profile("Kids")));

        Profile created = profileService.createProfile(ACCOUNT_ID,
                new ProfileRequest("  Kids  ", AGE_CATEGORY_ID, "   "));

        assertThat(created.profileId()).isEqualTo(PROFILE_ID);
        verify(profileRepository).create(ACCOUNT_ID, "Kids", AGE_CATEGORY_ID, null);
    }

    @Test
    void createProfile_missingFields_reportsAllErrors() {
        when(profileRepository.accountExists(ACCOUNT_ID)).thenReturn(true);

        assertThatThrownBy(() -> profileService.createProfile(ACCOUNT_ID, new ProfileRequest(" ", null, null)))
                .isInstanceOfSatisfying(InvalidInputException.class, exception ->
                        assertThat(exception.getFieldErrors()).containsOnlyKeys("profileName", "ageCategoryId"));
        verify(profileRepository, never()).create(anyLong(), anyString(), anyLong(), any());
    }

    @Test
    void createProfile_nullBody_throwsInvalidInput() {
        when(profileRepository.accountExists(ACCOUNT_ID)).thenReturn(true);

        assertThatThrownBy(() -> profileService.createProfile(ACCOUNT_ID, null))
                .isInstanceOf(InvalidInputException.class);
    }

    @Test
    void createProfile_nameTooLong_throwsInvalidInput() {
        when(profileRepository.accountExists(ACCOUNT_ID)).thenReturn(true);
        when(profileRepository.ageCategoryExists(AGE_CATEGORY_ID)).thenReturn(true);
        String longName = "a".repeat(ProfileService.MAX_NAME_LENGTH + 1);

        assertThatThrownBy(() -> profileService.createProfile(ACCOUNT_ID,
                new ProfileRequest(longName, AGE_CATEGORY_ID, null)))
                .isInstanceOfSatisfying(InvalidInputException.class, exception ->
                        assertThat(exception.getFieldErrors()).containsOnlyKeys("profileName"));
    }

    @Test
    void createProfile_imageTooLong_throwsInvalidInput() {
        when(profileRepository.accountExists(ACCOUNT_ID)).thenReturn(true);
        when(profileRepository.ageCategoryExists(AGE_CATEGORY_ID)).thenReturn(true);
        String longImage = "x".repeat(ProfileService.MAX_IMAGE_LENGTH + 1);

        assertThatThrownBy(() -> profileService.createProfile(ACCOUNT_ID,
                new ProfileRequest("Kids", AGE_CATEGORY_ID, longImage)))
                .isInstanceOfSatisfying(InvalidInputException.class, exception ->
                        assertThat(exception.getFieldErrors()).containsOnlyKeys("profileImage"));
    }

    @Test
    void createProfile_unknownAgeCategory_throwsInvalidInput() {
        when(profileRepository.accountExists(ACCOUNT_ID)).thenReturn(true);
        when(profileRepository.ageCategoryExists(99L)).thenReturn(false);

        assertThatThrownBy(() -> profileService.createProfile(ACCOUNT_ID, new ProfileRequest("Kids", 99L, null)))
                .isInstanceOfSatisfying(InvalidInputException.class, exception ->
                        assertThat(exception.getFieldErrors()).containsOnlyKeys("ageCategoryId"));
    }

    @Test
    void createProfile_negativeAgeCategory_isRejectedWithoutDatabaseLookup() {
        when(profileRepository.accountExists(ACCOUNT_ID)).thenReturn(true);

        assertThatThrownBy(() -> profileService.createProfile(ACCOUNT_ID, new ProfileRequest("Kids", -1L, null)))
                .isInstanceOf(InvalidInputException.class);
        verify(profileRepository, never()).ageCategoryExists(anyLong());
    }

    @Test
    void createProfile_duplicateName_throwsConflict() {
        when(profileRepository.accountExists(ACCOUNT_ID)).thenReturn(true);
        when(profileRepository.ageCategoryExists(AGE_CATEGORY_ID)).thenReturn(true);
        when(profileRepository.isNameTaken(ACCOUNT_ID, "Kids", null)).thenReturn(true);

        assertThatThrownBy(() -> profileService.createProfile(ACCOUNT_ID,
                new ProfileRequest("Kids", AGE_CATEGORY_ID, null)))
                .isInstanceOf(ConflictException.class);
    }

    @Test
    void createProfile_duplicateKeyFromDatabase_throwsConflict() {
        when(profileRepository.accountExists(ACCOUNT_ID)).thenReturn(true);
        when(profileRepository.ageCategoryExists(AGE_CATEGORY_ID)).thenReturn(true);
        when(profileRepository.isNameTaken(ACCOUNT_ID, "Kids", null)).thenReturn(false);
        when(profileRepository.create(ACCOUNT_ID, "Kids", AGE_CATEGORY_ID, null))
                .thenThrow(new DuplicateKeyException("profiles_account_name_unique"));

        assertThatThrownBy(() -> profileService.createProfile(ACCOUNT_ID,
                new ProfileRequest("Kids", AGE_CATEGORY_ID, null)))
                .isInstanceOf(ConflictException.class);
    }

    // --- Updating ---

    @Test
    void updateProfile_validRequest_returnsUpdatedProfile() {
        when(profileRepository.accountExists(ACCOUNT_ID)).thenReturn(true);
        when(profileRepository.findByIdAndAccountId(PROFILE_ID, ACCOUNT_ID))
                .thenReturn(Optional.of(profile("Kids")), Optional.of(profile("Teens")));
        when(profileRepository.ageCategoryExists(AGE_CATEGORY_ID)).thenReturn(true);
        when(profileRepository.isNameTaken(ACCOUNT_ID, "Teens", PROFILE_ID)).thenReturn(false);
        when(profileRepository.update(PROFILE_ID, ACCOUNT_ID, "Teens", AGE_CATEGORY_ID, null)).thenReturn(true);

        Profile updated = profileService.updateProfile(ACCOUNT_ID, PROFILE_ID,
                new ProfileRequest("Teens", AGE_CATEGORY_ID, null));

        assertThat(updated.profileName()).isEqualTo("Teens");
    }

    @Test
    void updateProfile_unknownProfile_throwsNotFound() {
        when(profileRepository.accountExists(ACCOUNT_ID)).thenReturn(true);
        when(profileRepository.findByIdAndAccountId(PROFILE_ID, ACCOUNT_ID)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> profileService.updateProfile(ACCOUNT_ID, PROFILE_ID,
                new ProfileRequest("Teens", AGE_CATEGORY_ID, null)))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void updateProfile_nameUsedByOtherProfile_throwsConflict() {
        when(profileRepository.accountExists(ACCOUNT_ID)).thenReturn(true);
        when(profileRepository.findByIdAndAccountId(PROFILE_ID, ACCOUNT_ID)).thenReturn(Optional.of(profile("Kids")));
        when(profileRepository.ageCategoryExists(AGE_CATEGORY_ID)).thenReturn(true);
        when(profileRepository.isNameTaken(ACCOUNT_ID, "Dad", PROFILE_ID)).thenReturn(true);

        assertThatThrownBy(() -> profileService.updateProfile(ACCOUNT_ID, PROFILE_ID,
                new ProfileRequest("Dad", AGE_CATEGORY_ID, null)))
                .isInstanceOf(ConflictException.class);
    }

    @Test
    void updateProfile_profileDeletedDuringUpdate_throwsNotFound() {
        when(profileRepository.accountExists(ACCOUNT_ID)).thenReturn(true);
        when(profileRepository.findByIdAndAccountId(PROFILE_ID, ACCOUNT_ID)).thenReturn(Optional.of(profile("Kids")));
        when(profileRepository.ageCategoryExists(AGE_CATEGORY_ID)).thenReturn(true);
        when(profileRepository.isNameTaken(ACCOUNT_ID, "Kids", PROFILE_ID)).thenReturn(false);
        when(profileRepository.update(PROFILE_ID, ACCOUNT_ID, "Kids", AGE_CATEGORY_ID, null)).thenReturn(false);

        assertThatThrownBy(() -> profileService.updateProfile(ACCOUNT_ID, PROFILE_ID,
                new ProfileRequest("Kids", AGE_CATEGORY_ID, null)))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    // --- Deleting ---

    @Test
    void deleteProfile_existingProfile_deletesIt() {
        when(profileRepository.accountExists(ACCOUNT_ID)).thenReturn(true);
        when(profileRepository.delete(PROFILE_ID, ACCOUNT_ID)).thenReturn(true);

        profileService.deleteProfile(ACCOUNT_ID, PROFILE_ID);

        verify(profileRepository).delete(PROFILE_ID, ACCOUNT_ID);
    }

    @Test
    void deleteProfile_unknownProfile_throwsNotFound() {
        when(profileRepository.accountExists(ACCOUNT_ID)).thenReturn(true);
        when(profileRepository.delete(PROFILE_ID, ACCOUNT_ID)).thenReturn(false);

        assertThatThrownBy(() -> profileService.deleteProfile(ACCOUNT_ID, PROFILE_ID))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void deleteProfile_stillReferenced_throwsConflict() {
        when(profileRepository.accountExists(ACCOUNT_ID)).thenReturn(true);
        when(profileRepository.delete(PROFILE_ID, ACCOUNT_ID))
                .thenThrow(new DataIntegrityViolationException("foreign key"));

        assertThatThrownBy(() -> profileService.deleteProfile(ACCOUNT_ID, PROFILE_ID))
                .isInstanceOf(ConflictException.class);
    }
}
