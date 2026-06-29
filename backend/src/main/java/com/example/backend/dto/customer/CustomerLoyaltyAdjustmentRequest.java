package com.example.backend.dto.customer;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CustomerLoyaltyAdjustmentRequest {

    @NotNull(message = "Points adjustment is required")
    private Integer points;

    @NotBlank(message = "Reason is required")
    private String reason;
}
