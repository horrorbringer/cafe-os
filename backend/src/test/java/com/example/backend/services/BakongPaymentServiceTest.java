package com.example.backend.services;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.content;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.header;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;

import com.example.backend.dto.payment.BakongKhqrRequestDTO;
import com.example.backend.dto.payment.BakongKhqrResponseDTO;
import com.example.backend.dto.payment.BakongPaymentCheckRequestDTO;
import com.example.backend.dto.payment.BakongPaymentCheckResponseDTO;

import kh.gov.nbc.bakong_khqr.BakongKHQR;

class BakongPaymentServiceTest {

    private static final String CHECK_URL = "https://api-bakong.nbc.gov.kh/v1/check_transaction_by_md5";

    @Test
    void generatesValidDynamicKhqrWithOfficialSdk() {
        BakongPaymentService service = service(RestClient.builder(), "token");
        BakongKhqrRequestDTO request = new BakongKhqrRequestDTO();
        request.setBakongAccountId("merchant@bank");
        request.setMerchantName("Cafe POS");
        request.setAmount(2.50);
        request.setCurrency("USD");
        request.setBillNumber("ORD-1001");

        BakongKhqrResponseDTO response = service.generateKhqr(request);

        assertTrue(response.isSuccess());
        assertNotNull(response.getData().getMd5());
        assertEquals(32, response.getData().getMd5().length());
        assertEquals("DYNAMIC", response.getData().getType());
        assertTrue(BakongKHQR.verify(response.getData().getQr()).getData().isValid());
    }

    @Test
    void mapsSuccessfulBakongTransactionCheck() {
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        BakongPaymentService service = service(builder, "test-token");
        server.expect(requestTo(CHECK_URL))
                .andExpect(header(HttpHeaders.AUTHORIZATION, "Bearer test-token"))
                .andExpect(content().json("{\"md5\":\"0123456789abcdef0123456789abcdef\"}"))
                .andRespond(withSuccess("""
                        {
                          "responseCode": 0,
                          "responseMessage": "Success",
                          "data": {
                            "hash": "payment-hash",
                            "fromAccountId": "buyer@bank",
                            "toAccountId": "merchant@bank",
                            "amount": 2.5,
                            "currency": "USD",
                            "externalRef": "txn-1001",
                            "createdDateMs": 1710000000000
                          }
                        }
                        """, MediaType.APPLICATION_JSON));

        BakongPaymentCheckRequestDTO request = new BakongPaymentCheckRequestDTO();
        request.setMd5("0123456789abcdef0123456789abcdef");
        BakongPaymentCheckResponseDTO response = service.checkPaymentStatus(request);

        assertTrue(response.isSuccess());
        assertEquals("COMPLETED", response.getData().getStatus());
        assertEquals("txn-1001", response.getData().getPayment().getTransactionId());
        assertEquals(2.5, response.getData().getPayment().getAmount());
        server.verify();
    }

    private BakongPaymentService service(RestClient.Builder builder, String token) {
        return new BakongPaymentService(builder, CHECK_URL, token, "Phnom Penh", 5);
    }
}
