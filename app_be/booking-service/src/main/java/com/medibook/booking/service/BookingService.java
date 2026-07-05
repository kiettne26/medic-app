/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  com.medibook.booking.dto.BookingCreatedEmailRequest
 *  com.medibook.booking.dto.BookingDto
 *  com.medibook.booking.dto.BookingDto$TimeSlotDto
 *  com.medibook.booking.dto.BookingStatsDto
 *  com.medibook.booking.dto.BookingStatusNotificationRequest
 *  com.medibook.booking.dto.CancelBookingRequest
 *  com.medibook.booking.dto.CreateBookingRequest
 *  com.medibook.booking.dto.InitiatePaymentRequest
 *  com.medibook.booking.dto.PaymentInitDto
 *  com.medibook.booking.dto.TimeSlotDto
 *  com.medibook.booking.dto.ZaloPayCallbackRequest
 *  com.medibook.booking.dto.ZaloPayCallbackResponse
 *  com.medibook.booking.entity.Booking
 *  com.medibook.booking.entity.BookingStatusHistory
 *  com.medibook.booking.entity.TimeSlot
 *  com.medibook.booking.repository.BookingRepository
 *  com.medibook.booking.repository.BookingStatusHistoryRepository
 *  com.medibook.booking.repository.TimeSlotRepository
 *  com.medibook.booking.service.BookingService
 *  com.medibook.booking.service.BookingService$PatientContact
 *  com.medibook.booking.service.NotificationClient
 *  com.medibook.booking.service.SlotNotificationService
 *  com.medibook.booking.service.ZaloPayService
 *  com.medibook.common.enums.BookingStatus
 *  com.medibook.common.enums.PaymentMethod
 *  com.medibook.common.enums.PaymentStatus
 *  com.medibook.common.enums.SlotStatus
 *  com.medibook.common.exception.BadRequestException
 *  com.medibook.common.exception.ResourceNotFoundException
 *  com.medibook.common.exception.SlotNotAvailableException
 *  lombok.Generated
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 *  org.springframework.dao.EmptyResultDataAccessException
 *  org.springframework.data.domain.Page
 *  org.springframework.data.domain.Pageable
 *  org.springframework.jdbc.core.JdbcTemplate
 *  org.springframework.scheduling.annotation.Scheduled
 *  org.springframework.stereotype.Service
 *  org.springframework.transaction.annotation.Isolation
 *  org.springframework.transaction.annotation.Transactional
 *  org.springframework.transaction.support.TransactionSynchronization
 *  org.springframework.transaction.support.TransactionSynchronizationManager
 */
package com.medibook.booking.service;

import com.medibook.booking.dto.BookingCreatedEmailRequest;
import com.medibook.booking.dto.BookingDto;
import com.medibook.booking.dto.BookingStatsDto;
import com.medibook.booking.dto.BookingStatusNotificationRequest;
import com.medibook.booking.dto.CancelBookingRequest;
import com.medibook.booking.dto.CreateBookingRequest;
import com.medibook.booking.dto.InitiatePaymentRequest;
import com.medibook.booking.dto.PaymentInitDto;
import com.medibook.booking.dto.TimeSlotDto;
import com.medibook.booking.dto.ZaloPayCallbackRequest;
import com.medibook.booking.dto.ZaloPayCallbackResponse;
import com.medibook.booking.entity.Booking;
import com.medibook.booking.entity.BookingStatusHistory;
import com.medibook.booking.entity.TimeSlot;
import com.medibook.booking.repository.BookingRepository;
import com.medibook.booking.repository.BookingStatusHistoryRepository;
import com.medibook.booking.repository.TimeSlotRepository;
import com.medibook.booking.service.BookingService;
import com.medibook.booking.service.NotificationClient;
import com.medibook.booking.service.SlotNotificationService;
import com.medibook.booking.service.ZaloPayService;
import com.medibook.common.enums.BookingStatus;
import com.medibook.common.enums.PaymentMethod;
import com.medibook.common.enums.PaymentStatus;
import com.medibook.common.enums.SlotStatus;
import com.medibook.common.exception.BadRequestException;
import com.medibook.common.exception.ResourceNotFoundException;
import com.medibook.common.exception.SlotNotAvailableException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import lombok.Generated;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

@Service
public class BookingService {
    @Generated
    private static final Logger log = LoggerFactory.getLogger(BookingService.class);
    private static final long PAYMENT_HOLD_MINUTES = 15L;
    private static final String PAYMENT_TIMEOUT_REASON = "T\u1ef1 \u0111\u1ed9ng h\u1ee7y do qu\u00e1 h\u1ea1n thanh to\u00e1n 15 ph\u00fat";
    private final BookingRepository bookingRepository;
    private final TimeSlotRepository timeSlotRepository;
    private final BookingStatusHistoryRepository statusHistoryRepository;
    private final JdbcTemplate jdbcTemplate;
    private final SlotNotificationService slotNotificationService;
    private final NotificationClient notificationClient;
    private final ZaloPayService zaloPayService;

    private void validatePatientBeforeBooking(UUID patientId) {
        List rows = this.jdbcTemplate.queryForList("SELECT\n    u.email,\n    COALESCE(u.email_verified, false) AS email_verified,\n    p.full_name,\n    p.phone\nFROM users u\nLEFT JOIN profiles p ON p.user_id = u.id\nWHERE u.id = ?\nLIMIT 1\n", new Object[]{patientId});
        if (rows.isEmpty()) {
            throw new BadRequestException("Kh\u00f4ng t\u00ecm th\u1ea5y t\u00e0i kho\u1ea3n b\u1ec7nh nh\u00e2n.");
        }
        Map patient = (Map)rows.get(0);
        if (!(this.hasText(patient.get("full_name")) && this.hasText(patient.get("phone")) && this.hasText(patient.get("email")))) {
            throw new BadRequestException("Vui l\u00f2ng c\u1eadp nh\u1eadt \u0111\u1ea7y \u0111\u1ee7 h\u1ecd t\u00ean, s\u1ed1 \u0111i\u1ec7n tho\u1ea1i v\u00e0 email tr\u01b0\u1edbc khi \u0111\u1eb7t l\u1ecbch.");
        }
        if (!this.asBoolean(patient.get("email_verified"))) {
            throw new BadRequestException("Vui l\u00f2ng x\u00e1c th\u1ef1c email tr\u01b0\u1edbc khi \u0111\u1eb7t l\u1ecbch.");
        }
    }

    private boolean hasText(Object value) {
        return value != null && !value.toString().trim().isEmpty();
    }

    private boolean asBoolean(Object value) {
        if (value instanceof Boolean) {
            Boolean bool = (Boolean)value;
            return bool;
        }
        return value != null && Boolean.parseBoolean(value.toString());
    }

    private UUID findDoctorIdByUserId(UUID userId) {
        try {
            return (UUID)this.jdbcTemplate.queryForObject("SELECT id FROM doctors WHERE user_id = ?", UUID.class, new Object[]{userId});
        }
        catch (Exception e) {
            log.error("Could not find doctorId for userId: {}", (Object)userId);
            return null;
        }
    }

    private BigDecimal getServicePrice(UUID serviceId) {
        try {
            BigDecimal price = (BigDecimal)this.jdbcTemplate.queryForObject("SELECT price FROM medical_services WHERE id = ?", BigDecimal.class, new Object[]{serviceId});
            return price != null ? price : BigDecimal.ZERO;
        }
        catch (EmptyResultDataAccessException e) {
            throw new ResourceNotFoundException("MedicalService", "id", (Object)serviceId);
        }
    }

    private String getServiceName(UUID serviceId) {
        try {
            String name = (String)this.jdbcTemplate.queryForObject("SELECT name FROM medical_services WHERE id = ?", String.class, new Object[]{serviceId});
            return this.hasText((Object)name) ? name : "Dich vu kham";
        }
        catch (EmptyResultDataAccessException e) {
            throw new ResourceNotFoundException("MedicalService", "id", (Object)serviceId);
        }
    }

    private String buildPaymentReference(Booking booking, PaymentMethod method) {
        String bookingCode = booking.getId().toString().substring(0, 8).toUpperCase();
        long timestamp = System.currentTimeMillis();
        return method.name() + "-" + bookingCode + "-" + timestamp;
    }

    @Transactional(isolation=Isolation.SERIALIZABLE)
    public BookingDto createBooking(UUID patientId, CreateBookingRequest request) {
        log.info("Creating booking for patient: {}, slot: {}", (Object)patientId, (Object)request.getTimeSlotId());
        this.validatePatientBeforeBooking(patientId);
        TimeSlot slot = this.timeSlotRepository.findByIdWithLock(request.getTimeSlotId()).orElseThrow(() -> new ResourceNotFoundException("TimeSlot", "id", request.getTimeSlotId()));
        if (!slot.getIsAvailable().booleanValue()) {
            log.warn("Slot {} already booked, rejecting request from patient {}", (Object)slot.getId(), (Object)patientId);
            throw new SlotNotAvailableException();
        }
        if (!slot.getDoctorId().equals(request.getDoctorId())) {
            throw new BadRequestException("TimeSlot kh\u00f4ng thu\u1ed9c v\u1ec1 b\u00e1c s\u0129 \u0111\u00e3 ch\u1ecdn");
        }
        slot.setIsAvailable(Boolean.valueOf(false));
        this.timeSlotRepository.save(slot);
        BigDecimal totalAmount = this.getServicePrice(request.getServiceId());
        Booking booking = Booking.builder().patientId(patientId).doctorId(request.getDoctorId()).serviceId(request.getServiceId()).timeSlot(slot).status(BookingStatus.PENDING).totalAmount(totalAmount).paymentStatus(PaymentStatus.UNPAID).notes(request.getNotes()).build();
        booking = this.bookingRepository.save(booking);
        this.saveStatusHistory(booking, null, BookingStatus.PENDING, patientId, "\u0110\u1eb7t l\u1ecbch m\u1edbi");
        log.info("Booking created successfully: {}", (Object)booking.getId());
        BookingDto dto = this.toDtoRaw(booking);
        this.enrichBookings(List.of(dto));
        // Xóa gửi email khi đặt lịch mới ở trạng thái PENDING (chờ thanh toán thành công mới gửi)
        // this.sendBookingCreatedEmailAfterCommit(dto);
        return dto;
    }

    @Transactional
    public PaymentInitDto initiatePayment(UUID bookingId, UUID patientId, InitiatePaymentRequest request) {
        Booking booking = this.bookingRepository.findById(bookingId).orElseThrow(() -> new ResourceNotFoundException("Booking", "id", bookingId));
        if (!booking.getPatientId().equals(patientId)) {
            throw new BadRequestException("Ban khong co quyen thanh toan lich nay");
        }
        if (booking.getStatus() == BookingStatus.CANCELED || booking.getStatus() == BookingStatus.CANCELLED) {
            throw new BadRequestException("Khong the thanh toan lich da huy");
        }
        if ((booking = this.refreshProviderPaymentStatus(booking, patientId, "Thanh toan thanh cong")).getPaymentStatus() == PaymentStatus.PAID) {
            if (booking.getStatus() == BookingStatus.PENDING) {
                booking = this.markBookingPaidAndConfirm(booking, patientId, "Thanh toan thanh cong");
            }
            return PaymentInitDto.builder().bookingId(booking.getId()).amount(booking.getTotalAmount()).paymentMethod(booking.getPaymentMethod()).paymentStatus(PaymentStatus.PAID).provider("ZALOPAY").appTransId(booking.getPaymentReference()).message("Lich hen da duoc thanh toan").build();
        }
        if (this.expirePaymentHoldIfNeeded(booking)) {
            throw new BadRequestException("Thoi gian giu cho 15 phut da het. Lich da duoc huy tu dong, vui long chon khung gio khac.");
        }
        PaymentMethod method = request.getPaymentMethod();
        if (booking.getTotalAmount() == null) {
            booking.setTotalAmount(this.getServicePrice(booking.getServiceId()));
        }
        PaymentInitDto init = this.zaloPayService.createOrder(booking, this.getServiceName(booking.getServiceId()), method);
        booking.setPaymentMethod(method);
        booking.setPaymentStatus(PaymentStatus.PENDING);
        booking.setPaymentReference(init.getAppTransId());
        booking.setPaidAt(null);
        this.bookingRepository.save(booking);
        return init;
    }

    @Transactional
    public BookingDto refreshPaymentStatus(UUID bookingId, UUID patientId) {
        Booking booking = this.bookingRepository.findById(bookingId).orElseThrow(() -> new ResourceNotFoundException("Booking", "id", bookingId));
        if (!booking.getPatientId().equals(patientId)) {
            throw new BadRequestException("Ban khong co quyen xem thanh toan lich nay");
        }
        if ((booking = this.refreshProviderPaymentStatus(booking, patientId, "Thanh toan thanh cong")).getPaymentStatus() != PaymentStatus.PAID && this.expirePaymentHoldIfNeeded(booking)) {
            booking = this.bookingRepository.findById(bookingId).orElseThrow(() -> new ResourceNotFoundException("Booking", "id", bookingId));
        }
        BookingDto dto = this.toDtoRaw(booking);
        this.enrichBookings(List.of(dto));
        return dto;
    }

    @Transactional
    public ZaloPayCallbackResponse handleZaloPayCallback(ZaloPayCallbackRequest request) {
        BigDecimal paidAmount;
        if (!this.zaloPayService.isValidCallback(request)) {
            return ZaloPayCallbackResponse.builder().returnCode(-1).returnMessage("mac not equal").build();
        }
        Map data = this.zaloPayService.parseCallbackData(request.getData());
        String appTransId = this.asString(data.get("app_trans_id"));
        if (!this.hasText((Object)appTransId)) {
            return ZaloPayCallbackResponse.builder().returnCode(0).returnMessage("missing app_trans_id").build();
        }
        Booking booking = this.bookingRepository.findByPaymentReference(appTransId).orElse(null);
        if (booking == null) {
            return ZaloPayCallbackResponse.builder().returnCode(0).returnMessage("booking not found").build();
        }
        BigDecimal bigDecimal = paidAmount = data.get("amount") != null ? new BigDecimal(data.get("amount").toString()) : BigDecimal.ZERO;
        if (booking.getTotalAmount() != null && booking.getTotalAmount().setScale(0, RoundingMode.HALF_UP).compareTo(paidAmount) != 0) {
            return ZaloPayCallbackResponse.builder().returnCode(0).returnMessage("amount mismatch").build();
        }
        this.markBookingPaidAndConfirm(booking, booking.getPatientId(), "Thanh toan ZaloPay thanh cong");
        return ZaloPayCallbackResponse.builder().returnCode(1).returnMessage("success").build();
    }

    @Transactional
    public BookingDto confirmBooking(UUID bookingId, UUID userId) {
        Booking booking = this.bookingRepository.findById(bookingId).orElseThrow(() -> new ResourceNotFoundException("Booking", "id", bookingId));
        UUID doctorId = this.findDoctorIdByUserId(userId);
        if (doctorId == null || !booking.getDoctorId().equals(doctorId)) {
            throw new BadRequestException("B\u1ea1n kh\u00f4ng c\u00f3 quy\u1ec1n x\u00e1c nh\u1eadn l\u1ecbch n\u00e0y");
        }
        if (this.expirePaymentHoldIfNeeded(booking)) {
            throw new BadRequestException("Lich da tu dong huy do qua han thanh toan 15 phut");
        }
        if (booking.getPaymentStatus() != PaymentStatus.PAID) {
            throw new BadRequestException("Chi co the xac nhan lich da thanh toan");
        }
        if (booking.getStatus() != BookingStatus.PENDING) {
            throw new BadRequestException("Ch\u1ec9 c\u00f3 th\u1ec3 x\u00e1c nh\u1eadn l\u1ecbch \u0111ang ch\u1edd");
        }
        BookingStatus oldStatus = booking.getStatus();
        booking.setStatus(BookingStatus.CONFIRMED);
        booking = this.bookingRepository.save(booking);
        this.saveStatusHistory(booking, oldStatus, BookingStatus.CONFIRMED, userId, "B\u00e1c s\u0129 x\u00e1c nh\u1eadn");
        log.info("Booking {} confirmed by doctor {}", (Object)bookingId, (Object)userId);
        BookingDto dto = this.toDtoRaw(booking);
        this.enrichBookings(List.of(dto));
        this.sendBookingConfirmedNotificationAfterCommit(dto);
        return dto;
    }

    @Transactional
    public BookingDto completeBooking(UUID bookingId, UUID userId, String doctorNotes) {
        Booking booking = this.bookingRepository.findById(bookingId).orElseThrow(() -> new ResourceNotFoundException("Booking", "id", bookingId));
        UUID doctorId = this.findDoctorIdByUserId(userId);
        if (doctorId == null || !booking.getDoctorId().equals(doctorId)) {
            throw new BadRequestException("B\u1ea1n kh\u00f4ng c\u00f3 quy\u1ec1n ho\u00e0n th\u00e0nh l\u1ecbch n\u00e0y");
        }
        if (booking.getStatus() != BookingStatus.CONFIRMED) {
            throw new BadRequestException("Ch\u1ec9 c\u00f3 th\u1ec3 ho\u00e0n th\u00e0nh l\u1ecbch \u0111\u00e3 x\u00e1c nh\u1eadn");
        }
        BookingStatus oldStatus = booking.getStatus();
        booking.setStatus(BookingStatus.COMPLETED);
        booking.setDoctorNotes(doctorNotes);
        booking = this.bookingRepository.save(booking);
        this.saveStatusHistory(booking, oldStatus, BookingStatus.COMPLETED, userId, "Ho\u00e0n th\u00e0nh kh\u00e1m");
        log.info("Booking {} completed by doctor {}", (Object)bookingId, (Object)userId);
        BookingDto dto = this.toDtoRaw(booking);
        this.enrichBookings(List.of(dto));
        return dto;
    }

    @Transactional
    public BookingDto cancelBooking(UUID bookingId, UUID userId, CancelBookingRequest request) {
        boolean isDoctor;
        Booking booking = this.bookingRepository.findById(bookingId).orElseThrow(() -> new ResourceNotFoundException("Booking", "id", bookingId));
        boolean isPatient = booking.getPatientId().equals(userId);
        UUID doctorId = this.findDoctorIdByUserId(userId);
        boolean bl = isDoctor = doctorId != null && booking.getDoctorId().equals(doctorId);
        if (!isPatient && !isDoctor) {
            throw new BadRequestException("B\u1ea1n kh\u00f4ng c\u00f3 quy\u1ec1n h\u1ee7y l\u1ecbch n\u00e0y");
        }
        if (booking.getStatus() == BookingStatus.COMPLETED || booking.getStatus() == BookingStatus.CANCELED) {
            throw new BadRequestException("Kh\u00f4ng th\u1ec3 h\u1ee7y l\u1ecbch \u0111\u00e3 ho\u00e0n th\u00e0nh ho\u1eb7c \u0111\u00e3 h\u1ee7y");
        }
        BookingStatus oldStatus = booking.getStatus();
        booking.setStatus(BookingStatus.CANCELED);
        booking.setCancellationReason(request.getReason());
        booking.setCancelledBy(userId);
        TimeSlot slot = booking.getTimeSlot();
        slot.setIsAvailable(Boolean.valueOf(true));
        this.timeSlotRepository.save(slot);
        booking = this.bookingRepository.save(booking);
        String reason = isPatient ? "B\u1ec7nh nh\u00e2n h\u1ee7y" : "B\u00e1c s\u0129 h\u1ee7y";
        this.saveStatusHistory(booking, oldStatus, BookingStatus.CANCELED, userId, reason + ": " + request.getReason());
        log.info("Booking {} cancelled by user {}", (Object)bookingId, (Object)userId);
        BookingDto dto = this.toDtoRaw(booking);
        this.enrichBookings(List.of(dto));
        this.sendBookingCancelledNotificationAfterCommit(dto, request.getReason());
        return dto;
    }

    @Transactional(readOnly=true)
    public BookingDto getBookingById(UUID id) {
        Booking booking = this.bookingRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Booking", "id", id));
        BookingDto dto = this.toDtoRaw(booking);
        this.enrichBookings(List.of(dto));
        return dto;
    }

    @Transactional(readOnly=true)
    public Page<BookingDto> getPatientBookings(UUID patientId, Pageable pageable) {
        Page dtos = this.bookingRepository.findByPatientIdOrderByCreatedAtDesc(patientId, pageable).map(arg_0 -> this.toDtoRaw(arg_0));
        this.enrichBookings(dtos.getContent());
        return dtos;
    }

    @Transactional(readOnly=true)
    public Page<BookingDto> getDoctorBookings(UUID userId, Pageable pageable) {
        UUID doctorId = this.findDoctorIdByUserId(userId);
        if (doctorId == null) {
            return Page.empty();
        }
        Page dtos = this.bookingRepository.findByDoctorIdOrderByCreatedAtDesc(doctorId, pageable).map(arg_0 -> this.toDtoRaw(arg_0));
        this.enrichBookings(dtos.getContent());
        return dtos;
    }

    @Transactional(readOnly=true)
    public List<BookingDto> getDoctorBookingsByDate(UUID userId, LocalDate date) {
        UUID doctorId = this.findDoctorIdByUserId(userId);
        if (doctorId == null) {
            return List.of();
        }
        List<BookingDto> dtos = this.bookingRepository.findByDoctorIdAndDate(doctorId, date).stream().map(arg_0 -> this.toDtoRaw(arg_0)).collect(Collectors.toList());
        this.enrichBookings(dtos);
        return dtos;
    }

    @Transactional(readOnly=true)
    public Page<BookingDto> getAllBookings(BookingStatus status, Pageable pageable) {
        Page dtos = status != null ? this.bookingRepository.findByStatusOrderByCreatedAtDesc(status, pageable).map(arg_0 -> this.toDtoRaw(arg_0)) : this.bookingRepository.findAll(pageable).map(arg_0 -> this.toDtoRaw(arg_0));
        this.enrichBookings(dtos.getContent());
        return dtos;
    }

    public List<TimeSlotDto> getAvailableSlots(UUID doctorId, LocalDate date) {
        return this.timeSlotRepository.findApprovedAvailableSlotsByDoctorAndDate(doctorId, date).stream().map(arg_0 -> this.toSlotDto(arg_0)).collect(Collectors.toList());
    }

    public List<TimeSlotDto> getDoctorSlotsForWeek(UUID userId, LocalDate startDate, LocalDate endDate) {
        UUID doctorId;
        UUID uUID = doctorId = userId != null ? this.findDoctorIdByUserId(userId) : null;
        if (doctorId == null) {
            log.warn("Cannot find doctorId for userId: {}, returning empty list", (Object)userId);
            return List.of();
        }
        return this.timeSlotRepository.findByDoctorIdAndDateBetween(doctorId, startDate, endDate).stream().map(arg_0 -> this.toSlotDto(arg_0)).collect(Collectors.toList());
    }

    @Transactional
    public TimeSlotDto createTimeSlot(UUID userId, LocalDate date, String startTime, String endTime) {
        UUID doctorId;
        UUID uUID = doctorId = userId != null ? this.findDoctorIdByUserId(userId) : null;
        if (doctorId == null) {
            throw new BadRequestException("Doctor not found for user: " + String.valueOf(userId));
        }
        if (((String)startTime).length() == 5) {
            startTime = (String)startTime + ":00";
        }
        if (((String)endTime).length() == 5) {
            endTime = (String)endTime + ":00";
        }
        LocalTime start = LocalTime.parse((CharSequence)startTime);
        LocalTime end = LocalTime.parse((CharSequence)endTime);
        LocalTime minTime = LocalTime.of(7, 0);
        LocalTime maxTime = LocalTime.of(17, 0);
        if (start.isBefore(minTime) || end.isAfter(maxTime)) {
            throw new BadRequestException("Khung gi\u1edd ph\u1ea3i trong kho\u1ea3ng 07:00 - 17:00");
        }
        if (!end.isAfter(start)) {
            throw new BadRequestException("Gi\u1edd k\u1ebft th\u00fac ph\u1ea3i sau gi\u1edd b\u1eaft \u0111\u1ea7u");
        }
        List<TimeSlot> existingSlots = this.timeSlotRepository.findByDoctorIdAndDateBetween(doctorId, date, date);
        for (TimeSlot existing : existingSlots) {
            if (start.isBefore(existing.getEndTime()) && end.isAfter(existing.getStartTime())) {
                throw new BadRequestException("Khung gi\u1edd b\u1ecb tr\u00f9ng v\u1edbi khung gi\u1edd \u0111\u00e3 c\u00f3");
            }
        }
        TimeSlot slot = new TimeSlot();
        slot.setDoctorId(doctorId);
        slot.setDate(date);
        slot.setStartTime(start);
        slot.setEndTime(end);
        slot.setIsAvailable(Boolean.valueOf(true));
        slot.setCreatedAt(LocalDateTime.now());
        slot.setUpdatedAt(LocalDateTime.now());
        slot.setVersion(Long.valueOf(0L));
        TimeSlot saved = this.timeSlotRepository.save(slot);
        TimeSlotDto slotDto = this.toSlotDto(saved);
        this.slotNotificationService.notifyNewPendingSlot(slotDto);
        return slotDto;
    }

    @Transactional
    public void deleteTimeSlot(UUID slotId, UUID userId) {
        UUID doctorId;
        TimeSlot slot = this.timeSlotRepository.findById(slotId).orElseThrow(() -> new ResourceNotFoundException("TimeSlot", "id", slotId));
        doctorId = userId != null ? this.findDoctorIdByUserId(userId) : null;
        if (doctorId == null || !slot.getDoctorId().equals(doctorId)) {
            throw new BadRequestException("You don't have permission to delete this slot");
        }
        if (!slot.getIsAvailable().booleanValue()) {
            throw new BadRequestException("Cannot delete booked slot");
        }
        this.timeSlotRepository.delete(slot);
    }

    @Scheduled(fixedDelay=60000L)
    @Transactional
    public void cancelExpiredPaymentHolds() {
        LocalDateTime expiresBefore = LocalDateTime.now().minusMinutes(15L);
        List<Booking> expiredBookings = this.bookingRepository.findExpiredPaymentHolds(BookingStatus.PENDING, PaymentStatus.PAID, expiresBefore);
        for (Booking booking : expiredBookings) {
            try {
                Booking latest = this.refreshProviderPaymentStatus(booking, booking.getPatientId(), "Thanh toan thanh cong");
                if (latest.getPaymentStatus() == PaymentStatus.PAID) continue;
                this.cancelExpiredPaymentHold(latest);
            }
            catch (Exception e) {
                log.warn("Could not process expired payment hold {}: {}", (Object)booking.getId(), (Object)e.getMessage());
            }
        }
    }

    private Booking refreshProviderPaymentStatus(Booking booking, UUID changedBy, String confirmReason) {
        if (booking.getPaymentStatus() == PaymentStatus.PENDING && this.hasText((Object)booking.getPaymentReference())) {
            PaymentStatus status = this.zaloPayService.queryOrderStatus(booking.getPaymentReference());
            if (status == PaymentStatus.PAID) {
                return this.markBookingPaidAndConfirm(booking, changedBy, confirmReason);
            }
            if (status == PaymentStatus.FAILED) {
                booking.setPaymentStatus(PaymentStatus.FAILED);
                return this.bookingRepository.save(booking);
            }
        }
        return booking;
    }

    private boolean expirePaymentHoldIfNeeded(Booking booking) {
        if (!this.isPaymentHoldExpired(booking)) {
            return false;
        }
        this.cancelExpiredPaymentHold(booking);
        return true;
    }

    private boolean isPaymentHoldExpired(Booking booking) {
        if (booking == null || booking.getStatus() != BookingStatus.PENDING || booking.getPaymentStatus() == PaymentStatus.PAID || booking.getCreatedAt() == null) {
            return false;
        }
        LocalDateTime deadline = booking.getCreatedAt().plusMinutes(15L);
        return !deadline.isAfter(LocalDateTime.now());
    }

    private Booking cancelExpiredPaymentHold(Booking booking) {
        if (booking.getStatus() != BookingStatus.PENDING || booking.getPaymentStatus() == PaymentStatus.PAID) {
            return booking;
        }
        BookingStatus oldStatus = booking.getStatus();
        booking.setStatus(BookingStatus.CANCELED);
        booking.setPaymentStatus(PaymentStatus.FAILED);
        booking.setCancellationReason(PAYMENT_TIMEOUT_REASON);
        booking.setCancelledBy(null);
        TimeSlot slot = booking.getTimeSlot();
        if (slot != null && !Boolean.TRUE.equals(slot.getIsAvailable())) {
            slot.setIsAvailable(Boolean.valueOf(true));
            this.timeSlotRepository.save(slot);
        }
        Booking saved = this.bookingRepository.save(booking);
        this.saveStatusHistory(saved, oldStatus, BookingStatus.CANCELED, null, PAYMENT_TIMEOUT_REASON);
        log.info("Booking {} auto-cancelled because payment hold expired", (Object)saved.getId());
        BookingDto dto = this.toDtoRaw(saved);
        this.enrichBookings(List.of(dto));
        this.sendBookingCancelledNotificationAfterCommit(dto, PAYMENT_TIMEOUT_REASON);
        return saved;
    }

    private Booking markBookingPaidAndConfirm(Booking booking, UUID changedBy, String reason) {
        BookingStatus oldStatus = booking.getStatus();
        boolean shouldConfirm = booking.getStatus() == BookingStatus.PENDING;
        booking.setPaymentStatus(PaymentStatus.PAID);
        if (booking.getPaidAt() == null) {
            booking.setPaidAt(LocalDateTime.now());
        }
        if (shouldConfirm) {
            booking.setStatus(BookingStatus.CONFIRMED);
        }
        Booking saved = this.bookingRepository.save(booking);
        if (shouldConfirm) {
            this.saveStatusHistory(saved, oldStatus, BookingStatus.CONFIRMED, changedBy, reason);
            BookingDto dto = this.toDtoRaw(saved);
            this.enrichBookings(List.of(dto));
            this.sendBookingConfirmedNotificationAfterCommit(dto);
            // Gửi email xác nhận đặt lịch thành công sau khi đã thanh toán thành công
            this.sendBookingCreatedEmailAfterCommit(dto);
        }
        return saved;
    }

    private void sendBookingCreatedEmailAfterCommit(BookingDto dto) {
        BookingCreatedEmailRequest emailRequest = this.buildBookingCreatedEmailRequest(dto);
        if (emailRequest == null) {
            return;
        }
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    CompletableFuture.runAsync(() -> notificationClient.sendBookingCreatedEmail(emailRequest));
                }
            });
            return;
        }
        CompletableFuture.runAsync(() -> this.notificationClient.sendBookingCreatedEmail(emailRequest));
    }

    private void sendBookingConfirmedNotificationAfterCommit(BookingDto dto) {
        BookingStatusNotificationRequest request = this.buildBookingStatusNotificationRequest(dto, null);
        if (request == null) {
            return;
        }
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    CompletableFuture.runAsync(() -> notificationClient.sendBookingConfirmedNotification(request));
                }
            });
            return;
        }
        CompletableFuture.runAsync(() -> this.notificationClient.sendBookingConfirmedNotification(request));
    }

    private void sendBookingCancelledNotificationAfterCommit(BookingDto dto, String reason) {
        BookingStatusNotificationRequest request = this.buildBookingStatusNotificationRequest(dto, reason);
        if (request == null) {
            return;
        }
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    CompletableFuture.runAsync(() -> notificationClient.sendBookingCancelledNotification(request));
                }
            });
            return;
        }
        CompletableFuture.runAsync(() -> this.notificationClient.sendBookingCancelledNotification(request));
    }

    private BookingCreatedEmailRequest buildBookingCreatedEmailRequest(BookingDto dto) {
        if (dto == null || dto.getPatientId() == null || dto.getTimeSlot() == null) {
            return null;
        }
        PatientContact patientContact = this.findPatientContact(dto.getPatientId());
        if (patientContact == null || patientContact.email() == null || patientContact.email().isBlank()) {
            log.warn("Cannot send booking confirmation email because patient {} has no email", (Object)dto.getPatientId());
            return null;
        }
        BookingDto.TimeSlotDto slot = dto.getTimeSlot();
        return BookingCreatedEmailRequest.builder().patientId(dto.getPatientId()).bookingId(dto.getId()).patientEmail(patientContact.email()).patientName(this.firstNonBlank(new String[]{dto.getPatientName(), patientContact.fullName()})).doctorName(this.firstNonBlank(new String[]{dto.getDoctorName(), "b\u00e1c s\u0129"})).serviceName(this.firstNonBlank(new String[]{dto.getServiceName(), "d\u1ecbch v\u1ee5 kh\u00e1m"})).date(slot.getDate() != null ? slot.getDate().toString() : null).startTime(slot.getStartTime() != null ? slot.getStartTime().toString() : null).endTime(slot.getEndTime() != null ? slot.getEndTime().toString() : null).notes(dto.getNotes()).build();
    }

    private BookingStatusNotificationRequest buildBookingStatusNotificationRequest(BookingDto dto, String reason) {
        if (dto == null || dto.getPatientId() == null || dto.getId() == null || dto.getTimeSlot() == null) {
            return null;
        }
        BookingDto.TimeSlotDto slot = dto.getTimeSlot();
        return BookingStatusNotificationRequest.builder().patientId(dto.getPatientId()).bookingId(dto.getId()).doctorName(this.firstNonBlank(new String[]{dto.getDoctorName(), "b\u00e1c s\u0129"})).date(slot.getDate() != null ? slot.getDate().toString() : null).startTime(slot.getStartTime() != null ? slot.getStartTime().toString() : null).endTime(slot.getEndTime() != null ? slot.getEndTime().toString() : null).reason(this.firstNonBlank(new String[]{reason, dto.getCancellationReason()})).build();
    }

    private PatientContact findPatientContact(UUID patientId) {
        try {
            Map row = this.jdbcTemplate.queryForMap("SELECT email, full_name FROM users WHERE id = ?", new Object[]{patientId});
            return new PatientContact(this.asString(row.get("email")), this.asString(row.get("full_name")));
        }
        catch (Exception e) {
            log.warn("Could not fetch patient email for {}: {}", (Object)patientId, (Object)e.getMessage());
            return null;
        }
    }

    private String asString(Object value) {
        return value != null ? value.toString() : null;
    }

    private String firstNonBlank(String ... values) {
        if (values == null) {
            return null;
        }
        for (String value : values) {
            if (value == null || value.isBlank()) continue;
            return value;
        }
        return null;
    }

    private void saveStatusHistory(Booking booking, BookingStatus oldStatus, BookingStatus newStatus, UUID changedBy, String reason) {
        BookingStatusHistory history = BookingStatusHistory.builder().booking(booking).oldStatus(oldStatus).newStatus(newStatus).changedBy(changedBy).reason(reason).build();
        this.statusHistoryRepository.save(history);
    }

    private BookingDto toDtoRaw(Booking booking) {
        TimeSlot slot = booking.getTimeSlot();
        return BookingDto.builder().id(booking.getId()).patientId(booking.getPatientId()).doctorId(booking.getDoctorId()).serviceId(booking.getServiceId()).timeSlot(slot != null ? BookingDto.TimeSlotDto.builder().id(slot.getId()).date(slot.getDate()).startTime(slot.getStartTime()).endTime(slot.getEndTime()).build() : null).status(booking.getStatus()).notes(booking.getNotes()).doctorNotes(booking.getDoctorNotes()).cancellationReason(booking.getCancellationReason()).totalAmount(booking.getTotalAmount()).paymentStatus(booking.getPaymentStatus()).paymentMethod(booking.getPaymentMethod()).paymentReference(booking.getPaymentReference()).paidAt(booking.getPaidAt()).createdAt(booking.getCreatedAt() != null ? booking.getCreatedAt() : LocalDateTime.now()).updatedAt(booking.getUpdatedAt() != null ? booking.getUpdatedAt() : LocalDateTime.now()).build();
    }

    private void enrichBookings(List<BookingDto> dtos) {
        if (dtos == null || dtos.isEmpty()) {
            return;
        }
        Set<UUID> patientIds = dtos.stream().map(BookingDto::getPatientId).filter(Objects::nonNull).collect(Collectors.toSet());
        Set<UUID> doctorIds = dtos.stream().map(BookingDto::getDoctorId).filter(Objects::nonNull).collect(Collectors.toSet());
        Set<UUID> serviceIds = dtos.stream().map(BookingDto::getServiceId).filter(Objects::nonNull).collect(Collectors.toSet());
        Map<UUID, Map<String, String>> patientMap = new HashMap<>();
        Map<UUID, Map<String, String>> doctorMap = new HashMap<>();
        Map<UUID, String> serviceMap = new HashMap<>();
        if (!patientIds.isEmpty()) {
            try {
                String inSql = patientIds.stream().map(id -> "?").collect(Collectors.joining(","));
                String query = String.format("SELECT user_id, full_name, avatar_url FROM profiles WHERE user_id IN (%s)", inSql);
                List<Map<String, Object>> rows = this.jdbcTemplate.queryForList(query, patientIds.toArray());
                for (Map<String, Object> row : rows) {
                    UUID userId = (UUID)row.get("user_id");
                    Map<String, String> info = new HashMap<>();
                    info.put("full_name", (String)row.get("full_name"));
                    info.put("avatar_url", (String)row.get("avatar_url"));
                    patientMap.put(userId, info);
                }
            }
            catch (Exception e) {
                log.warn("Error fetching patient profiles in batch: {}", (Object)e.getMessage());
            }
        }
        if (!doctorIds.isEmpty()) {
            try {
                String inSql = doctorIds.stream().map(id -> "?").collect(Collectors.joining(","));
                String query = String.format("SELECT id, full_name, avatar_url FROM doctors WHERE id IN (%s)", inSql);
                List<Map<String, Object>> rows = this.jdbcTemplate.queryForList(query, doctorIds.toArray());
                for (Map<String, Object> row : rows) {
                    UUID docId = (UUID)row.get("id");
                    Map<String, String> info = new HashMap<>();
                    info.put("full_name", (String)row.get("full_name"));
                    info.put("avatar_url", (String)row.get("avatar_url"));
                    doctorMap.put(docId, info);
                }
            }
            catch (Exception e) {
                log.warn("Error fetching doctor profiles in batch: {}", (Object)e.getMessage());
            }
        }
        if (!serviceIds.isEmpty()) {
            try {
                String inSql = serviceIds.stream().map(id -> "?").collect(Collectors.joining(","));
                String query = String.format("SELECT id, name FROM medical_services WHERE id IN (%s)", inSql);
                List<Map<String, Object>> rows = this.jdbcTemplate.queryForList(query, serviceIds.toArray());
                for (Map<String, Object> row : rows) {
                    UUID srvId = (UUID)row.get("id");
                    serviceMap.put(srvId, (String)row.get("name"));
                }
            }
            catch (Exception e) {
                log.warn("Error fetching medical services in batch: {}", (Object)e.getMessage());
            }
        }
        for (BookingDto dto : dtos) {
            if (dto.getPatientId() != null && patientMap.containsKey(dto.getPatientId())) {
                Map<String, String> info2 = patientMap.get(dto.getPatientId());
                dto.setPatientName(info2.get("full_name"));
                dto.setPatientAvatar(info2.get("avatar_url"));
            }
            if (dto.getDoctorId() != null && doctorMap.containsKey(dto.getDoctorId())) {
                Map<String, String> info2 = doctorMap.get(dto.getDoctorId());
                dto.setDoctorName(info2.get("full_name"));
                dto.setDoctorAvatar(info2.get("avatar_url"));
            }
            if (dto.getServiceId() == null || !serviceMap.containsKey(dto.getServiceId())) continue;
            dto.setServiceName(serviceMap.get(dto.getServiceId()));
        }
    }

    private TimeSlotDto toSlotDto(TimeSlot slot) {
        String doctorName = null;
        String doctorAvatar = null;
        try {
            List<Map<String, Object>> doctor = this.jdbcTemplate.queryForList("SELECT full_name, avatar_url FROM doctors WHERE id = ?", new Object[]{slot.getDoctorId()});
            if (!doctor.isEmpty()) {
                doctorName = (String)doctor.get(0).get("full_name");
                doctorAvatar = (String)doctor.get(0).get("avatar_url");
            }
        }
        catch (Exception e) {
            log.warn("Could not fetch doctor info for slot {}: {}", (Object)slot.getId(), (Object)e.getMessage());
        }
        return TimeSlotDto.builder().id(slot.getId()).doctorId(slot.getDoctorId()).doctorName(doctorName).doctorAvatar(doctorAvatar).date(slot.getDate()).startTime(slot.getStartTime()).endTime(slot.getEndTime()).isAvailable(slot.getIsAvailable()).status(slot.getStatus()).build();
    }

    @Transactional
    public List<TimeSlotDto> generateSlots(UUID doctorId, LocalDate date) {
        List<TimeSlot> existingSlots = this.timeSlotRepository.findAvailableSlotsByDoctorAndDate(doctorId, date);
        this.timeSlotRepository.deleteAll(existingSlots);
        List<TimeSlot> slots = IntStream.range(8, 17).mapToObj(hour -> TimeSlot.builder().doctorId(doctorId).date(date).startTime(LocalTime.of(hour, 0)).endTime(LocalTime.of(hour + 1, 0)).isAvailable(Boolean.valueOf(true)).build()).collect(Collectors.toList());
        slots = this.timeSlotRepository.saveAll(slots);
        return slots.stream().map(this::toSlotDto).collect(Collectors.toList());
    }

    @Transactional
    public List<TimeSlotDto> generateSlotsForUser(UUID userId, LocalDate date) {
        UUID doctorId = this.findDoctorIdByUserId(userId);
        if (doctorId == null) {
            log.warn("Cannot find doctorId for userId: {}", (Object)userId);
            return List.of();
        }
        return this.generateSlots(doctorId, date);
    }

    @Transactional(readOnly=true)
    public List<TimeSlotDto> getAllSlots(String status, LocalDate startDate, LocalDate endDate) {
        List<TimeSlot> slots;
        if (status != null && !status.isEmpty()) {
            try {
                SlotStatus slotStatus = SlotStatus.valueOf(status.toUpperCase());
                slots = this.timeSlotRepository.findByStatus(slotStatus);
            }
            catch (IllegalArgumentException e) {
                log.warn("Invalid status filter: {}", (Object)status);
                slots = this.timeSlotRepository.findAll();
            }
        } else {
            slots = this.timeSlotRepository.findAll();
        }
        if (startDate != null && endDate != null) {
            LocalDate start = startDate;
            LocalDate end = endDate;
            slots = slots.stream().filter(s -> !s.getDate().isBefore(start) && !s.getDate().isAfter(end)).collect(Collectors.toList());
        } else if (startDate != null) {
            LocalDate start = startDate;
            slots = slots.stream().filter(s -> !s.getDate().isBefore(start)).collect(Collectors.toList());
        } else if (endDate != null) {
            LocalDate end = endDate;
            slots = slots.stream().filter(s -> !s.getDate().isAfter(end)).collect(Collectors.toList());
        }
        slots.sort((a, b) -> {
            int dateCompare = b.getDate().compareTo(a.getDate());
            if (dateCompare != 0) {
                return dateCompare;
            }
            return a.getStartTime().compareTo(b.getStartTime());
        });
        return slots.stream().map(this::toSlotDto).collect(Collectors.toList());
    }

    @Transactional(readOnly=true)
    public List<TimeSlotDto> getAllSlots(String status) {
        return this.getAllSlots(status, null, null);
    }

    @Transactional(readOnly=true)
    public List<TimeSlotDto> getPendingSlots() {
        return this.timeSlotRepository.findByStatus(SlotStatus.PENDING).stream().map(this::toSlotDto).collect(Collectors.toList());
    }

    @Transactional
    public TimeSlotDto approveSlot(UUID slotId) {
        TimeSlot slot = this.timeSlotRepository.findById(slotId).orElseThrow(() -> new ResourceNotFoundException("TimeSlot", "id", slotId));
        slot.setStatus(SlotStatus.APPROVED);
        slot = this.timeSlotRepository.save(slot);
        log.info("Slot {} approved", (Object)slotId);
        return this.toSlotDto(slot);
    }

    @Transactional
    public TimeSlotDto rejectSlot(UUID slotId) {
        TimeSlot slot = this.timeSlotRepository.findById(slotId).orElseThrow(() -> new ResourceNotFoundException("TimeSlot", "id", slotId));
        slot.setStatus(SlotStatus.REJECTED);
        slot = this.timeSlotRepository.save(slot);
        log.info("Slot {} rejected", (Object)slotId);
        return this.toSlotDto(slot);
    }

    @Transactional
    public int approveBulkSlots(List<UUID> slotIds) {
        int count = 0;
        for (UUID slotId : slotIds) {
            try {
                TimeSlot slot = this.timeSlotRepository.findById(slotId).orElse(null);
                if (slot == null || slot.getStatus() != SlotStatus.PENDING) continue;
                slot.setStatus(SlotStatus.APPROVED);
                this.timeSlotRepository.save(slot);
                ++count;
            }
            catch (Exception e) {
                log.warn("Failed to approve slot {}: {}", (Object)slotId, (Object)e.getMessage());
            }
        }
        log.info("Bulk approved {} slots", (Object)count);
        return count;
    }

    @Transactional
    public int rejectBulkSlots(List<UUID> slotIds) {
        int count = 0;
        for (UUID slotId : slotIds) {
            try {
                TimeSlot slot = this.timeSlotRepository.findById(slotId).orElse(null);
                if (slot == null || slot.getStatus() != SlotStatus.PENDING) continue;
                slot.setStatus(SlotStatus.REJECTED);
                this.timeSlotRepository.save(slot);
                ++count;
            }
            catch (Exception e) {
                log.warn("Failed to reject slot {}: {}", (Object)slotId, (Object)e.getMessage());
            }
        }
        log.info("Bulk rejected {} slots", (Object)count);
        return count;
    }

    @Transactional(readOnly=true)
    public BookingStatsDto getBookingStats() {
        LocalDate today = LocalDate.now();
        long totalToday = this.bookingRepository.countByDate(today);
        long pending = 0L;
        long confirmed = 0L;
        long completed = 0L;
        long canceled = 0L;
        List<Object[]> statusCounts = this.bookingRepository.countByStatus();
        for (Object[] row : statusCounts) {
            BookingStatus status = (BookingStatus)row[0];
            long count = (Long)row[1];
            if (status == BookingStatus.PENDING) {
                pending = count;
                continue;
            }
            if (status == BookingStatus.CONFIRMED) {
                confirmed = count;
                continue;
            }
            if (status == BookingStatus.COMPLETED) {
                completed = count;
                continue;
            }
            if (status != BookingStatus.CANCELED && status != BookingStatus.CANCELLED) continue;
            canceled += count;
        }
        return BookingStatsDto.builder().totalToday((int)totalToday).pendingCount((int)pending).confirmedCount((int)confirmed).completedCount((int)completed).canceledCount((int)canceled).todayChangePercent(5.0).pendingChangePercent(-2.0).completedChangePercent(10.0).build();
    }

    @Transactional
    public void completeMockPayment(String appTransId) {
        Booking booking = (Booking)this.bookingRepository.findByPaymentReference(appTransId).orElseThrow(() -> new ResourceNotFoundException("Booking", "paymentReference", (Object)appTransId));
        this.markBookingPaidAndConfirm(booking, booking.getPatientId(), "Thanh toan gia lap thanh cong");
    }

    public double getAmountByPaymentReference(String appTransId) {
        return this.bookingRepository.findByPaymentReference(appTransId).map(b -> b.getTotalAmount() != null ? b.getTotalAmount().doubleValue() : 0.0).orElse(0.0);
    }

    @Generated
    public BookingService(BookingRepository bookingRepository, TimeSlotRepository timeSlotRepository, BookingStatusHistoryRepository statusHistoryRepository, JdbcTemplate jdbcTemplate, SlotNotificationService slotNotificationService, NotificationClient notificationClient, ZaloPayService zaloPayService) {
        this.bookingRepository = bookingRepository;
        this.timeSlotRepository = timeSlotRepository;
        this.statusHistoryRepository = statusHistoryRepository;
        this.jdbcTemplate = jdbcTemplate;
        this.slotNotificationService = slotNotificationService;
        this.notificationClient = notificationClient;
        this.zaloPayService = zaloPayService;
    }

    private record PatientContact(String email, String fullName) {
    }
}


