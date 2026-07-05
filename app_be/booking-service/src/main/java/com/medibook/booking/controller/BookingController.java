package com.medibook.booking.controller;

import com.medibook.booking.dto.*;
import com.medibook.booking.service.BookingService;
import com.medibook.common.dto.ApiResponse;
import com.medibook.common.dto.PageResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * Booking Controller - API endpoints cho đặt lịch
 */
@RestController
@RequestMapping("/bookings")
@RequiredArgsConstructor
@Tag(name = "Bookings", description = "API đặt lịch khám")
public class BookingController {

    private final BookingService bookingService;

    /**
     * 🔐 Đặt lịch mới - Core endpoint
     */
    @PostMapping
    @Operation(summary = "Đặt lịch khám mới")
    public ResponseEntity<ApiResponse<BookingDto>> createBooking(
            @RequestHeader("X-User-Id") UUID userId,
            @Valid @RequestBody CreateBookingRequest request) {
        BookingDto booking = bookingService.createBooking(userId, request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success("Đặt lịch thành công", booking));
    }

    @PostMapping("/{id}/payment/initiate")
    @Operation(summary = "Tao don thanh toan ZaloPay sau khi dat lich")
    public ResponseEntity<ApiResponse<PaymentInitDto>> initiatePayment(
            @PathVariable UUID id,
            @RequestHeader("X-User-Id") UUID userId,
            @Valid @RequestBody InitiatePaymentRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Tao don thanh toan thanh cong",
                bookingService.initiatePayment(id, userId, request)));
    }

    @GetMapping("/{id}/payment/status")
    @Operation(summary = "Kiem tra trang thai thanh toan")
    public ResponseEntity<ApiResponse<BookingDto>> refreshPaymentStatus(
            @PathVariable UUID id,
            @RequestHeader("X-User-Id") UUID userId) {
        return ResponseEntity.ok(ApiResponse.success(bookingService.refreshPaymentStatus(id, userId)));
    }

    @PostMapping("/payment/zalopay/callback")
    @Operation(summary = "Callback thanh toan tu ZaloPay")
    public ResponseEntity<ZaloPayCallbackResponse> handleZaloPayCallback(
            @RequestBody ZaloPayCallbackRequest request) {
        return ResponseEntity.ok(bookingService.handleZaloPayCallback(request));
    }

    @GetMapping("/admin")
    @Operation(summary = "Lấy danh sách tất cả booking (Admin)")
    public ResponseEntity<ApiResponse<PageResponse<BookingDto>>> getAllBookings(
            @RequestParam(required = false) com.medibook.common.enums.BookingStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Page<BookingDto> bookings = bookingService.getAllBookings(status, PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(bookings.getContent(), page, size, bookings.getTotalElements())));
    }

    @GetMapping("/admin/stats")
    @Operation(summary = "Lấy thống kê lịch hẹn cho Admin")
    public ResponseEntity<ApiResponse<com.medibook.booking.dto.BookingStatsDto>> getBookingStats() {
        return ResponseEntity.ok(ApiResponse.success(bookingService.getBookingStats()));
    }


    @GetMapping("/{id}")
    @Operation(summary = "Lấy thông tin booking theo ID")
    public ResponseEntity<ApiResponse<BookingDto>> getBookingById(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.success(bookingService.getBookingById(id)));
    }

    @GetMapping("/patient")
    @Operation(summary = "Lấy danh sách booking của bệnh nhân hiện tại")
    public ResponseEntity<ApiResponse<PageResponse<BookingDto>>> getPatientBookings(
            @RequestHeader("X-User-Id") UUID userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Page<BookingDto> bookings = bookingService.getPatientBookings(userId, PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(bookings.getContent(), page, size, bookings.getTotalElements())));
    }

    @GetMapping("/doctor")
    @Operation(summary = "Lấy danh sách booking của bác sĩ hiện tại")
    public ResponseEntity<ApiResponse<PageResponse<BookingDto>>> getDoctorBookings(
            @RequestHeader("X-User-Id") UUID userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Page<BookingDto> bookings = bookingService.getDoctorBookings(userId, PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(bookings.getContent(), page, size, bookings.getTotalElements())));
    }

    @GetMapping("/doctor/date/{date}")
    @Operation(summary = "Lấy lịch khám của bác sĩ trong ngày")
    public ResponseEntity<ApiResponse<List<BookingDto>>> getDoctorBookingsByDate(
            @RequestHeader("X-User-Id") UUID userId,
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ResponseEntity.ok(ApiResponse.success(bookingService.getDoctorBookingsByDate(userId, date)));
    }

    @PutMapping("/{id}/confirm")
    @Operation(summary = "Xác nhận lịch (Bác sĩ)")
    public ResponseEntity<ApiResponse<BookingDto>> confirmBooking(
            @PathVariable UUID id,
            @RequestHeader("X-User-Id") UUID userId) {
        return ResponseEntity.ok(ApiResponse.success("Xác nhận thành công", bookingService.confirmBooking(id, userId)));
    }

    @PutMapping("/{id}/complete")
    @Operation(summary = "Hoàn thành lịch (Bác sĩ)")
    public ResponseEntity<ApiResponse<BookingDto>> completeBooking(
            @PathVariable UUID id,
            @RequestHeader("X-User-Id") UUID userId,
            @RequestParam(required = false) String doctorNotes) {
        return ResponseEntity.ok(
                ApiResponse.success("Hoàn thành thành công", bookingService.completeBooking(id, userId, doctorNotes)));
    }

    @PutMapping("/{id}/cancel")
    @Operation(summary = "Hủy lịch")
    public ResponseEntity<ApiResponse<BookingDto>> cancelBooking(
            @PathVariable UUID id,
            @RequestHeader("X-User-Id") UUID userId,
            @RequestBody CancelBookingRequest request) {
        return ResponseEntity
                .ok(ApiResponse.success("Hủy lịch thành công", bookingService.cancelBooking(id, userId, request)));
    }
    @GetMapping("/payment/mock-gate")
    public ResponseEntity<String> showMockPaymentGate(
            @RequestParam("app_trans_id") String appTransId,
            @RequestParam(value = "method", defaultValue = "ZALOPAY") String method) {
        double amountDouble = 300000;
        try {
            amountDouble = bookingService.getAmountByPaymentReference(appTransId);
        } catch (Exception e) {
            // fallback
        }
        String amountFormatted = java.text.NumberFormat.getNumberInstance(new java.util.Locale("vi", "VN")).format(amountDouble) + "đ";

        String html;
        if ("BANK_APP".equalsIgnoreCase(method)) {
            html = "<!DOCTYPE html>\n" +
                    "<html>\n" +
                    "<head>\n" +
                    "    <meta charset=\"UTF-8\">\n" +
                    "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n" +
                    "    <title>Thanh Toán VietQR - MediBook</title>\n" +
                    "    <style>\n" +
                    "        body { font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, sans-serif; background-color: #f3f4f6; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; padding: 16px; box-sizing: border-box; }\n" +
                    "        .card { background: white; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); padding: 24px; width: 100%; max-width: 440px; text-align: center; box-sizing: border-box; }\n" +
                    "        .logos { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding: 0 10px; }\n" +
                    "        .logo-vietqr { height: 32px; width: auto; }\n" +
                    "        .logo-napas { height: 20px; width: auto; }\n" +
                    "        h2 { color: #111827; margin: 0 0 4px 0; font-size: 18px; font-weight: 700; }\n" +
                    "        .subtitle { color: #6b7280; font-size: 13px; margin-bottom: 20px; text-transform: uppercase; letter-spacing: 0.5px; }\n" +
                    "        .qr-container { background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 16px; padding: 16px; margin-bottom: 20px; display: inline-block; width: 100%; box-sizing: border-box; }\n" +
                    "        .qr-code { width: 220px; height: 220px; margin: 0 auto; display: block; border-radius: 8px; }\n" +
                    "        .qr-hint { color: #4b5563; font-size: 12px; margin-top: 10px; font-weight: 500; }\n" +
                    "        .info-box { text-align: left; background: #f8fafc; border-radius: 12px; padding: 16px; margin-bottom: 20px; border: 1px solid #f1f5f9; }\n" +
                    "        .info-row { display: flex; justify-content: space-between; margin-bottom: 10px; font-size: 13px; }\n" +
                    "        .info-row:last-child { margin-bottom: 0; }\n" +
                    "        .info-label { color: #64748b; }\n" +
                    "        .info-value { color: #0f172a; font-weight: 600; text-align: right; }\n" +
                    "        .amount { color: #00875a; font-weight: 800; font-size: 16px; }\n" +
                    "        .btn { display: block; width: 100%; padding: 14px; border: none; border-radius: 12px; font-size: 15px; font-weight: 700; cursor: pointer; transition: background 0.2s; box-sizing: border-box; }\n" +
                    "        .btn-success { background-color: #00875a; color: white; margin-top: 16px; }\n" +
                    "        .btn-success:hover { background-color: #006644; }\n" +
                    "        .btn-cancel { background-color: #f3f4f6; color: #4b5563; margin-top: 8px; }\n" +
                    "        .btn-cancel:hover { background-color: #e5e7eb; }\n" +
                    "        .success-box { display: none; }\n" +
                    "        .success-icon { font-size: 54px; color: #00875a; margin-bottom: 16px; }\n" +
                    "    </style>\n" +
                    "</head>\n" +
                    "<body>\n" +
                    "    <div class=\"card\" id=\"payment-card\">\n" +
                    "        <div class=\"logos\">\n" +
                    "            <img class=\"logo-vietqr\" src=\"https://vietqr.net/portal-service/v1/File/get/1c6d328c-e837-4d9d-9f4a-7b3b3cb55938\" alt=\"VietQR\">\n" +
                    "            <img class=\"logo-napas\" src=\"https://images.squarespace-cdn.com/content/v1/5ea04b77f11370252b4ab5f4/1628178125433-286V5U46DCPGOCL23SVO/Logo+Napas.png\" style=\"height:28px; width:auto;\" alt=\"Napas247\">\n" +
                    "        </div>\n" +
                    "        <h2>Quét mã VietQR để thanh toán</h2>\n" +
                    "        <p class=\"subtitle\">Ứng dụng Ngân hàng hỗ trợ thanh toán qua mã QR</p>\n" +
                    "        \n" +
                    "        <div class=\"qr-container\">\n" +
                    "            <img class=\"qr-code\" src=\"https://img.vietqr.io/image/MB-970422920260705-compact2.png?amount={{AMOUNT_INT}}&addInfo={{APP_TRANS_ID}}&accountName=CONG%20TY%20MEDIBOOK\" alt=\"VietQR Code\">\n" +
                    "            <div class=\"qr-hint\">Sử dụng ứng dụng ngân hàng quét mã để thanh toán tự động</div>\n" +
                    "        </div>\n" +
                    "\n" +
                    "        <div class=\"info-box\">\n" +
                    "            <div class=\"info-row\">\n" +
                    "                <span class=\"info-label\">Ngân hàng:</span>\n" +
                    "                <span class=\"info-value\">MB Bank (Ngân hàng Quân Đội)</span>\n" +
                    "            </div>\n" +
                    "            <div class=\"info-row\">\n" +
                    "                <span class=\"info-label\">Số tài khoản:</span>\n" +
                    "                <span class=\"info-value\">9704 2292 0260 705</span>\n" +
                    "            </div>\n" +
                    "            <div class=\"info-row\">\n" +
                    "                <span class=\"info-label\">Tên thụ hưởng:</span>\n" +
                    "                <span class=\"info-value\">CONG TY CONG NGHE MEDIBOOK</span>\n" +
                    "            </div>\n" +
                    "            <div class=\"info-row\">\n" +
                    "                <span class=\"info-label\">Số tiền:</span>\n" +
                    "                <span class=\"info-value amount\">{{AMOUNT_FORMATTED}}</span>\n" +
                    "            </div>\n" +
                    "            <div class=\"info-row\">\n" +
                    "                <span class=\"info-label\">Nội dung chuyển khoản:</span>\n" +
                    "                <span class=\"info-value\" style=\"color:#00875a;font-family:monospace;font-size:13px;\">{{APP_TRANS_ID}}</span>\n" +
                    "            </div>\n" +
                    "        </div>\n" +
                    "\n" +
                    "        <button class=\"btn btn-success\" onclick=\"completePayment()\">Xác nhận đã chuyển khoản</button>\n" +
                    "        <button class=\"btn btn-cancel\" onclick=\"cancelPayment()\">Hủy bỏ giao dịch</button>\n" +
                    "    </div>\n" +
                    "    <div class=\"card success-box\" id=\"success-card\">\n" +
                    "        <div class=\"success-icon\">✓</div>\n" +
                    "        <h2>Thanh toán thành công!</h2>\n" +
                    "        <p class=\"subtitle\">Giao dịch đã được xác nhận trên hệ thống MediBook.</p>\n" +
                    "        <div style=\"height: 1px; background: #e5e7eb; margin: 20px 0;\"></div>\n" +
                    "        <p style=\"color: #6b7280; font-size: 14px;\">Bạn có thể đóng trang này để quay lại ứng dụng.</p>\n" +
                    "    </div>\n" +
                    "    <script>\n" +
                    "        function completePayment() {\n" +
                    "            fetch('/api/bookings/payment/mock-complete?app_trans_id={{APP_TRANS_ID}}')\n" +
                    "                .then(res => {\n" +
                    "                    document.getElementById('payment-card').style.display = 'none';\n" +
                    "                    document.getElementById('success-card').style.display = 'block';\n" +
                    "                })\n" +
                    "                .catch(err => alert('Lỗi kết nối server giả lập!'));\n" +
                    "        }\n" +
                    "        function cancelPayment() {\n" +
                    "            alert('Giao dịch đã bị hủy!');\n" +
                    "            window.close();\n" +
                    "        }\n" +
                    "    </script>\n" +
                    "</body>\n" +
                    "</html>";

            html = html.replace("{{AMOUNT_INT}}", String.valueOf((int) amountDouble))
                       .replace("{{APP_TRANS_ID}}", appTransId)
                       .replace("{{AMOUNT_FORMATTED}}", amountFormatted);
        } else {
            html = "<!DOCTYPE html>\n" +
                    "<html>\n" +
                    "<head>\n" +
                    "    <meta charset=\"UTF-8\">\n" +
                    "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n" +
                    "    <title>Cổng Thanh Toán Giả Lập ZaloPay - MediBook</title>\n" +
                    "    <style>\n" +
                    "        body { font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, sans-serif; background-color: #f3f4f6; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; padding: 16px; box-sizing: border-box; }\n" +
                    "        .card { background: white; border-radius: 20px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); padding: 32px; width: 100%; max-width: 400px; text-align: center; }\n" +
                    "        .logo { width: 100px; height: auto; margin-bottom: 24px; }\n" +
                    "        h2 { color: #1f2937; margin: 0 0 8px 0; font-size: 22px; font-weight: 700; }\n" +
                    "        .subtitle { color: #6b7280; font-size: 14px; margin-bottom: 24px; }\n" +
                    "        .divider { height: 1px; background: #e5e7eb; margin: 20px 0; }\n" +
                    "        .detail-row { display: flex; justify-content: space-between; margin-bottom: 12px; font-size: 14px; }\n" +
                    "        .detail-label { color: #6b7280; }\n" +
                    "        .detail-value { color: #111827; font-weight: 600; }\n" +
                    "        .amount { font-size: 24px; color: #00c853; font-weight: 800; margin: 20px 0; }\n" +
                    "        .btn { display: block; width: 100%; padding: 14px; border: none; border-radius: 12px; font-size: 16px; font-weight: 700; cursor: pointer; transition: background 0.2s; margin-top: 16px; }\n" +
                    "        .btn-success { background-color: #00c853; color: white; }\n" +
                    "        .btn-success:hover { background-color: #00a844; }\n" +
                    "        .btn-cancel { background-color: #f3f4f6; color: #4b5563; margin-top: 8px; }\n" +
                    "        .btn-cancel:hover { background-color: #e5e7eb; }\n" +
                    "        .success-box { display: none; }\n" +
                    "        .success-icon { font-size: 64px; color: #00c853; margin-bottom: 16px; }\n" +
                    "    </style>\n" +
                    "</head>\n" +
                    "<body>\n" +
                    "    <div class=\"card\" id=\"payment-card\">\n" +
                    "        <img class=\"logo\" src=\"https://upload.wikimedia.org/wikipedia/commons/0/07/ZaloPay_Logo.png\" alt=\"ZaloPay\">\n" +
                    "        <h2>ZaloPay Sandbox</h2>\n" +
                    "        <p class=\"subtitle\">CỔNG THANH TOÁN MOCK (GIẢ LẬP)</p>\n" +
                    "        <div class=\"divider\"></div>\n" +
                    "        <div class=\"detail-row\">\n" +
                    "            <span class=\"detail-label\">Mã giao dịch:</span>\n" +
                    "            <span class=\"detail-value\">" + appTransId + "</span>\n" +
                    "        </div>\n" +
                    "        <div class=\"detail-row\">\n" +
                    "            <span class=\"detail-label\">Dịch vụ:</span>\n" +
                    "            <span class=\"detail-value\">Đặt lịch khám bệnh</span>\n" +
                    "        </div>\n" +
                    "        <div class=\"amount\">" + amountFormatted + "</div>\n" +
                    "        <button class=\"btn btn-success\" onclick=\"completePayment()\">Xác nhận thanh toán</button>\n" +
                    "        <button class=\"btn btn-cancel\" onclick=\"cancelPayment()\">Hủy bỏ giao dịch</button>\n" +
                    "    </div>\n" +
                    "    <div class=\"card success-box\" id=\"success-card\">\n" +
                    "        <div class=\"success-icon\">✓</div>\n" +
                    "        <h2>Thanh toán thành công!</h2>\n" +
                    "        <p class=\"subtitle\">Giao dịch đã được xác nhận trên hệ thống MediBook.</p>\n" +
                    "        <div class=\"divider\"></div>\n" +
                    "        <p style=\"color: #6b7280; font-size: 14px;\">Bạn có thể đóng trang này để quay lại ứng dụng.</p>\n" +
                    "    </div>\n" +
                    "    <script>\n" +
                    "        function completePayment() {\n" +
                    "            fetch('/api/bookings/payment/mock-complete?app_trans_id=" + appTransId + "')\n" +
                    "                .then(res => {\n" +
                    "                    document.getElementById('payment-card').style.display = 'none';\n" +
                    "                    document.getElementById('success-card').style.display = 'block';\n" +
                    "                })\n" +
                    "                .catch(err => alert('Lỗi kết nối server giả lập!'));\n" +
                    "        }\n" +
                    "        function cancelPayment() {\n" +
                    "            alert('Giao dịch đã bị hủy!');\n" +
                    "            window.close();\n" +
                    "        }\n" +
                    "    </script>\n" +
                    "</body>\n" +
                    "</html>";
        }

        return ResponseEntity.ok()
                .header("Content-Type", "text/html; charset=utf-8")
                .body(html);
    }

    @GetMapping("/payment/mock-complete")
    public ResponseEntity<ApiResponse<String>> completeMockPayment(@RequestParam("app_trans_id") String appTransId) {
        bookingService.completeMockPayment(appTransId);
        return ResponseEntity.ok(ApiResponse.success("Thanh toan gia lap thanh cong", null));
    }
}
