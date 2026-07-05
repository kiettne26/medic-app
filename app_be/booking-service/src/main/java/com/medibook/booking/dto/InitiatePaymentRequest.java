package com.medibook.booking.dto;

import com.medibook.common.enums.PaymentMethod;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InitiatePaymentRequest {

    @NotNull(message = "Payment method khong duoc de trong")
    private PaymentMethod paymentMethod;
}
