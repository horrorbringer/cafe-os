package com.example.backend.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class RecipeUpdateRequestDTO {
    @NotNull(message = "Quantity needed is required")
    @Positive(message = "Quantity needed must be positive")
    private Double quantityNeeded;

    public Double getQuantityNeeded() { return quantityNeeded; }
    public void setQuantityNeeded(Double quantityNeeded) { this.quantityNeeded = quantityNeeded; }
}
