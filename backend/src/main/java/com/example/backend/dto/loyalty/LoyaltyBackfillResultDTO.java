package com.example.backend.dto.loyalty;

import lombok.Data;

@Data
public class LoyaltyBackfillResultDTO {
    private Boolean applied;
    private Integer scannedOrders;
    private Integer earnTransactionsCreated;
    private Integer redeemTransactionsCreated;
    private Integer skippedOrders;
    private String note;
}
