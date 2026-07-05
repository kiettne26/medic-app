package com.medibook.booking.service;

import com.medibook.booking.dto.BookingCreatedEmailRequest;
import com.medibook.booking.dto.BookingStatusNotificationRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.reactive.function.client.WebClient;

import java.time.Duration;

@Slf4j
@Service
public class NotificationClient {

    private final WebClient webClient;
    private final String notificationServiceUrl;

    public NotificationClient(
            @Value("${services.notification-service.url:http://localhost:8084}") String notificationServiceUrl) {
        this.notificationServiceUrl = notificationServiceUrl;
        this.webClient = WebClient.builder().baseUrl(notificationServiceUrl).build();
    }

    public void sendBookingCreatedEmail(BookingCreatedEmailRequest request) {
        if (request == null || !StringUtils.hasText(request.getPatientEmail())) {
            log.warn("Skip notification-service call because patient email is missing");
            return;
        }

        try {
            webClient
                    .post()
                    .uri("/notifications/internal/booking-created")
                    .bodyValue(request)
                    .retrieve()
                    .toBodilessEntity()
                    .block(Duration.ofSeconds(30));

            log.info("Requested booking confirmation email for booking {}", request.getBookingId());
        } catch (Exception e) {
            log.warn("Could not request booking confirmation email for booking {}: {}",
                    request.getBookingId(), e.getMessage());
        }
    }

    public void sendBookingConfirmedNotification(BookingStatusNotificationRequest request) {
        sendBookingStatusNotification(request, "/notifications/internal/booking-confirmed", "confirmed");
    }

    public void sendBookingCancelledNotification(BookingStatusNotificationRequest request) {
        sendBookingStatusNotification(request, "/notifications/internal/booking-cancelled", "cancelled");
    }

    private void sendBookingStatusNotification(
            BookingStatusNotificationRequest request,
            String uri,
            String action) {
        if (request == null || request.getPatientId() == null || request.getBookingId() == null) {
            log.warn("Skip {} booking notification because request is incomplete", action);
            return;
        }

        try {
            webClient
                    .post()
                    .uri(uri)
                    .bodyValue(request)
                    .retrieve()
                    .toBodilessEntity()
                    .block(Duration.ofSeconds(30));

            log.info("Requested {} booking notification for booking {}", action, request.getBookingId());
        } catch (Exception e) {
            log.warn("Could not request {} booking notification for booking {}: {}",
                    action, request.getBookingId(), e.getMessage());
        }
    }
}
