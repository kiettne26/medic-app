package com.medibook.notification.service;

import com.medibook.notification.dto.BookingCreatedEmailRequest;
import com.medibook.notification.dto.BookingStatusNotificationRequest;
import com.medibook.notification.dto.EmailVerificationEmailRequest;
import com.medibook.notification.entity.Notification;
import com.medibook.notification.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Notification Service - Xử lý thông báo
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final SimpMessagingTemplate messagingTemplate;
    private final EmailService emailService;

    /**
     * Tạo và gửi notification
     */
    @Transactional
    public Notification createAndSend(UUID userId, String title, String message, String type, UUID relatedId) {
        Notification notification = Notification.builder()
                .userId(userId)
                .title(title)
                .message(message)
                .type(type)
                .relatedId(relatedId)
                .isRead(false)
                .build();

        notification = notificationRepository.save(notification);

        // Gửi qua WebSocket
        try {
            messagingTemplate.convertAndSendToUser(
                    userId.toString(),
                    "/queue/notifications",
                    notification);
            log.info("WebSocket notification sent to user: {}", userId);
        } catch (Exception e) {
            log.warn("Failed to send WebSocket notification: {}", e.getMessage());
        }

        // Fallback log for notification events that do not include a recipient email
        logEmail(userId, title, message);

        return notification;
    }

    /**
     * Gửi notification khi đặt lịch thành công
     */
    public void sendBookingCreatedNotification(UUID patientId, UUID bookingId, String doctorName, String date,
            String time) {
        String title = "Đặt lịch thành công";
        String message = String.format("Bạn đã đặt lịch khám với bác sĩ %s vào %s lúc %s. Vui lòng chờ xác nhận.",
                doctorName, date, time);
        createAndSend(patientId, title, message, "BOOKING_CREATED", bookingId);
    }

    /**
     * Tao thong bao va gui email xac nhan khi benh nhan dat lich thanh cong.
     */
    @Transactional
    public void sendBookingCreatedConfirmation(BookingCreatedEmailRequest request) {
        if (request == null) {
            log.warn("Skip booking confirmation because request body is missing");
            return;
        }

        String title = "Đặt lịch thành công";
        String time = request.getEndTime() != null && !request.getEndTime().isBlank()
                ? request.getStartTime() + " - " + request.getEndTime()
                : request.getStartTime();
        String message = String.format(
                "Bạn đã đặt lịch khám với bác sĩ %s vào %s lúc %s. Vui lòng chờ xác nhận.",
                request.getDoctorName(), request.getDate(), time);

        if (request.getPatientId() != null && request.getBookingId() != null) {
            createAndSend(request.getPatientId(), title, message, "BOOKING_CREATED", request.getBookingId());
        } else {
            log.warn("Skip in-app booking notification because patientId or bookingId is missing");
        }

        emailService.sendBookingCreatedConfirmation(request);
    }

    public void sendEmailVerificationCode(EmailVerificationEmailRequest request) {
        emailService.sendEmailVerificationCode(request);
    }

    /**
     * Gửi notification khi lịch được xác nhận.
     */
    public void sendBookingConfirmedNotification(UUID patientId, UUID bookingId, String doctorName, String date,
            String time) {
        String title = "Lịch đã được xác nhận";
        String message = String.format("Lịch khám với bác sĩ %s vào %s lúc %s đã được xác nhận.", doctorName, date,
                time);
        createAndSend(patientId, title, message, "BOOKING_CONFIRMED", bookingId);
    }

    public void sendBookingConfirmedNotification(BookingStatusNotificationRequest request) {
        if (request == null || request.getPatientId() == null || request.getBookingId() == null) {
            log.warn("Skip confirmed booking notification because request is incomplete");
            return;
        }

        sendBookingConfirmedNotification(
                request.getPatientId(),
                request.getBookingId(),
                firstNonBlank(request.getDoctorName(), "bác sĩ"),
                firstNonBlank(request.getDate(), "ngày đã đặt"),
                formatTimeRange(request.getStartTime(), request.getEndTime()));
    }

    /**
     * Gửi notification khi lịch bị hủy
     */
    public void sendBookingCancelledNotification(UUID userId, UUID bookingId, String reason) {
        String title = "Lịch đã bị hủy";
        String message = String.format("Lịch khám đã bị hủy. Lý do: %s", reason);
        createAndSend(userId, title, message, "BOOKING_CANCELLED", bookingId);
    }

    public void sendBookingCancelledNotification(BookingStatusNotificationRequest request) {
        if (request == null || request.getPatientId() == null || request.getBookingId() == null) {
            log.warn("Skip cancelled booking notification because request is incomplete");
            return;
        }

        sendBookingCancelledNotification(
                request.getPatientId(),
                request.getBookingId(),
                firstNonBlank(request.getReason(), "Không có lý do cụ thể"));
    }

    /**
     * Gửi notification nhắc lịch
     */
    public void sendReminderNotification(UUID patientId, UUID bookingId, String doctorName, String date, String time) {
        String title = "Nhắc lịch khám";
        String message = String.format("Bạn có lịch khám với bác sĩ %s vào ngày mai %s lúc %s. Đừng quên nhé!",
                doctorName, date, time);
        createAndSend(patientId, title, message, "REMINDER", bookingId);
    }

    /**
     * Lấy danh sách notification của user
     */
    public Page<Notification> getUserNotifications(UUID userId, Pageable pageable) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
    }

    /**
     * Lấy notification chưa đọc
     */
    public List<Notification> getUnreadNotifications(UUID userId) {
        return notificationRepository.findByUserIdAndIsReadFalseOrderByCreatedAtDesc(userId);
    }

    /**
     * Đếm notification chưa đọc
     */
    public long countUnread(UUID userId) {
        return notificationRepository.countByUserIdAndIsReadFalse(userId);
    }

    /**
     * Đánh dấu đã đọc
     */
    @Transactional
    public void markAsRead(UUID notificationId) {
        notificationRepository.findById(notificationId).ifPresent(n -> {
            n.setIsRead(true);
            n.setReadAt(LocalDateTime.now());
            notificationRepository.save(n);
        });
    }

    /**
     * Đánh dấu tất cả đã đọc
     */
    @Transactional
    public void markAllAsRead(UUID userId) {
        notificationRepository.markAllAsRead(userId);
    }

    /**
     * Log fallback cho notification chua co email nguoi nhan.
     */
    private void logEmail(UUID userId, String subject, String body) {
        log.info("EMAIL FALLBACK LOG");
        log.info("To: User {}", userId);
        log.info("Subject: {}", subject);
        log.info("Body: {}", body);
        log.info("---");
    }

    private String formatTimeRange(String startTime, String endTime) {
        if (startTime == null || startTime.isBlank()) {
            return "giờ đã đặt";
        }
        if (endTime == null || endTime.isBlank()) {
            return startTime;
        }
        return startTime + " - " + endTime;
    }

    private String firstNonBlank(String... values) {
        if (values == null) {
            return null;
        }
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                return value;
            }
        }
        return null;
    }
}
