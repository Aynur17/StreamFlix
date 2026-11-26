package com.example.demo.controller;

import com.example.demo.dto.ProfileRequest;
import com.example.demo.exception.ConflictException;
import com.example.demo.exception.InvalidInputException;
import com.example.demo.exception.ResourceNotFoundException;
import com.example.demo.model.Profile;
import com.example.demo.service.ProfileService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.Map;

import static org.hamcrest.Matchers.endsWith;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.doThrow;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(ProfileController.class)
class ProfileControllerTest {

    private static final String PROFILES_URL = "/api/v1/accounts/1/profiles";
    private static final Profile KIDS = new Profile(10L, 1L, "Kids", 3L, "9", 9, null);

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private ProfileService profileService;

    @Test
    void getProfiles_returnsList() throws Exception {
        when(profileService.getProfiles(1L)).thenReturn(List.of(KIDS));

        mockMvc.perform(get(PROFILES_URL))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(10))
                .andExpect(jsonPath("$[0].name").value("Kids"))
                .andExpect(jsonPath("$[0].ageCategory").value("9"));
    }

    @Test
    void getProfile_unknownProfile_returns404WithProblemDetail() throws Exception {
        when(profileService.getProfile(1L, 99L))
                .thenThrow(new ResourceNotFoundException("Profile 99 does not exist in account 1."));

        mockMvc.perform(get(PROFILES_URL + "/99"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404))
                .andExpect(jsonPath("$.detail").value("Profile 99 does not exist in account 1."));
    }

    @Test
    void getProfiles_nonNumericAccountId_returns400() throws Exception {
        mockMvc.perform(get("/api/v1/accounts/abc/profiles"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.title").value("Invalid parameter"));
        verifyNoInteractions(profileService);
    }

    @Test
    void createProfile_validBody_returns201WithLocation() throws Exception {
        when(profileService.createProfile(eq(1L), any(ProfileRequest.class))).thenReturn(KIDS);

        mockMvc.perform(post(PROFILES_URL)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"profileName": "Kids", "ageCategoryId": 3}
                                """))
                .andExpect(status().isCreated())
                .andExpect(header().string("Location", endsWith("/api/v1/accounts/1/profiles/10")))
                .andExpect(jsonPath("$.name").value("Kids"));
    }

    @Test
    void createProfile_invalidBody_returns400WithFieldErrors() throws Exception {
        when(profileService.createProfile(eq(1L), any(ProfileRequest.class)))
                .thenThrow(new InvalidInputException(Map.of("profileName", "Profile name is required.")));

        mockMvc.perform(post(PROFILES_URL)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"profileName": "", "ageCategoryId": 3}
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors.profileName").value("Profile name is required."));
    }

    @Test
    void createProfile_malformedJson_returns400() throws Exception {
        mockMvc.perform(post(PROFILES_URL)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{ not json"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.title").value("Malformed request"));
        verifyNoInteractions(profileService);
    }

    @Test
    void updateProfile_duplicateName_returns409() throws Exception {
        when(profileService.updateProfile(eq(1L), eq(10L), any(ProfileRequest.class)))
                .thenThrow(new ConflictException("This account already has a profile named 'Dad'."));

        mockMvc.perform(put(PROFILES_URL + "/10")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"profileName": "Dad", "ageCategoryId": 3}
                                """))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status").value(409));
    }

    @Test
    void deleteProfile_returns204() throws Exception {
        mockMvc.perform(delete(PROFILES_URL + "/10"))
                .andExpect(status().isNoContent());
        verify(profileService).deleteProfile(1L, 10L);
    }

    @Test
    void deleteProfile_unknownProfile_returns404() throws Exception {
        doThrow(new ResourceNotFoundException("Profile 99 does not exist in account 1."))
                .when(profileService).deleteProfile(1L, 99L);

        mockMvc.perform(delete(PROFILES_URL + "/99"))
                .andExpect(status().isNotFound());
    }
}
