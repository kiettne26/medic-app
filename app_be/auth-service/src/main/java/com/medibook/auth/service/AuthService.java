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
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
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

    /**
     * Social Login
     */
    @Transactional
    public AuthResponse socialLogin(SocialLoginRequest request) {
        log.info("Social Login request: email={}, provider={}", request.getEmail(), request.getProvider());

        return userRepository.findByEmail(request.getEmail())
                .map(user -> {
                    // Update user info if needed
                    if (!user.getEnabled()) {
                        throw new UnauthorizedException("Tài khoản đã bị vô hiệu hóa");
                    }
                    return generateAuthResponse(user);
                })
                .orElseGet(() -> {
                    // Register new social user
                    User newUser = User.builder()
                            .email(request.getEmail())
                            .fullName(request.getName())
                            .passwordHash(passwordEncoder.encode(UUID.randomUUID().toString()))
                            .role("PATIENT") // Default
                            .enabled(true)
                            .avatarUrl(request.getAvatar())
                            .build();

                    User savedUser = userRepository.save(newUser);
                    log.info("Registered new user from social login: {}", savedUser.getEmail());
                    return generateAuthResponse(savedUser);
                });
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
                .role("PATIENT") // Default
                .enabled(true)
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
}
