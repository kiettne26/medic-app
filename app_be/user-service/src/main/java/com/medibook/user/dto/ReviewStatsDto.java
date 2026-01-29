package com.medibook.user.dto;

import lombok.*;
import java.util.Map;

/**
 * DTO cho Review Statistics
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReviewStatsDto {
    private double averageRating;
    private int totalReviews;
    private Map<Integer, Integer> ratingDistribution; // 5->count, 4->count, etc.
    private double monthlyGrowth; // % growth this month
}
