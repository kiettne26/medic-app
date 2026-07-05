package com.medibook.user.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationClient {

    private final RestTemplateBuilder restTemplateBuilder;

    @Value("${services.notification-service.url:http://localhost:8084}")
    private String notificationServiceUrl;

    public boolean sendEmailVerificationCode(String email, String code, int expiresInMinutes) {
        Map<String, Object> request = new HashMap<>();
        request.put("to", email);
        request.put("code", code);
        request.put("expiresInMinutes", expiresInMinutes);

        try {
            restTemplateBuilder
                    .build()
                    .postForEntity(notificationServiceUrl + "/notifications/internal/email-verification",
                            request,
                            Void.class);
            log.info("Requested email verification code for {}", email);
            return true;
        } catch (RestClientException e) {
            log.warn("Could not request email verification code for {}: {}", email, e.getMessage());
            return false;
        }
    }
}
