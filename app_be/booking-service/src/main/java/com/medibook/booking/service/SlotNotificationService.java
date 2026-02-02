package com.medibook.booking.service;

import com.medibook.booking.dto.TimeSlotDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

/**
 * Service to send real-time WebSocket notifications for slot events
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SlotNotificationService {

    private final SimpMessagingTemplate messagingTemplate;

    // Topic for admin to receive new pending slots
    private static final String TOPIC_ADMIN_PENDING_SLOTS = "/topic/admin/pending-slots";

    /**
     * Notify admin when a new slot is created (PENDING status)
     */
    public void notifyNewPendingSlot(TimeSlotDto slot) {
        log.info("Sending WebSocket notification for new pending slot: {}", slot.getId());
        try {
            SlotNotification notification = new SlotNotification(
                    "NEW_SLOT",
                    "Có lịch làm việc mới chờ duyệt",
                    slot
            );
            messagingTemplate.convertAndSend(TOPIC_ADMIN_PENDING_SLOTS, notification);
            log.debug("WebSocket notification sent successfully");
        } catch (Exception e) {
            log.error("Failed to send WebSocket notification: {}", e.getMessage(), e);
        }
    }

    /**
     * Notify admin when a slot is approved
     */
    public void notifySlotApproved(TimeSlotDto slot) {
        log.info("Sending WebSocket notification for approved slot: {}", slot.getId());
        try {
            SlotNotification notification = new SlotNotification(
                    "SLOT_APPROVED",
                    "Lịch làm việc đã được duyệt",
                    slot
            );
            messagingTemplate.convertAndSend(TOPIC_ADMIN_PENDING_SLOTS, notification);
        } catch (Exception e) {
            log.error("Failed to send WebSocket notification: {}", e.getMessage(), e);
        }
    }

    /**
     * Notify admin when a slot is rejected
     */
    public void notifySlotRejected(TimeSlotDto slot) {
        log.info("Sending WebSocket notification for rejected slot: {}", slot.getId());
        try {
            SlotNotification notification = new SlotNotification(
                    "SLOT_REJECTED",
                    "Lịch làm việc đã bị từ chối",
                    slot
            );
            messagingTemplate.convertAndSend(TOPIC_ADMIN_PENDING_SLOTS, notification);
        } catch (Exception e) {
            log.error("Failed to send WebSocket notification: {}", e.getMessage(), e);
        }
    }

    /**
     * Notification payload
     */
    public record SlotNotification(
            String type,
            String message,
            TimeSlotDto slot
    ) {}
}
