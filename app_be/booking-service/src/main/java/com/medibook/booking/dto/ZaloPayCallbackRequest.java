package com.medibook.booking.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ZaloPayCallbackRequest {
    private String data;
    private String mac;
    private Integer type;
}
