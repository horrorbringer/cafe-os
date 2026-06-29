package com.example.backend.dto.report;

import lombok.Data;

@Data
public class LoyaltyReportDTO {
    private Integer totalCustomers;
    private Integer activeLoyaltyCustomers;
    private Integer bronzeCustomers;
    private Integer silverCustomers;
    private Integer goldCustomers;
    private Integer outstandingPoints;
    private Double outstandingValue;
    private Integer pointsEarned;
    private Integer pointsRedeemed;
    private Integer pointsRefunded;
    private Integer pointsReversed;
    private Integer pointsAdjustedUp;
    private Integer pointsAdjustedDown;
    private Double redeemedValue;
}
