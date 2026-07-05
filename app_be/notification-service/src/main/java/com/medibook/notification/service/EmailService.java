package com.medibook.notification.service;

import com.medibook.notification.dto.BookingCreatedEmailRequest;
import com.medibook.notification.dto.EmailVerificationEmailRequest;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username:}")
    private String mailUsername;

    @Value("${spring.mail.password:}")
    private String mailPassword;

    @Value("${notification.email.from-name:MediBook}")
    private String fromName;

    public void sendBookingCreatedConfirmation(BookingCreatedEmailRequest request) {
        if (request == null || !StringUtils.hasText(request.getPatientEmail())) {
            log.warn("Skip booking confirmation email because patient email is missing");
            return;
        }

        String subject = "Xác nhận đặt lịch khám - MediBook";
        String body = buildBookingCreatedBody(request);

        if (!isSmtpConfigured()) {
            log.warn("MAIL_USERNAME or MAIL_PASSWORD is not configured. Booking confirmation email is logged only.");
            logEmail(request.getPatientEmail(), subject, body);
            return;
        }

        // Run email sending asynchronously to prevent database transaction or HTTP hang
        java.util.concurrent.CompletableFuture.runAsync(() -> {
            try {
                MimeMessage message = mailSender.createMimeMessage();
                MimeMessageHelper helper = new MimeMessageHelper(message, StandardCharsets.UTF_8.name());
                helper.setTo(request.getPatientEmail());
                helper.setSubject(subject);
                helper.setText(body, true); // true sets Content-Type to text/html
                helper.setFrom(new InternetAddress(mailUsername, fromName, StandardCharsets.UTF_8.name()));

                mailSender.send(message);
                log.info("Async: Booking confirmation email sent to {}", request.getPatientEmail());
            } catch (Exception e) {
                log.error("Async: Failed to send booking confirmation email to {}: {}",
                        request.getPatientEmail(), e.getMessage(), e);
            }
        });
    }

    public void sendEmailVerificationCode(EmailVerificationEmailRequest request) {
        if (request == null || !StringUtils.hasText(request.getTo()) || !StringUtils.hasText(request.getCode())) {
            log.warn("Skip email verification because recipient or code is missing");
            return;
        }

        int expiresInMinutes = request.getExpiresInMinutes() != null ? request.getExpiresInMinutes() : 10;
        String subject = "Mã xác thực email MediBook";
        String body = buildEmailVerificationBody(request.getCode(), expiresInMinutes);

        if (!isSmtpConfigured()) {
            log.warn("MAIL_USERNAME or MAIL_PASSWORD is not configured. Cannot send email verification code to {}.",
                    request.getTo());
            throw new IllegalStateException("SMTP email is not configured. Set MAIL_USERNAME and MAIL_PASSWORD.");
        }

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, StandardCharsets.UTF_8.name());
            helper.setTo(request.getTo());
            helper.setSubject(subject);
            helper.setText(body, true); // true sets Content-Type to text/html
            helper.setFrom(new InternetAddress(mailUsername, fromName, StandardCharsets.UTF_8.name()));

            mailSender.send(message);
            log.info("Email verification code sent to {}", request.getTo());
        } catch (Exception e) {
            log.error("Failed to send email verification code to {}: {}",
                    request.getTo(), e.getMessage(), e);
            throw new IllegalStateException("Could not send email verification code", e);
        }
    }

    private String buildBookingCreatedBody(BookingCreatedEmailRequest request) {
        String patientName = defaultText(request.getPatientName(), "bạn");
        String doctorName = defaultText(request.getDoctorName(), "bác sĩ");
        String serviceName = defaultText(request.getServiceName(), "dịch vụ khám");
        String date = defaultText(request.getDate(), "chưa xác định");
        String startTime = defaultText(request.getStartTime(), "chưa xác định");
        String endTime = defaultText(request.getEndTime(), "");
        String timeRange = StringUtils.hasText(endTime) ? startTime + " - " + endTime : startTime;
        String notesHtml = StringUtils.hasText(request.getNotes())
                ? "<div style=\"margin-top: 16px; padding: 12px; background-color: #FEF3C7; border: 1px solid #FDE68A; border-radius: 8px; color: #92400E; font-size: 13px;\"><strong>Ghi chú từ bệnh nhân:</strong> " + request.getNotes() + "</div>"
                : "";

        return String.format("""
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Xác nhận lịch đặt khám - MediBook</title>
                    <style>
                        body {
                            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                            background-color: #F8FAFC;
                            margin: 0;
                            padding: 0;
                            -webkit-font-smoothing: antialiased;
                        }
                        .wrapper {
                            width: 100%%;
                            background-color: #F8FAFC;
                            padding: 40px 0;
                        }
                        .container {
                            max-width: 580px;
                            margin: 0 auto;
                            background-color: #ffffff;
                            border-radius: 16px;
                            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
                            overflow: hidden;
                            border: 1px solid #E2E8F0;
                        }
                        .header {
                            background-color: #297EFF;
                            padding: 32px 24px;
                            text-align: center;
                        }
                        .header h1 {
                            color: #ffffff;
                            font-size: 26px;
                            font-weight: 800;
                            margin: 0;
                            letter-spacing: 0.5px;
                        }
                        .content {
                            padding: 40px 32px;
                            color: #334155;
                            line-height: 1.6;
                        }
                        .content h2 {
                            color: #0F172A;
                            font-size: 20px;
                            font-weight: 700;
                            margin-top: 0;
                            margin-bottom: 8px;
                        }
                        .subtitle {
                            color: #64748B;
                            font-size: 14px;
                            margin-top: 0;
                            margin-bottom: 28px;
                        }
                        .info-card {
                            background-color: #F8FAFC;
                            border: 1px solid #E2E8F0;
                            border-radius: 12px;
                            padding: 24px;
                            margin-bottom: 28px;
                        }
                        .badge-status {
                            display: inline-block;
                            background-color: #EFF6FF;
                            color: #2563EB;
                            border: 1px solid #BFDBFE;
                            padding: 4px 10px;
                            border-radius: 6px;
                            font-weight: 700;
                            font-size: 12px;
                        }
                        .divider {
                            height: 1px;
                            background-color: #E2E8F0;
                            margin: 32px 0;
                        }
                        .footer {
                            background-color: #F1F5F9;
                            padding: 24px 32px;
                            text-align: center;
                            border-top: 1px solid #E2E8F0;
                        }
                        .footer p {
                            margin: 0;
                            font-size: 12px;
                            color: #64748B;
                            line-height: 1.5;
                        }
                        .footer a {
                            color: #297EFF;
                            text-decoration: none;
                            font-weight: 600;
                        }
                    </style>
                </head>
                <body>
                    <div class="wrapper">
                        <div class="container">
                            <div class="header">
                                <h1>MediBook</h1>
                            </div>
                            <div class="content">
                                <h2>Lịch hẹn của bạn đã được tiếp nhận!</h2>
                                <div class="subtitle">Xin chào %s, cảm ơn bạn đã đặt lịch khám qua MediBook. Dưới đây là thông tin chi tiết lịch hẹn của bạn:</div>
                                
                                <div class="info-card">
                                    <table style="width:100%%; border-collapse:collapse;">
                                        <tr style="border-bottom:1px solid #E2E8F0;">
                                            <td style="padding:10px 0; font-weight:600; color:#64748B; font-size:14px;">Mã lịch hẹn:</td>
                                            <td style="padding:10px 0; font-weight:700; color:#0F172A; font-size:14px; text-align:right;">%s</td>
                                        </tr>
                                        <tr style="border-bottom:1px solid #E2E8F0;">
                                            <td style="padding:10px 0; font-weight:600; color:#64748B; font-size:14px;">Bác sĩ:</td>
                                            <td style="padding:10px 0; font-weight:700; color:#0F172A; font-size:14px; text-align:right;">%s</td>
                                        </tr>
                                        <tr style="border-bottom:1px solid #E2E8F0;">
                                            <td style="padding:10px 0; font-weight:600; color:#64748B; font-size:14px;">Dịch vụ:</td>
                                            <td style="padding:10px 0; font-weight:700; color:#0F172A; font-size:14px; text-align:right;">%s</td>
                                        </tr>
                                        <tr style="border-bottom:1px solid #E2E8F0;">
                                            <td style="padding:10px 0; font-weight:600; color:#64748B; font-size:14px;">Ngày khám:</td>
                                            <td style="padding:10px 0; font-weight:700; color:#0F172A; font-size:14px; text-align:right;">%s</td>
                                        </tr>
                                        <tr style="border-bottom:1px solid #E2E8F0;">
                                            <td style="padding:10px 0; font-weight:600; color:#64748B; font-size:14px;">Thời gian:</td>
                                            <td style="padding:10px 0; font-weight:700; color:#0F172A; font-size:14px; text-align:right;">%s</td>
                                        </tr>
                                        <tr>
                                            <td style="padding:10px 0; font-weight:600; color:#64748B; font-size:14px;">Trạng thái:</td>
                                            <td style="padding:10px 0; text-align:right;"><span class="badge-status">Đang chờ xác nhận</span></td>
                                        </tr>
                                    </table>
                                </div>
                                
                                <div style="text-align: center; margin: 28px 0; padding: 20px; background-color: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 12px;">
                                    <div style="font-size: 12px; color: #64748B; font-weight: 700; margin-bottom: 12px; text-transform: uppercase; letter-spacing: 0.5px;">Mã QR Check-in Lịch Hẹn</div>
                                    <img src="https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=%s" width="150" height="150" alt="Booking QR Code" style="border: 4px solid #ffffff; box-shadow: 0 4px 10px rgba(0,0,0,0.08); border-radius: 8px; display: block; margin: 0 auto;" />
                                    <div style="font-size: 11px; color: #94A3B8; margin-top: 10px;">Dùng để check-in nhanh khi đến phòng khám</div>
                                </div>
                                
                                %s
                                
                                <p style="margin-top: 20px;">Vui lòng xuất trình mã QR này tại quầy tiếp đón của MediBook để làm thủ tục check-in nhanh chóng và tiện lợi.</p>
                                
                                <div class="divider"></div>
                                
                                <p style="margin-bottom:0;">Trân trọng,<br><strong>Đội ngũ MediBook</strong></p>
                            </div>
                            <div class="footer">
                                <p>© 2026 MediBook. Tất cả các quyền được bảo lưu.</p>
                                <p style="margin-top: 6px;">Cần trợ giúp? Liên hệ với chúng tôi tại <a href="mailto:support@medibook.vn">support@medibook.vn</a></p>
                            </div>
                        </div>
                    </div>
                </body>
                </html>
                """,
                patientName,
                request.getBookingId(),
                doctorName,
                serviceName,
                date,
                timeRange,
                request.getBookingId(), // QR Code Data
                notesHtml);
    }

    private String buildEmailVerificationBody(String code, int expiresInMinutes) {
        return String.format("""
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="utf-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Xác thực tài khoản MediBook</title>
                    <style>
                        body {
                            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                            background-color: #F8FAFC;
                            margin: 0;
                            padding: 0;
                            -webkit-font-smoothing: antialiased;
                        }
                        .wrapper {
                            width: 100%%;
                            background-color: #F8FAFC;
                            padding: 40px 0;
                        }
                        .container {
                            max-width: 580px;
                            margin: 0 auto;
                            background-color: #ffffff;
                            border-radius: 16px;
                            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
                            overflow: hidden;
                            border: 1px solid #E2E8F0;
                        }
                        .header {
                            background-color: #297EFF;
                            padding: 32px 24px;
                            text-align: center;
                        }
                        .header h1 {
                            color: #ffffff;
                            font-size: 26px;
                            font-weight: 800;
                            margin: 0;
                            letter-spacing: 0.5px;
                        }
                        .content {
                            padding: 40px 32px;
                            color: #334155;
                            line-height: 1.6;
                        }
                        .content h2 {
                            color: #0F172A;
                            font-size: 20px;
                            font-weight: 700;
                            margin-top: 0;
                            margin-bottom: 16px;
                        }
                        .content p {
                            margin-top: 0;
                            margin-bottom: 24px;
                            font-size: 15px;
                            color: #475569;
                        }
                        .code-box {
                            background-color: #EFF6FF;
                            border: 1px dashed #BFDBFE;
                            border-radius: 12px;
                            padding: 24px;
                            text-align: center;
                            margin-bottom: 28px;
                        }
                        .code-title {
                            font-size: 12px;
                            text-transform: uppercase;
                            letter-spacing: 1px;
                            color: #1E40AF;
                            font-weight: 700;
                            margin-bottom: 8px;
                        }
                        .code-value {
                            font-size: 38px;
                            font-weight: 800;
                            letter-spacing: 6px;
                            color: #297EFF;
                            margin: 0;
                        }
                        .badge {
                            display: inline-block;
                            background-color: #FFFBEB;
                            border: 1px solid #FDE68A;
                            color: #B45309;
                            padding: 6px 12px;
                            border-radius: 8px;
                            font-size: 13px;
                            font-weight: 600;
                            margin-bottom: 24px;
                        }
                        .footer {
                            background-color: #F1F5F9;
                            padding: 24px 32px;
                            text-align: center;
                            border-top: 1px solid #E2E8F0;
                        }
                        .footer p {
                            margin: 0;
                            font-size: 12px;
                            color: #64748B;
                            line-height: 1.5;
                        }
                        .footer a {
                            color: #297EFF;
                            text-decoration: none;
                            font-weight: 600;
                        }
                        .divider {
                            height: 1px;
                            background-color: #E2E8F0;
                            margin: 32px 0;
                        }
                    </style>
                </head>
                <body>
                    <div class="wrapper">
                        <div class="container">
                            <div class="header">
                                <h1>MediBook</h1>
                            </div>
                            <div class="content">
                                <h2>Xác thực địa chỉ Email của bạn</h2>
                                <p>Xin chào,</p>
                                <p>Cảm ơn bạn đã lựa chọn hệ thống chăm sóc sức khỏe thông minh <strong>MediBook</strong>. Để hoàn tất quy trình xác thực tài khoản, vui lòng sử dụng mã bảo mật dưới đây:</p>
                                
                                <div class="code-box">
                                    <div class="code-title">Mã xác thực của bạn</div>
                                    <div class="code-value">%s</div>
                                </div>
                                
                                <div style="text-align: center;">
                                    <div class="badge">Mã xác thực có hiệu lực trong %d phút</div>
                                </div>
                                
                                <p style="font-size: 13px; color: #94A3B8; margin-top: 12px;">Nếu bạn không yêu cầu đăng ký hoặc thực hiện hành động này trên MediBook, vui lòng bỏ qua và xóa email này an toàn.</p>
                                
                                <div class="divider"></div>
                                
                                <p style="margin-bottom: 0;">Trân trọng,<br><strong>Đội ngũ MediBook</strong></p>
                            </div>
                            <div class="footer">
                                <p>© 2026 MediBook. Tất cả các quyền được bảo lưu.</p>
                                <p style="margin-top: 6px;">Cần trợ giúp? Liên hệ với chúng tôi tại <a href="mailto:support@medibook.vn">support@medibook.vn</a></p>
                            </div>
                        </div>
                    </div>
                </body>
                </html>
                """, code, expiresInMinutes);
    }

    private boolean isSmtpConfigured() {
        return StringUtils.hasText(mailUsername) && StringUtils.hasText(mailPassword);
    }

    private String defaultText(String value, String fallback) {
        return StringUtils.hasText(value) ? value : fallback;
    }

    private void logEmail(String to, String subject, String body) {
        log.info("EMAIL LOG");
        log.info("To: {}", to);
        log.info("Subject: {}", subject);
        log.info("Body: {}", body);
    }
}
