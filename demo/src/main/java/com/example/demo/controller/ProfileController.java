package com.example.demo.controller;

import com.example.demo.dto.ProfileRequest;
import com.example.demo.dto.ProfileResponse;
import com.example.demo.model.Profile;
import com.example.demo.service.ProfileService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.List;

/**
 * REST endpoints for the profiles that belong to an account.
 */
@RestController
@RequestMapping("/api/v1/accounts/{accountId}/profiles")
public class ProfileController {

    private final ProfileService profileService;

    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }

    @GetMapping
    public List<ProfileResponse> getProfiles(@PathVariable("accountId") long accountId) {
        return profileService.getProfiles(accountId).stream()
                .map(ProfileResponse::from)
                .toList();
    }

    @GetMapping("/{profileId}")
    public ProfileResponse getProfile(@PathVariable("accountId") long accountId,
                                      @PathVariable("profileId") long profileId) {
        return ProfileResponse.from(profileService.getProfile(accountId, profileId));
    }

    @PostMapping
    public ResponseEntity<ProfileResponse> createProfile(@PathVariable("accountId") long accountId,
                                                         @RequestBody ProfileRequest request) {
        Profile profile = profileService.createProfile(accountId, request);
        URI location = ServletUriComponentsBuilder.fromCurrentRequest()
                .path("/{profileId}")
                .buildAndExpand(profile.profileId())
                .toUri();
        return ResponseEntity.created(location).body(ProfileResponse.from(profile));
    }

    @PutMapping("/{profileId}")
    public ProfileResponse updateProfile(@PathVariable("accountId") long accountId,
                                         @PathVariable("profileId") long profileId,
                                         @RequestBody ProfileRequest request) {
        return ProfileResponse.from(profileService.updateProfile(accountId, profileId, request));
    }

    @DeleteMapping("/{profileId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteProfile(@PathVariable("accountId") long accountId,
                              @PathVariable("profileId") long profileId) {
        profileService.deleteProfile(accountId, profileId);
    }
}
