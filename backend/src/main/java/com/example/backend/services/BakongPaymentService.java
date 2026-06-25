package com.example.backend.services;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import com.example.backend.dto.payment.BakongKhqrRequestDTO;
import com.example.backend.dto.payment.BakongKhqrResponseDTO;
import com.example.backend.dto.payment.BakongPaymentCheckRequestDTO;
import com.example.backend.dto.payment.BakongPaymentCheckResponseDTO;
import com.fasterxml.jackson.databind.JsonNode;

import kh.gov.nbc.bakong_khqr.BakongKHQR;
import kh.gov.nbc.bakong_khqr.model.IndividualInfo;
import kh.gov.nbc.bakong_khqr.model.KHQRCurrency;
import kh.gov.nbc.bakong_khqr.model.KHQRData;
import kh.gov.nbc.bakong_khqr.model.KHQRResponse;

@Service
public class BakongPaymentService {

    private final RestClient restClient;
    private final String paymentCheckUrl;
    private final String apiToken;
    private final String merchantCity;
    private final long expirationMinutes;

    public BakongPaymentService(
            RestClient.Builder restClientBuilder,
            @Value("${bakong.api.url:https://api-bakong.nbc.gov.kh/v1/check_transaction_by_md5}") String paymentCheckUrl,
            @Value("${bakong.api.token:}") String apiToken,
            @Value("${bakong.merchant-city:Phnom Penh}") String merchantCity,
            @Value("${bakong.khqr.expiration-minutes:5}") long expirationMinutes) {
        this.restClient = restClientBuilder.build();
        this.paymentCheckUrl = paymentCheckUrl;
        this.apiToken = apiToken;
        this.merchantCity = merchantCity;
        this.expirationMinutes = expirationMinutes;
    }

    public BakongKhqrResponseDTO generateKhqr(BakongKhqrRequestDTO request) {
        KHQRCurrency currency = KHQRCurrency.valueOf(request.getCurrency().toUpperCase());
        Instant expiresAt = Instant.now().plus(expirationMinutes, ChronoUnit.MINUTES);

        IndividualInfo individualInfo = new IndividualInfo();
        individualInfo.setBakongAccountId(request.getBakongAccountId());
        individualInfo.setMerchantName(request.getMerchantName());
        individualInfo.setMerchantCity(merchantCity);
        individualInfo.setCurrency(currency);
        individualInfo.setAmount(request.getAmount());
        individualInfo.setBillNumber(request.getBillNumber());
        individualInfo.setPurposeOfTransaction("Cafe order");
        individualInfo.setExpirationTimestamp(expiresAt.toEpochMilli());

        KHQRResponse<KHQRData> sdkResponse = BakongKHQR.generateIndividual(individualInfo);
        if (sdkResponse.getKHQRStatus() == null
                || sdkResponse.getKHQRStatus().getCode() != 0
                || sdkResponse.getData() == null) {
            String message = sdkResponse.getKHQRStatus() == null
                    ? "Unknown KHQR SDK error"
                    : sdkResponse.getKHQRStatus().getMessage();
            throw new IllegalArgumentException("Unable to generate KHQR: " + message);
        }

        BakongKhqrResponseDTO.KhqrData data = new BakongKhqrResponseDTO.KhqrData();
        data.setQr(sdkResponse.getData().getQr());
        data.setMd5(sdkResponse.getData().getMd5());
        data.setType("DYNAMIC");
        data.setExpiresAt(expiresAt.toString());

        BakongKhqrResponseDTO response = new BakongKhqrResponseDTO();
        response.setSuccess(true);
        response.setData(data);
        return response;
    }

    public BakongPaymentCheckResponseDTO checkPaymentStatus(BakongPaymentCheckRequestDTO request) {
        if (apiToken == null || apiToken.isBlank()) {
            throw new IllegalStateException("BAKONG_API_TOKEN is required to check payment status");
        }

        try {
            JsonNode response = restClient.post()
                    .uri(paymentCheckUrl)
                    .contentType(MediaType.APPLICATION_JSON)
                    .headers(headers -> headers.setBearerAuth(apiToken))
                    .body(Map.of("md5", request.getMd5()))
                    .retrieve()
                    .body(JsonNode.class);
            return mapPaymentCheckResponse(response);
        } catch (RestClientException e) {
            throw new RuntimeException("Bakong payment status check failed", e);
        }
    }

    private BakongPaymentCheckResponseDTO mapPaymentCheckResponse(JsonNode response) {
        BakongPaymentCheckResponseDTO result = new BakongPaymentCheckResponseDTO();
        JsonNode dataNode = response == null ? null : response.path("data");
        boolean completed = response != null
                && response.path("responseCode").asInt(-1) == 0
                && dataNode != null
                && !dataNode.isMissingNode()
                && !dataNode.isNull();

        BakongPaymentCheckResponseDTO.PaymentData data = new BakongPaymentCheckResponseDTO.PaymentData();
        data.setStatus(completed ? "COMPLETED" : "PENDING");

        if (completed) {
            BakongPaymentCheckResponseDTO.PaymentDetails payment = new BakongPaymentCheckResponseDTO.PaymentDetails();
            payment.setHash(text(dataNode, "hash", "md5"));
            payment.setFromAccountId(text(dataNode, "fromAccountId", "from_account_id"));
            payment.setToAccountId(text(dataNode, "toAccountId", "to_account_id"));
            payment.setAmount(number(dataNode, "amount"));
            payment.setCurrency(text(dataNode, "currency"));
            payment.setTransactionId(text(dataNode, "externalRef", "external_ref", "transactionId"));
            payment.setTime(text(dataNode, "createdDateMs", "created_date_ms", "createdDate"));
            data.setPayment(payment);
        }

        result.setSuccess(completed);
        result.setData(data);
        return result;
    }

    private String text(JsonNode node, String... fieldNames) {
        for (String fieldName : fieldNames) {
            JsonNode value = node.get(fieldName);
            if (value != null && !value.isNull()) {
                return value.asText();
            }
        }
        return null;
    }

    private Double number(JsonNode node, String fieldName) {
        JsonNode value = node.get(fieldName);
        return value == null || value.isNull() ? null : value.asDouble();
    }
}
