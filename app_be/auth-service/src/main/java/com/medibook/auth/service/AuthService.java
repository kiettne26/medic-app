package com.medibook.auth.service;

import com.medibook.auth.dto.*;
import com.medibook.auth.entity.RefreshToken;
import com.medibook.auth.entity.User;
import com.medibook.auth.repository.RefreshTokenRepository;
import com.medibook.auth.repository.UserRepository;
import com.medibook.auth.security.JwtTokenProvider;
import com.medibook.common.exception.BadRequestException;
import com.medibook.common.exception.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.util.UriComponentsBuilder;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * Authentication Service - Xử lý đăng ký, đăng nhập, refresh token
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;
    private final AuthenticationManager authenticationManager;
    private final RestTemplate restTemplate; // Injected with @LoadBalanced from RestTemplateConfig
    private final RestTemplate externalRestTemplate = new RestTemplate();

    /**
     * Social Login
     */
    @Transactional
    public AuthResponse socialLogin(SocialLoginRequest request) {
        log.info("Social Login request: email={}, provider={}", request.getEmail(), request.getProvider());
        SocialUserInfo socialUser = verifySocialLogin(request);

        return userRepository.findByEmail(socialUser.email())
                .map(user -> {
                    if (!user.getEnabled()) {
                        throw new UnauthorizedException("Tài khoản đã bị vô hiệu hóa");
                    }
                    // Cập nhật fullName và avatarUrl từ provider nếu user chưa có
                    boolean updated = false;
                    if (socialUser.name() != null && (user.getFullName() == null || user.getFullName().isBlank())) {
                        user.setFullName(socialUser.name());
                        updated = true;
                    }
                    if (socialUser.avatar() != null && !socialUser.avatar().isBlank()) {
                        user.setAvatarUrl(socialUser.avatar());
                        updated = true;
                    }
                    if (updated) {
                        userRepository.save(user);
                        log.info("Updated social user info: {}", user.getEmail());
                    }
                    return generateAuthResponse(user);
                })
                .orElseGet(() -> {
                    // Register new social user
                    User newUser = User.builder()
                            .email(socialUser.email())
                            .fullName(socialUser.name())
                            .passwordHash(passwordEncoder.encode(UUID.randomUUID().toString()))
                            .role("PATIENT")
                            .enabled(true)
                            .emailVerified(false)
                            .avatarUrl(socialUser.avatar())
                            .build();

                    User savedUser = userRepository.save(newUser);
                    log.info("Registered new user from social login: {}", savedUser.getEmail());
                    return generateAuthResponse(savedUser);
                });
    }

    private SocialUserInfo verifySocialLogin(SocialLoginRequest request) {
        if ("FACEBOOK".equalsIgnoreCase(request.getProvider())) {
            return verifyFacebookToken(request);
        }

        if (!hasText(request.getEmail())) {
            throw new BadRequestException("Email social login khong hop le");
        }
        return new SocialUserInfo(request.getEmail().trim(), request.getName(), request.getAvatar());
    }

    private SocialUserInfo verifyFacebookToken(SocialLoginRequest request) {
        if (!hasText(request.getToken())) {
            throw new UnauthorizedException("Facebook access token khong hop le");
        }

        String graphUrl = UriComponentsBuilder
                .fromHttpUrl("https://graph.facebook.com/me")
                .queryParam("fields", "id,name,email,picture.width(200).height(200)")
                .queryParam("access_token", request.getToken())
                .toUriString();

        @SuppressWarnings("unchecked")
        Map<String, Object> profile = externalRestTemplate.getForObject(graphUrl, Map.class);
        if (profile == null || !hasText(asString(profile.get("id")))) {
            throw new UnauthorizedException("Khong the xac thuc Facebook access token");
        }

        String email = asString(profile.get("email"));
        if (!hasText(email)) {
            email = request.getEmail();
        }
        if (!hasText(email)) {
            throw new BadRequestException("Facebook khong cung cap email cho tai khoan nay");
        }

        String name = firstNonBlank(asString(profile.get("name")), request.getName(), "Facebook User");
        String avatar = firstNonBlank(extractFacebookAvatar(profile), request.getAvatar(), "");

        return new SocialUserInfo(email.trim(), name, avatar);
    }

    @SuppressWarnings("unchecked")
    private String extractFacebookAvatar(Map<String, Object> profile) {
        Object picture = profile.get("picture");
        if (!(picture instanceof Map<?, ?> pictureMap)) {
            return null;
        }
        Object data = ((Map<String, Object>) pictureMap).get("data");
        if (!(data instanceof Map<?, ?> dataMap)) {
            return null;
        }
        return asString(((Map<String, Object>) dataMap).get("url"));
    }

    private boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }

    private String asString(Object value) {
        return value != null ? value.toString() : null;
    }

    private String firstNonBlank(String... values) {
        for (String value : values) {
            if (hasText(value)) {
                return value;
            }
        }
        return null;
    }

    private record SocialUserInfo(String email, String name, String avatar) {
    }

    /**
     * Đăng ký tài khoản mới
     */
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        // Check email đã tồn tại chưa
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email đã được sử dụng");
        }

        // Tạo user mới
        User user = User.builder()
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .fullName(request.getFullName())
                .phone(request.getPhone())
                .role("PATIENT")
                .enabled(true)
                .emailVerified(false)
                .build();

        user = userRepository.save(user);
        log.info("User registered successfully: {}", user.getEmail());

        return generateAuthResponse(user);
    }

    /**
     * Đăng nhập
     */
    @Transactional
    public AuthResponse login(LoginRequest request) {
        log.info("Login attempt: {}", request.getEmail());

        // Authenticate using Spring Security
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()));

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new UnauthorizedException("Email hoặc mật khẩu không đúng"));

        // Revoke old tokens
        refreshTokenRepository.revokeAllByUser(user);

        log.info("User logged in successfully: {}", user.getEmail());
        return generateAuthResponse(user);
    }

    /**
     * Đăng xuất
     */
    @Transactional
    public void logout(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UnauthorizedException("User không tồn tại"));

        refreshTokenRepository.revokeAllByUser(user);
        log.info("User logged out: {}", email);
    }

    /**
     * Generate auth response với access + refresh tokens
     */
    private AuthResponse generateAuthResponse(User user) {
        // Generate access token (Role is String now)
        String accessToken = tokenProvider.generateAccessToken(
                user.getId(),
                user.getEmail(),
                user.getRole());

        // Generate và lưu refresh token
        String refreshTokenValue = tokenProvider.generateRefreshToken();
        RefreshToken refreshToken = RefreshToken.builder()
                .token(refreshTokenValue)
                .user(user)
                .expiresAt(Instant.now().plusMillis(tokenProvider.getRefreshTokenExpiration()))
                .revoked(false)
                .build();
        refreshTokenRepository.save(refreshToken);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshTokenValue)
                .tokenType("Bearer")
                .expiresIn(tokenProvider.getAccessTokenExpiration() / 1000) // Convert to seconds
                .user(AuthResponse.UserInfo.builder()
                        .id(user.getId())
                        .email(user.getEmail())
                        .fullName(user.getFullName())
                        .phone(user.getPhone())
                        .avatarUrl(user.getAvatarUrl())
                        .role(user.getRole())
                        .build())
                .build();
    }

    /**
     * Refresh Token
     */
    @Transactional
    public AuthResponse refreshToken(RefreshTokenRequest request) {
        String requestRefreshToken = request.getRefreshToken();

        return refreshTokenRepository.findByToken(requestRefreshToken)
                .map(this::verifyExpiration)
                .map(RefreshToken::getUser)
                .map(user -> {
                    String accessToken = tokenProvider.generateAccessToken(
                            user.getId(),
                            user.getEmail(),
                            user.getRole());

                    return AuthResponse.builder()
                            .accessToken(accessToken)
                            .refreshToken(requestRefreshToken)
                            .tokenType("Bearer")
                            .expiresIn(tokenProvider.getAccessTokenExpiration() / 1000)
                            .user(AuthResponse.UserInfo.builder()
                                    .id(user.getId())
                                    .email(user.getEmail())
                                    .fullName(user.getFullName())
                                    .phone(user.getPhone())
                                    .avatarUrl(user.getAvatarUrl())
                                    .role(user.getRole())
                                    .build())
                            .build();
                })
                .orElseThrow(() -> new UnauthorizedException("Refresh token không tồn tại"));
    }

    private RefreshToken verifyExpiration(RefreshToken token) {
        if (token.getExpiresAt().compareTo(Instant.now()) < 0) {
            refreshTokenRepository.delete(token);
            throw new UnauthorizedException("Refresh token đã hết hạn");
        }
        return token;
    }

    /**
     * Đổi mật khẩu
     */
    @Transactional
    public void changePassword(UUID userId, ChangePasswordRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UnauthorizedException("User không tồn tại"));

        // Verify old password
        if (!passwordEncoder.matches(request.getOldPassword(), user.getPasswordHash())) {
            throw new BadRequestException("Mật khẩu cũ không chính xác");
        }

        // Validate new password (simple check, validation annotations handle mostly)
        if (request.getNewPassword().equals(request.getOldPassword())) {
            throw new BadRequestException("Mật khẩu mới không được trùng với mật khẩu cũ");
        }

        // Update password
        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user); // Save explicitly although Transactional handles it
        log.info("Password changed for user: {}", user.getEmail());
    }

    /**
     * ADMIN: Tạo tài khoản bác sĩ (User + Doctor profile)
     * Flow:
     * 1. Tạo User với role DOCTOR
     * 2. Gọi User Service để tạo Doctor profile
     */
    @Transactional
    public CreateDoctorAccountResponse createDoctorAccount(CreateDoctorAccountRequest request) {
        // Check email đã tồn tại chưa
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email đã được sử dụng");
        }

        // 1. Tạo User với role DOCTOR
        User user = User.builder()
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .fullName(request.getFullName())
                .phone(request.getPhone())
                .avatarUrl(request.getAvatarUrl())
                .role("DOCTOR")
                .enabled(true)
                .emailVerified(true)
                .build();

        user = userRepository.save(user);
        log.info("Doctor user created: {}", user.getEmail());

        // 2. Gọi User Service để tạo Doctor profile
        UUID doctorId = createDoctorProfile(user.getId(), request);

        return CreateDoctorAccountResponse.builder()
                .userId(user.getId())
                .doctorId(doctorId)
                .email(user.getEmail())
                .fullName(user.getFullName())
                .specialty(request.getSpecialty())
                .message("Tạo tài khoản bác sĩ thành công")
                .build();
    }

    /**
     * Gọi User Service để tạo Doctor profile
     * Sử dụng service discovery qua Eureka với @LoadBalanced RestTemplate
     */
    private UUID createDoctorProfile(UUID userId, CreateDoctorAccountRequest request) {
        try {
            // Tạo request body cho User Service
            Map<String, Object> doctorRequest = new HashMap<>();
            doctorRequest.put("userId", userId.toString());
            doctorRequest.put("fullName", request.getFullName());
            doctorRequest.put("specialty", request.getSpecialty());
            doctorRequest.put("description", request.getDescription());
            doctorRequest.put("phone", request.getPhone());
            doctorRequest.put("avatarUrl", request.getAvatarUrl());
            doctorRequest.put("isAvailable", request.getIsAvailable() != null ? request.getIsAvailable() : true);
            doctorRequest.put("serviceIds", request.getServiceIds());

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(doctorRequest, headers);

            // Gọi User Service qua Eureka service discovery
            // "user-service" là spring.application.name trong user-service/application.yml
            String userServiceUrl = "http://user-service/doctors";
            log.info("Calling User Service to create doctor profile: {}", userServiceUrl);
            
            @SuppressWarnings("unchecked")
            Map<String, Object> response = restTemplate.postForObject(userServiceUrl, entity, Map.class);
            
            if (response != null && response.get("data") != null) {
                @SuppressWarnings("unchecked")
                Map<String, Object> data = (Map<String, Object>) response.get("data");
                UUID doctorId = UUID.fromString((String) data.get("id"));
                log.info("Doctor profile created successfully with ID: {}", doctorId);
                return doctorId;
            }
            
            log.warn("Could not get doctor ID from response");
            return null;
        } catch (Exception e) {
            log.error("Failed to create doctor profile: {}", e.getMessage());
            // Không throw exception, chỉ log warning vì User đã được tạo
            // Admin có thể tạo Doctor profile sau
            return null;
        }
    }
}
