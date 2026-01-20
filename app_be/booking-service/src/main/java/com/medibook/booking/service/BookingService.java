package com.medibook.booking.service;

import com.medibook.booking.dto.*;
import com.medibook.booking.entity.*;
import com.medibook.booking.repository.*;
import com.medibook.common.enums.BookingStatus;
import com.medibook.common.exception.BadRequestException;
import com.medibook.common.exception.ResourceNotFoundException;
import com.medibook.common.exception.SlotNotAvailableException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 🔐 BOOKING SERVICE - CORE FEATURE
 * Xử lý đặt lịch với Transaction và Pessimistic Lock
 * Chống race condition và double booking
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class BookingService {

    private final BookingRepository bookingRepository;
    private final TimeSlotRepository timeSlotRepository;
    private final BookingStatusHistoryRepository statusHistoryRepository;

    /**
     * 🔐 ĐẶT LỊCH - CORE FUNCTION với Transaction và Pessimistic Lock
     * 
     * Flow:
     * 1. Bắt đầu transaction với isolation SERIALIZABLE
     * 2. Lấy TimeSlot với PESSIMISTIC_WRITE lock (block các requests khác)
     * 3. Kiểm tra slot còn available không
     * 4. Nếu có -> đánh dấu slot đã đặt và tạo booking
     * 5. Nếu không -> throw exception
     * 6. Commit transaction và release lock
     */
    @Transactional(isolation = Isolation.SERIALIZABLE)
    public BookingDto createBooking(UUID patientId, CreateBookingRequest request) {
        log.info("Creating booking for patient: {}, slot: {}", patientId, request.getTimeSlotId());

        // 🔐 STEP 1: Lấy slot với PESSIMISTIC LOCK
        // Lock sẽ block tất cả requests khác đang cố truy cập cùng slot
        TimeSlot slot = timeSlotRepository.findByIdWithLock(request.getTimeSlotId())
                .orElseThrow(() -> new ResourceNotFoundException("TimeSlot", "id", request.getTimeSlotId()));

        // 🔐 STEP 2: Double-check slot còn available không
        if (!slot.getIsAvailable()) {
            log.warn("Slot {} already booked, rejecting request from patient {}", slot.getId(), patientId);
            throw new SlotNotAvailableException();
        }

        // Validate doctorId matches
        if (!slot.getDoctorId().equals(request.getDoctorId())) {
            throw new BadRequestException("TimeSlot không thuộc về bác sĩ đã chọn");
        }

        // 🔐 STEP 3: Đánh dấu slot đã đặt
        slot.setIsAvailable(false);
        timeSlotRepository.save(slot);

        // 🔐 STEP 4: Tạo booking với status PENDING
        Booking booking = Booking.builder()
                .patientId(patientId)
                .doctorId(request.getDoctorId())
                .serviceId(request.getServiceId())
                .timeSlot(slot)
                .status(BookingStatus.PENDING)
                .notes(request.getNotes())
                .build();

        booking = bookingRepository.save(booking);

        // Lưu lịch sử status
        saveStatusHistory(booking, null, BookingStatus.PENDING, patientId, "Đặt lịch mới");

        log.info("Booking created successfully: {}", booking.getId());

        // TODO: Gửi notification qua Notification Service

        return toDto(booking);
    }

    /**
     * Xác nhận lịch (Bác sĩ)
     */
    @Transactional
    public BookingDto confirmBooking(UUID bookingId, UUID doctorId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking", "id", bookingId));

        if (!booking.getDoctorId().equals(doctorId)) {
            throw new BadRequestException("Bạn không có quyền xác nhận lịch này");
        }

        if (booking.getStatus() != BookingStatus.PENDING) {
            throw new BadRequestException("Chỉ có thể xác nhận lịch đang chờ");
        }

        BookingStatus oldStatus = booking.getStatus();
        booking.setStatus(BookingStatus.CONFIRMED);
        booking = bookingRepository.save(booking);

        saveStatusHistory(booking, oldStatus, BookingStatus.CONFIRMED, doctorId, "Bác sĩ xác nhận");

        log.info("Booking {} confirmed by doctor {}", bookingId, doctorId);
        return toDto(booking);
    }

    /**
     * Hoàn thành lịch (Bác sĩ)
     */
    @Transactional
    public BookingDto completeBooking(UUID bookingId, UUID doctorId, String doctorNotes) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking", "id", bookingId));

        if (!booking.getDoctorId().equals(doctorId)) {
            throw new BadRequestException("Bạn không có quyền hoàn thành lịch này");
        }

        if (booking.getStatus() != BookingStatus.CONFIRMED) {
            throw new BadRequestException("Chỉ có thể hoàn thành lịch đã xác nhận");
        }

        BookingStatus oldStatus = booking.getStatus();
        booking.setStatus(BookingStatus.COMPLETED);
        booking.setDoctorNotes(doctorNotes);
        booking = bookingRepository.save(booking);

        saveStatusHistory(booking, oldStatus, BookingStatus.COMPLETED, doctorId, "Hoàn thành khám");

        log.info("Booking {} completed by doctor {}", bookingId, doctorId);
        return toDto(booking);
    }

    /**
     * Hủy lịch (Patient hoặc Doctor)
     */
    @Transactional
    public BookingDto cancelBooking(UUID bookingId, UUID userId, CancelBookingRequest request) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking", "id", bookingId));

        // Kiểm tra quyền hủy
        boolean isPatient = booking.getPatientId().equals(userId);
        boolean isDoctor = booking.getDoctorId().equals(userId);

        if (!isPatient && !isDoctor) {
            throw new BadRequestException("Bạn không có quyền hủy lịch này");
        }

        if (booking.getStatus() == BookingStatus.COMPLETED || booking.getStatus() == BookingStatus.CANCELED) {
            throw new BadRequestException("Không thể hủy lịch đã hoàn thành hoặc đã hủy");
        }

        BookingStatus oldStatus = booking.getStatus();
        booking.setStatus(BookingStatus.CANCELED);
        booking.setCancellationReason(request.getReason());
        booking.setCancelledBy(userId);

        // 🔐 Trả lại slot để người khác có thể đặt
        TimeSlot slot = booking.getTimeSlot();
        slot.setIsAvailable(true);
        timeSlotRepository.save(slot);

        booking = bookingRepository.save(booking);

        String reason = isPatient ? "Bệnh nhân hủy" : "Bác sĩ hủy";
        saveStatusHistory(booking, oldStatus, BookingStatus.CANCELED, userId, reason + ": " + request.getReason());

        log.info("Booking {} cancelled by user {}", bookingId, userId);
        return toDto(booking);
    }

    /**
     * Lấy booking theo ID
     */
    public BookingDto getBookingById(UUID id) {
        Booking booking = bookingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Booking", "id", id));
        return toDto(booking);
    }

    /**
     * Lấy danh sách booking của patient
     */
    public Page<BookingDto> getPatientBookings(UUID patientId, Pageable pageable) {
        return bookingRepository.findByPatientIdOrderByCreatedAtDesc(patientId, pageable)
                .map(this::toDto);
    }

    /**
     * Lấy danh sách booking của doctor
     */
    public Page<BookingDto> getDoctorBookings(UUID doctorId, Pageable pageable) {
        return bookingRepository.findByDoctorIdOrderByCreatedAtDesc(doctorId, pageable)
                .map(this::toDto);
    }

    /**
     * Lấy booking của doctor trong ngày
     */
    public List<BookingDto> getDoctorBookingsByDate(UUID doctorId, LocalDate date) {
        return bookingRepository.findByDoctorIdAndDate(doctorId, date).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Lấy slot trống của doctor trong ngày
     */
    public List<TimeSlotDto> getAvailableSlots(UUID doctorId, LocalDate date) {
        return timeSlotRepository.findAvailableSlotsByDoctorAndDate(doctorId, date).stream()
                .map(this::toSlotDto)
                .collect(Collectors.toList());
    }

    /**
     * Lưu lịch sử thay đổi status
     */
    private void saveStatusHistory(Booking booking, BookingStatus oldStatus, BookingStatus newStatus, UUID changedBy,
            String reason) {
        BookingStatusHistory history = BookingStatusHistory.builder()
                .booking(booking)
                .oldStatus(oldStatus)
                .newStatus(newStatus)
                .changedBy(changedBy)
                .reason(reason)
                .build();
        statusHistoryRepository.save(history);
    }

    /**
     * Convert Booking to DTO
     */
    private BookingDto toDto(Booking booking) {
        TimeSlot slot = booking.getTimeSlot();
        return BookingDto.builder()
                .id(booking.getId())
                .patientId(booking.getPatientId())
                .doctorId(booking.getDoctorId())
                .serviceId(booking.getServiceId())
                .timeSlot(BookingDto.TimeSlotDto.builder()
                        .id(slot.getId())
                        .date(slot.getDate())
                        .startTime(slot.getStartTime())
                        .endTime(slot.getEndTime())
                        .build())
                .status(booking.getStatus())
                .notes(booking.getNotes())
                .doctorNotes(booking.getDoctorNotes())
                .cancellationReason(booking.getCancellationReason())
                .createdAt(booking.getCreatedAt())
                .updatedAt(booking.getUpdatedAt())
                .build();
    }

    /**
     * Convert TimeSlot to DTO
     */
    private TimeSlotDto toSlotDto(TimeSlot slot) {
        return TimeSlotDto.builder()
                .id(slot.getId())
                .doctorId(slot.getDoctorId())
                .date(slot.getDate())
                .startTime(slot.getStartTime())
                .endTime(slot.getEndTime())
                .isAvailable(slot.getIsAvailable())
                .build();
    }
}
