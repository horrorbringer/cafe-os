package com.example.backend.controller;

import com.example.backend.dto.OrderRequestDTO;
import com.example.backend.dto.payment.*;
import com.example.backend.services.BakongPaymentService;
import com.example.backend.services.OrderService;
import com.example.backend.services.SystemSettingService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/payments/bakong")
public class BakongPaymentController {

    private final BakongPaymentService bakongPaymentService;
    private final OrderService orderService;
    private final SystemSettingService systemSettingService;

    public BakongPaymentController(BakongPaymentService bakongPaymentService, OrderService orderService,
            SystemSettingService systemSettingService) {
        this.bakongPaymentService = bakongPaymentService;
        this.orderService = orderService;
        this.systemSettingService = systemSettingService;
    }

    @PostMapping("/generate")
    public ResponseEntity<BakongKhqrResponseDTO> generateKhqr(@Valid @RequestBody OrderRequestDTO orderRequest) {
        // 1. Securely calculate total on server based on DB prices
        Double securedAmount = orderService.calculateTotal(orderRequest);

        // 2. Prepare the real Bakong request with internal config
        BakongKhqrRequestDTO bakongRequest = new BakongKhqrRequestDTO();
        bakongRequest.setAmount(securedAmount);
        bakongRequest.setBakongAccountId(requiredSetting("BAKONG_ACCOUNT_ID"));
        String merchantName = systemSettingService.getValue("BAKONG_MERCHANT_NAME");
        bakongRequest.setMerchantName(merchantName == null || merchantName.isBlank() ? "Cafe POS System" : merchantName);
        bakongRequest.setBillNumber("ORD-" + System.currentTimeMillis());
        bakongRequest.setCurrency("USD");

        return ResponseEntity.ok(bakongPaymentService.generateKhqr(bakongRequest));
    }

    @PostMapping("/check")
    public ResponseEntity<BakongPaymentCheckResponseDTO> checkPaymentStatus(
            @Valid @RequestBody BakongPaymentCheckRequestDTO request) {
        return ResponseEntity.ok(bakongPaymentService.checkPaymentStatus(request));
    }

    private String requiredSetting(String key) {
        String value = systemSettingService.getValue(key);
        if (value == null || value.isBlank()) {
            throw new IllegalStateException(key + " is not configured");
        }
        return value;
    }
}
