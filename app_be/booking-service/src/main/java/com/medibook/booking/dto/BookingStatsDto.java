package com.medibook.booking.dto;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BookingStatsDto {
    private int totalToday;
    private int pendingCount;
    private int confirmedCount;
    private int completedCount;
    private int canceledCount;
    private double todayChangePercent;
    private double pendingChangePercent;
    private double completedChangePercent;
}
