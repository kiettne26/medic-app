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
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * BOOKING SERVICE - CORE FEATURE
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
    private final JdbcTemplate jdbcTemplate;
    private final SlotNotificationService slotNotificationService;

    /**
     * Tìm doctorId từ userId (ID tài khoản)
     */
    private UUID findDoctorIdByUserId(UUID userId) {
        try {
            return jdbcTemplate.queryForObject(
                    "SELECT id FROM doctors WHERE user_id = ?",
                    UUID.class,
                    userId);
        } catch (Exception e) {
            log.error("Could not find doctorId for userId: {}", userId);
            return null;
        }
    }

    /**
     * ĐẶT LỊCH - CORE FUNCTION với Transaction và Pessimistic Lock
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

        // STEP 1: Lấy slot với PESSIMISTIC LOCK
        // Lock sẽ block tất cả requests khác đang cố truy cập cùng slot
        TimeSlot slot = timeSlotRepository.findByIdWithLock(request.getTimeSlotId())
                .orElseThrow(() -> new ResourceNotFoundException("TimeSlot", "id", request.getTimeSlotId()));

        // STEP 2: Double-check slot còn available không
        if (!slot.getIsAvailable()) {
            log.warn("Slot {} already booked, rejecting request from patient {}", slot.getId(), patientId);
            throw new SlotNotAvailableException();
        }

        // Validate doctorId matches
        if (!slot.getDoctorId().equals(request.getDoctorId())) {
            throw new BadRequestException("TimeSlot không thuộc về bác sĩ đã chọn");
        }

        // STEP 3: Đánh dấu slot đã đặt
        slot.setIsAvailable(false);
        timeSlotRepository.save(slot);

        // STEP 4: Tạo booking với status PENDING
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
    public BookingDto confirmBooking(UUID bookingId, UUID userId) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking", "id", bookingId));

        // Ánh xạ userId -> doctorId và kiểm tra quyền
        UUID doctorId = findDoctorIdByUserId(userId);
        if (doctorId == null || !booking.getDoctorId().equals(doctorId)) {
            throw new BadRequestException("Bạn không có quyền xác nhận lịch này");
        }

        if (booking.getStatus() != BookingStatus.PENDING) {
            throw new BadRequestException("Chỉ có thể xác nhận lịch đang chờ");
        }

        BookingStatus oldStatus = booking.getStatus();
        booking.setStatus(BookingStatus.CONFIRMED);
        booking = bookingRepository.save(booking);

        saveStatusHistory(booking, oldStatus, BookingStatus.CONFIRMED, userId, "Bác sĩ xác nhận");

        log.info("Booking {} confirmed by doctor {}", bookingId, userId);
        return toDto(booking);
    }

    /**
     * Hoàn thành lịch (Bác sĩ)
     */
    @Transactional
    public BookingDto completeBooking(UUID bookingId, UUID userId, String doctorNotes) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking", "id", bookingId));

        // Ánh xạ userId -> doctorId và kiểm tra quyền
        UUID doctorId = findDoctorIdByUserId(userId);
        if (doctorId == null || !booking.getDoctorId().equals(doctorId)) {
            throw new BadRequestException("Bạn không có quyền hoàn thành lịch này");
        }

        if (booking.getStatus() != BookingStatus.CONFIRMED) {
            throw new BadRequestException("Chỉ có thể hoàn thành lịch đã xác nhận");
        }

        BookingStatus oldStatus = booking.getStatus();
        booking.setStatus(BookingStatus.COMPLETED);
        booking.setDoctorNotes(doctorNotes);
        booking = bookingRepository.save(booking);

        saveStatusHistory(booking, oldStatus, BookingStatus.COMPLETED, userId, "Hoàn thành khám");

        log.info("Booking {} completed by doctor {}", bookingId, userId);
        return toDto(booking);
    }

    /**
     * Hủy lịch (Patient hoặc Doctor)
     */
    @Transactional
    public BookingDto cancelBooking(UUID bookingId, UUID userId, CancelBookingRequest request) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Booking", "id", bookingId));
        boolean isPatient = booking.getPatientId().equals(userId);
        UUID doctorId = findDoctorIdByUserId(userId);
        boolean isDoctor = (doctorId != null && booking.getDoctorId().equals(doctorId));

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

        // Trả lại slot để người khác có thể đặt
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
    public Page<BookingDto> getDoctorBookings(UUID userId, Pageable pageable) {
        UUID doctorId = findDoctorIdByUserId(userId);
        if (doctorId == null) {
            return Page.empty();
        }
        return bookingRepository.findByDoctorIdOrderByCreatedAtDesc(doctorId, pageable)
                .map(this::toDto);
    }

    /**
     * Lấy booking của doctor trong ngày
     */
    public List<BookingDto> getDoctorBookingsByDate(UUID userId, LocalDate date) {
        UUID doctorId = findDoctorIdByUserId(userId);
        if (doctorId == null) {
            return List.of();
        }
        return bookingRepository.findByDoctorIdAndDate(doctorId, date).stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    /**
     * Lấy tất cả booking (Admin)
     */
    public Page<BookingDto> getAllBookings(BookingStatus status, Pageable pageable) {
        if (status != null) {
            return bookingRepository.findByStatusOrderByCreatedAtDesc(status, pageable)
                    .map(this::toDto);
        }
        return bookingRepository.findAll(pageable)
                .map(this::toDto);
    }

    /**
     * Lấy slot trống của doctor trong ngày (cho bệnh nhân - chỉ slot APPROVED)
     */
    public List<TimeSlotDto> getAvailableSlots(UUID doctorId, LocalDate date) {
        return timeSlotRepository.findApprovedAvailableSlotsByDoctorAndDate(doctorId, date).stream()
                .map(this::toSlotDto)
                .collect(Collectors.toList());
    }

    /**
     * Lấy tất cả slots của doctor trong tuần (cho màn hình lịch làm việc)
     */
    public List<TimeSlotDto> getDoctorSlotsForWeek(UUID userId, LocalDate startDate, LocalDate endDate) {
        UUID doctorId = userId != null ? findDoctorIdByUserId(userId) : null;
        if (doctorId == null) {
            log.warn("Cannot find doctorId for userId: {}, returning empty list", userId);
            return List.of();
        }
        return timeSlotRepository.findByDoctorIdAndDateBetween(doctorId, startDate, endDate).stream()
                .map(this::toSlotDto)
                .collect(Collectors.toList());
    }

    /**
     * Tạo TimeSlot mới cho bác sĩ
     */
    @Transactional
    public TimeSlotDto createTimeSlot(UUID userId, LocalDate date, String startTime, String endTime) {
        UUID doctorId = userId != null ? findDoctorIdByUserId(userId) : null;
        if (doctorId == null) {
            throw new BadRequestException("Doctor not found for user: " + userId);
        }

        // Validate time format (Assuming HH:mm or HH:mm:ss)
        if (startTime.length() == 5)
            startTime += ":00";
        if (endTime.length() == 5)
            endTime += ":00";

        java.time.LocalTime start = java.time.LocalTime.parse(startTime);
        java.time.LocalTime end = java.time.LocalTime.parse(endTime);

        // Validation 1: Time range (07:00-17:00)
        java.time.LocalTime minTime = java.time.LocalTime.of(7, 0);
        java.time.LocalTime maxTime = java.time.LocalTime.of(17, 0);
        if (start.isBefore(minTime) || end.isAfter(maxTime)) {
            throw new BadRequestException("Khung giờ phải trong khoảng 07:00 - 17:00");
        }

        // Validation 2: End time must be after start time
        if (!end.isAfter(start)) {
            throw new BadRequestException("Giờ kết thúc phải sau giờ bắt đầu");
        }

        // Validation 3: Check for overlapping slots
        List<TimeSlot> existingSlots = timeSlotRepository.findByDoctorIdAndDateBetween(doctorId, date, date);
        for (TimeSlot existing : existingSlots) {
            // Check if time ranges overlap
            if (start.isBefore(existing.getEndTime()) && end.isAfter(existing.getStartTime())) {
                throw new BadRequestException("Khung giờ bị trùng với khung giờ đã có");
            }
        }

        TimeSlot slot = new TimeSlot();
        slot.setDoctorId(doctorId);
        slot.setDate(date);
        slot.setStartTime(start);
        slot.setEndTime(end);
        slot.setIsAvailable(true);
        slot.setCreatedAt(java.time.LocalDateTime.now());
        slot.setUpdatedAt(java.time.LocalDateTime.now());
        // Version init handled by DB or set to 0
        slot.setVersion(0L);

        TimeSlot saved = timeSlotRepository.save(slot);
        TimeSlotDto slotDto = toSlotDto(saved);
        
        // Send WebSocket notification to admin
        slotNotificationService.notifyNewPendingSlot(slotDto);
        
        return slotDto;
    }

    /**
     * Xóa TimeSlot
     */
    @Transactional
    public void deleteTimeSlot(UUID slotId, UUID userId) {
        TimeSlot slot = timeSlotRepository.findById(slotId)
                .orElseThrow(() -> new ResourceNotFoundException("TimeSlot", "id", slotId));

        // Validate ownership
        UUID doctorId = userId != null ? findDoctorIdByUserId(userId) : null;
        if (doctorId == null || !slot.getDoctorId().equals(doctorId)) {
            throw new BadRequestException("You don't have permission to delete this slot");
        }

        // Check if booked
        if (!slot.getIsAvailable()) {
            throw new BadRequestException("Cannot delete booked slot");
        }

        timeSlotRepository.delete(slot);
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

        String patientName = null;
        String patientAvatar = null;
        String doctorName = null;
        String doctorAvatar = null;
        String serviceName = null;

        try {
            // Get Patient Name & Avatar from profiles table
            List<java.util.Map<String, Object>> profile = jdbcTemplate.queryForList(
                    "SELECT full_name, avatar_url FROM profiles WHERE user_id = ?", booking.getPatientId());
            if (!profile.isEmpty()) {
                patientName = (String) profile.get(0).get("full_name");
                patientAvatar = (String) profile.get(0).get("avatar_url");
            }

            // Get Doctor Name & Avatar from doctors table
            List<java.util.Map<String, Object>> doctor = jdbcTemplate.queryForList(
                    "SELECT full_name, avatar_url FROM doctors WHERE id = ?", booking.getDoctorId());
            if (!doctor.isEmpty()) {
                doctorName = (String) doctor.get(0).get("full_name");
                doctorAvatar = (String) doctor.get(0).get("avatar_url");
            }

            // Get Service Name from medical_services table
            serviceName = jdbcTemplate.queryForObject(
                    "SELECT name FROM medical_services WHERE id = ?", String.class, booking.getServiceId());
        } catch (Exception e) {
            log.warn("Could not fetch extra info for booking {}: {}", booking.getId(), e.getMessage());
        }

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
                .patientName(patientName)
                .patientAvatar(patientAvatar)
                .doctorName(doctorName)
                .doctorAvatar(doctorAvatar)
                .serviceName(serviceName)
                .createdAt(booking.getCreatedAt() != null ? booking.getCreatedAt() : java.time.LocalDateTime.now())
                .updatedAt(booking.getUpdatedAt() != null ? booking.getUpdatedAt() : java.time.LocalDateTime.now())
                .build();
    }

    /**
     * Convert TimeSlot to DTO
     */
    private TimeSlotDto toSlotDto(TimeSlot slot) {
        String doctorName = null;
        String doctorAvatar = null;
        
        try {
            List<java.util.Map<String, Object>> doctor = jdbcTemplate.queryForList(
                    "SELECT full_name, avatar_url FROM doctors WHERE id = ?", slot.getDoctorId());
            if (!doctor.isEmpty()) {
                doctorName = (String) doctor.get(0).get("full_name");
                doctorAvatar = (String) doctor.get(0).get("avatar_url");
            }
        } catch (Exception e) {
            log.warn("Could not fetch doctor info for slot {}: {}", slot.getId(), e.getMessage());
        }
        
        return TimeSlotDto.builder()
                .id(slot.getId())
                .doctorId(slot.getDoctorId())
                .doctorName(doctorName)
                .doctorAvatar(doctorAvatar)
                .date(slot.getDate())
                .startTime(slot.getStartTime())
                .endTime(slot.getEndTime())
                .isAvailable(slot.getIsAvailable())
                .status(slot.getStatus())
                .build();
    }

    /**
     * SEED DATA: Tạo lịch mẫu cho bác sĩ (Dùng cho dev)
     */
    @Transactional
    public List<TimeSlotDto> generateSlots(UUID doctorId, LocalDate date) {
        // Clear existing slots
        List<TimeSlot> existingSlots = timeSlotRepository.findAvailableSlotsByDoctorAndDate(doctorId, date);
        timeSlotRepository.deleteAll(existingSlots);

        // Create new slots from 08:00 to 17:00, 1 hour each
        List<TimeSlot> slots = java.util.stream.IntStream.range(8, 17)
                .mapToObj(hour -> TimeSlot.builder()
                        .doctorId(doctorId)
                        .date(date)
                        .startTime(java.time.LocalTime.of(hour, 0))
                        .endTime(java.time.LocalTime.of(hour + 1, 0))
                        .isAvailable(true)
                        .build())
                .collect(Collectors.toList());

        slots = timeSlotRepository.saveAll(slots);
        return slots.stream().map(this::toSlotDto).collect(Collectors.toList());
    }

    /**
     * SEED DATA: Tạo lịch mẫu cho bác sĩ sử dụng userId (account ID)
     */
    @Transactional
    public List<TimeSlotDto> generateSlotsForUser(UUID userId, LocalDate date) {
        UUID doctorId = findDoctorIdByUserId(userId);
        if (doctorId == null) {
            log.warn("Cannot find doctorId for userId: {}", userId);
            return List.of();
        }
        return generateSlots(doctorId, date);
    }

    // ==================== ADMIN APPROVAL WORKFLOW ====================

    /**
     * Lấy tất cả slots (Admin) - có thể filter theo status và khoảng ngày
     */
    public List<TimeSlotDto> getAllSlots(String status, LocalDate startDate, LocalDate endDate) {
        List<TimeSlot> slots;
        
        // Filter by status if provided
        if (status != null && !status.isEmpty()) {
            try {
                com.medibook.common.enums.SlotStatus slotStatus = 
                    com.medibook.common.enums.SlotStatus.valueOf(status.toUpperCase());
                slots = timeSlotRepository.findByStatus(slotStatus);
            } catch (IllegalArgumentException e) {
                log.warn("Invalid status filter: {}", status);
                slots = timeSlotRepository.findAll();
            }
        } else {
            slots = timeSlotRepository.findAll();
        }
        
        // Filter by date range if provided
        if (startDate != null && endDate != null) {
            final LocalDate start = startDate;
            final LocalDate end = endDate;
            slots = slots.stream()
                    .filter(s -> !s.getDate().isBefore(start) && !s.getDate().isAfter(end))
                    .collect(Collectors.toList());
        } else if (startDate != null) {
            final LocalDate start = startDate;
            slots = slots.stream()
                    .filter(s -> !s.getDate().isBefore(start))
                    .collect(Collectors.toList());
        } else if (endDate != null) {
            final LocalDate end = endDate;
            slots = slots.stream()
                    .filter(s -> !s.getDate().isAfter(end))
                    .collect(Collectors.toList());
        }
        
        // Sort by date desc, then startTime
        slots.sort((a, b) -> {
            int dateCompare = b.getDate().compareTo(a.getDate());
            if (dateCompare != 0) return dateCompare;
            return a.getStartTime().compareTo(b.getStartTime());
        });
        
        return slots.stream()
                .map(this::toSlotDto)
                .collect(Collectors.toList());
    }
    
    /**
     * Backward compatible - Lấy tất cả slots (Admin) - chỉ filter theo status
     */
    public List<TimeSlotDto> getAllSlots(String status) {
        return getAllSlots(status, null, null);
    }

    /**
     * Lấy danh sách slots đang chờ duyệt (Admin)
     */
    public List<TimeSlotDto> getPendingSlots() {
        return timeSlotRepository.findByStatus(com.medibook.common.enums.SlotStatus.PENDING)
                .stream()
                .map(this::toSlotDto)
                .collect(Collectors.toList());
    }

    /**
     * Duyệt slot (Admin)
     */
    @Transactional
    public TimeSlotDto approveSlot(UUID slotId) {
        TimeSlot slot = timeSlotRepository.findById(slotId)
                .orElseThrow(() -> new ResourceNotFoundException("TimeSlot", "id", slotId));

        slot.setStatus(com.medibook.common.enums.SlotStatus.APPROVED);
        slot = timeSlotRepository.save(slot);

        log.info("Slot {} approved", slotId);
        return toSlotDto(slot);
    }

    /**
     * Từ chối slot (Admin)
     */
    @Transactional
    public TimeSlotDto rejectSlot(UUID slotId) {
        TimeSlot slot = timeSlotRepository.findById(slotId)
                .orElseThrow(() -> new ResourceNotFoundException("TimeSlot", "id", slotId));

        slot.setStatus(com.medibook.common.enums.SlotStatus.REJECTED);
        slot = timeSlotRepository.save(slot);

        log.info("Slot {} rejected", slotId);
        return toSlotDto(slot);
    }

    /**
     * Duyệt nhiều slot cùng lúc (Admin)
     */
    @Transactional
    public int approveBulkSlots(List<UUID> slotIds) {
        int count = 0;
        for (UUID slotId : slotIds) {
            try {
                TimeSlot slot = timeSlotRepository.findById(slotId).orElse(null);
                if (slot != null && slot.getStatus() == com.medibook.common.enums.SlotStatus.PENDING) {
                    slot.setStatus(com.medibook.common.enums.SlotStatus.APPROVED);
                    timeSlotRepository.save(slot);
                    count++;
                }
            } catch (Exception e) {
                log.warn("Failed to approve slot {}: {}", slotId, e.getMessage());
            }
        }
        log.info("Bulk approved {} slots", count);
        return count;
    }

    /**
     * Từ chối nhiều slot cùng lúc (Admin)
     */
    @Transactional
    public int rejectBulkSlots(List<UUID> slotIds) {
        int count = 0;
        for (UUID slotId : slotIds) {
            try {
                TimeSlot slot = timeSlotRepository.findById(slotId).orElse(null);
                if (slot != null && slot.getStatus() == com.medibook.common.enums.SlotStatus.PENDING) {
                    slot.setStatus(com.medibook.common.enums.SlotStatus.REJECTED);
                    timeSlotRepository.save(slot);
                    count++;
                }
            } catch (Exception e) {
                log.warn("Failed to reject slot {}: {}", slotId, e.getMessage());
            }
        }
        log.info("Bulk rejected {} slots", count);
        return count;
    }
}
