package com.medibook.notification.service;

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

        // Log email (thay vì gửi thực - vì không có SMTP)
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
     * Gửi notification khi lịch được xác nhận
     */
    public void sendBookingConfirmedNotification(UUID patientId, UUID bookingId, String doctorName, String date,
            String time) {
        String title = "Lịch đã được xác nhận";
        String message = String.format("Lịch khám với bác sĩ %s vào %s lúc %s đã được xác nhận.", doctorName, date,
                time);
        createAndSend(patientId, title, message, "BOOKING_CONFIRMED", bookingId);
    }

    /**
     * Gửi notification khi lịch bị hủy
     */
    public void sendBookingCancelledNotification(UUID userId, UUID bookingId, String reason) {
        String title = "Lịch đã bị hủy";
        String message = String.format("Lịch khám đã bị hủy. Lý do: %s", reason);
        createAndSend(userId, title, message, "BOOKING_CANCELLED", bookingId);
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
     * Log email thay vì gửi thực (không có SMTP)
     */
    private void logEmail(UUID userId, String subject, String body) {
        log.info("📧 EMAIL LOG (không gửi thực vì không có SMTP)");
        log.info("To: User {}", userId);
        log.info("Subject: {}", subject);
        log.info("Body: {}", body);
        log.info("---");
    }
}
