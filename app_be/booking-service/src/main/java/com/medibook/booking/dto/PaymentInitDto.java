package com.medibook.booking.dto;

import com.medibook.common.enums.PaymentMethod;
import com.medibook.common.enums.PaymentStatus;
import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentInitDto {
    private UUID bookingId;
    private BigDecimal amount;
    private PaymentMethod paymentMethod;
    private PaymentStatus paymentStatus;
    private String provider;
    private String appTransId;
    private String orderUrl;
    private String qrCode;
    private String zpTransToken;
    private String orderToken;
    private String message;
}
