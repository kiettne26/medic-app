package com.medibook.booking.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.medibook.booking.dto.PaymentInitDto;
import com.medibook.booking.dto.ZaloPayCallbackRequest;
import com.medibook.booking.entity.Booking;
import com.medibook.common.enums.PaymentMethod;
import com.medibook.common.enums.PaymentStatus;
import com.medibook.common.exception.BadRequestException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class ZaloPayService {

    private static final ZoneId VIETNAM_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final DateTimeFormatter APP_TRANS_DATE = DateTimeFormatter.ofPattern("yyMMdd");

    private final ObjectMapper objectMapper;
    private final WebClient webClient = WebClient.builder().build();

    @Value("${payments.zalopay.app-id:0}")
    private int appId;

    @Value("${payments.zalopay.key1:}")
    private String key1;

    @Value("${payments.zalopay.key2:}")
    private String key2;

    @Value("${payments.zalopay.create-endpoint:https://sb-openapi.zalopay.vn/v2/create}")
    private String createEndpoint;

    @Value("${payments.zalopay.query-endpoint:https://sb-openapi.zalopay.vn/v2/query}")
    private String queryEndpoint;

    @Value("${payments.zalopay.callback-url:}")
    private String callbackUrl;

    @Value("${payments.zalopay.redirect-url:}")
    private String redirectUrl;

    @Value("${payments.zalopay.merchant-name:MediBook}")
    private String merchantName;

    @Value("${payments.zalopay.mock-enabled:true}")
    private boolean mockEnabled;

    public PaymentInitDto createOrder(Booking booking, String serviceName, PaymentMethod paymentMethod) {
        if (mockEnabled) {
            long amount = toVnd(booking.getTotalAmount());
            long appTime = System.currentTimeMillis();
            String appTransId = buildAppTransId(booking.getId(), appTime);
            
            String gatewayBase = "http://localhost:8080";
            if (callbackUrl != null && !callbackUrl.isBlank()) {
                try {
                    java.net.URI uri = new java.net.URI(callbackUrl);
                    gatewayBase = uri.getScheme() + "://" + uri.getAuthority();
                } catch (Exception e) {
                    log.warn("Failed to parse callbackUrl to get gateway base URL, using default", e);
                }
            }
            
            String mockOrderUrl = gatewayBase + "/api/bookings/payment/mock-gate?app_trans_id=" + appTransId
                    + "&method=" + paymentMethod.name();
            
            return PaymentInitDto.builder()
                    .bookingId(booking.getId())
                    .amount(booking.getTotalAmount())
                    .paymentMethod(paymentMethod)
                    .paymentStatus(PaymentStatus.PENDING)
                    .provider("ZALOPAY")
                    .appTransId(appTransId)
                    .orderUrl(mockOrderUrl)
                    .message("Khởi tạo đơn hàng giả lập thành công")
                    .build();
        }

        ensureCreateConfigured();

        long amount = toVnd(booking.getTotalAmount());
        long appTime = System.currentTimeMillis();
        String appTransId = buildAppTransId(booking.getId(), appTime);
        String appUser = booking.getPatientId().toString();
        String item = toJson(List.of(Map.of(
                "itemid", booking.getServiceId().toString(),
                "itemname", serviceName,
                "itemprice", amount,
                "itemquantity", 1)));
        String embedData = buildEmbedData(booking, paymentMethod);
        String description = merchantName + " - Thanh toan lich kham #" + booking.getId().toString().substring(0, 8);

        Map<String, Object> order = new LinkedHashMap<>();
        order.put("app_id", appId);
        order.put("app_user", appUser);
        order.put("app_time", appTime);
        order.put("amount", amount);
        order.put("app_trans_id", appTransId);
        order.put("bank_code", "");
        order.put("embed_data", embedData);
        order.put("item", item);
        order.put("description", description);
        if (hasText(callbackUrl)) {
            order.put("callback_url", callbackUrl);
        }
        order.put("mac", hmacSha256(buildCreateMacInput(appTransId, appUser, amount, appTime, embedData, item), key1));

        Map<String, Object> response = webClient.post()
                .uri(createEndpoint)
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(order)
                .retrieve()
                .bodyToMono(new ParameterizedTypeReference<Map<String, Object>>() {
                })
                .block(Duration.ofSeconds(20));

        int returnCode = asInt(response != null ? response.get("return_code") : null);
        if (returnCode != 1) {
            String message = asString(response != null ? response.get("return_message") : null);
            throw new BadRequestException(hasText(message) ? message : "Khong the tao don thanh toan ZaloPay");
        }

        return PaymentInitDto.builder()
                .bookingId(booking.getId())
                .amount(booking.getTotalAmount())
                .paymentMethod(paymentMethod)
                .paymentStatus(PaymentStatus.PENDING)
                .provider("ZALOPAY")
                .appTransId(appTransId)
                .orderUrl(asString(response.get("order_url")))
                .qrCode(asString(response.get("qr_code")))
                .zpTransToken(asString(response.get("zp_trans_token")))
                .orderToken(asString(response.get("order_token")))
                .message(asString(response.get("return_message")))
                .build();
    }

    public PaymentStatus queryOrderStatus(String appTransId) {
        ensureCreateConfigured();

        Map<String, Object> request = new LinkedHashMap<>();
        request.put("app_id", appId);
        request.put("app_trans_id", appTransId);
        request.put("mac", hmacSha256(appId + "|" + appTransId + "|" + key1, key1));

        Map<String, Object> response = webClient.post()
                .uri(queryEndpoint)
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(request)
                .retrieve()
                .bodyToMono(new ParameterizedTypeReference<Map<String, Object>>() {
                })
                .block(Duration.ofSeconds(20));

        int returnCode = asInt(response != null ? response.get("return_code") : null);
        if (returnCode == 1) {
            return PaymentStatus.PAID;
        }
        if (returnCode == 2) {
            return PaymentStatus.FAILED;
        }
        return PaymentStatus.PENDING;
    }

    public boolean isValidCallback(ZaloPayCallbackRequest request) {
        if (!hasText(key2) || request == null || !hasText(request.getData()) || !hasText(request.getMac())) {
            return false;
        }
        String mac = hmacSha256(request.getData(), key2);
        return mac.equals(request.getMac());
    }

    public Map<String, Object> parseCallbackData(String data) {
        try {
            return objectMapper.readValue(data, new TypeReference<Map<String, Object>>() {
            });
        } catch (JsonProcessingException e) {
            throw new BadRequestException("Du lieu callback ZaloPay khong hop le");
        }
    }

    private String buildEmbedData(Booking booking, PaymentMethod paymentMethod) {
        Map<String, Object> embedData = new LinkedHashMap<>();
        embedData.put("bookingId", booking.getId().toString());
        embedData.put("preferred_payment_method",
                paymentMethod == PaymentMethod.BANK_APP ? List.of("vietqr") : List.of("zalopay_wallet"));
        if (hasText(redirectUrl)) {
            embedData.put("redirecturl", redirectUrl);
        }
        return toJson(embedData);
    }

    private String buildCreateMacInput(String appTransId, String appUser, long amount, long appTime,
            String embedData, String item) {
        return appId + "|" + appTransId + "|" + appUser + "|" + amount + "|" + appTime + "|" + embedData + "|"
                + item;
    }

    private String buildAppTransId(UUID bookingId, long appTime) {
        String date = LocalDate.now(VIETNAM_ZONE).format(APP_TRANS_DATE);
        String bookingCode = bookingId.toString().replace("-", "").substring(0, 10);
        return date + "_" + bookingCode + appTime;
    }

    private long toVnd(BigDecimal amount) {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new BadRequestException("So tien thanh toan khong hop le");
        }
        return amount.setScale(0, RoundingMode.HALF_UP).longValue();
    }

    private void ensureCreateConfigured() {
        if (appId <= 0 || !hasText(key1) || !hasText(createEndpoint)) {
            throw new BadRequestException(
                    "Chua cau hinh ZaloPay. Hay tao app_be/payment-env.bat va dien ZALOPAY_APP_ID, ZALOPAY_KEY1, ZALOPAY_KEY2.");
        }
    }

    private String toJson(Object value) {
        try {
            return objectMapper.writeValueAsString(value);
        } catch (JsonProcessingException e) {
            throw new BadRequestException("Khong the tao du lieu thanh toan");
        }
    }

    private String hmacSha256(String data, String key) {
        try {
            Mac hmac = Mac.getInstance("HmacSHA256");
            hmac.init(new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            byte[] digest = hmac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(digest.length * 2);
            for (byte b : digest) {
                hex.append(String.format("%02x", b));
            }
            return hex.toString();
        } catch (Exception e) {
            throw new BadRequestException("Khong the ky du lieu thanh toan");
        }
    }

    private boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }

    private int asInt(Object value) {
        if (value instanceof Number number) {
            return number.intValue();
        }
        if (value != null) {
            return Integer.parseInt(value.toString());
        }
        return 0;
    }

    private String asString(Object value) {
        return value != null ? value.toString() : null;
    }
}
