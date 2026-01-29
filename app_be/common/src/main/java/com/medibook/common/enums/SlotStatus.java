package com.medibook.common.enums;

/**
 * Trạng thái phê duyệt của khung giờ làm việc
 */
public enum SlotStatus {
    PENDING, // Chờ duyệt
    APPROVED, // Đã duyệt - hiển thị cho bệnh nhân
    REJECTED // Từ chối
}
