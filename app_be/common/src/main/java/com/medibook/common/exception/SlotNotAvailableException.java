package com.medibook.common.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Exception khi slot không còn available (đã bị đặt)
 */
@ResponseStatus(HttpStatus.CONFLICT)
public class SlotNotAvailableException extends RuntimeException {

    public SlotNotAvailableException(String message) {
        super(message);
    }

    public SlotNotAvailableException() {
        super("Lịch khám này đã được đặt trước. Vui lòng chọn khung giờ khác.");
    }
}
