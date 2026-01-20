package com.medibook.notification.controller;

import com.medibook.common.dto.ApiResponse;
import com.medibook.common.dto.PageResponse;
import com.medibook.notification.entity.Notification;
import com.medibook.notification.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Notification Controller
 */
@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
@Tag(name = "Notifications", description = "API thông báo")
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    @Operation(summary = "Lấy danh sách thông báo của user")
    public ResponseEntity<ApiResponse<PageResponse<Notification>>> getUserNotifications(
            @RequestHeader("X-User-Id") UUID userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Page<Notification> notifications = notificationService.getUserNotifications(userId, PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(notifications.getContent(), page, size, notifications.getTotalElements())));
    }

    @GetMapping("/unread")
    @Operation(summary = "Lấy danh sách thông báo chưa đọc")
    public ResponseEntity<ApiResponse<List<Notification>>> getUnreadNotifications(
            @RequestHeader("X-User-Id") UUID userId) {
        return ResponseEntity.ok(ApiResponse.success(notificationService.getUnreadNotifications(userId)));
    }

    @GetMapping("/count")
    @Operation(summary = "Đếm số thông báo chưa đọc")
    public ResponseEntity<ApiResponse<Map<String, Long>>> countUnread(
            @RequestHeader("X-User-Id") UUID userId) {
        long count = notificationService.countUnread(userId);
        return ResponseEntity.ok(ApiResponse.success(Map.of("unreadCount", count)));
    }

    @PutMapping("/{id}/read")
    @Operation(summary = "Đánh dấu thông báo đã đọc")
    public ResponseEntity<ApiResponse<Void>> markAsRead(@PathVariable UUID id) {
        notificationService.markAsRead(id);
        return ResponseEntity.ok(ApiResponse.success("Đã đánh dấu đã đọc", null));
    }

    @PutMapping("/read-all")
    @Operation(summary = "Đánh dấu tất cả thông báo đã đọc")
    public ResponseEntity<ApiResponse<Void>> markAllAsRead(
            @RequestHeader("X-User-Id") UUID userId) {
        notificationService.markAllAsRead(userId);
        return ResponseEntity.ok(ApiResponse.success("Đã đánh dấu tất cả đã đọc", null));
    }
}
