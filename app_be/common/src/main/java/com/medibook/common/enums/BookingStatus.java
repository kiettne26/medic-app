package com.medibook.common.enums;

/**
 * Trạng thái booking
 */
public enum BookingStatus {
    PENDING, // Chờ xác nhận
    CONFIRMED, // Đã xác nhận
    COMPLETED, // Hoàn thành
    CANCELED, // Đã hủy (American English)
    CANCELLED // Đã hủy (British English - tương thích DB)
}
