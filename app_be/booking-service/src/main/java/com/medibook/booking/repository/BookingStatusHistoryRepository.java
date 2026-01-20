package com.medibook.booking.repository;

import com.medibook.booking.entity.Booking;
import com.medibook.booking.entity.BookingStatusHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface BookingStatusHistoryRepository extends JpaRepository<BookingStatusHistory, UUID> {

    List<BookingStatusHistory> findByBookingOrderByChangedAtDesc(Booking booking);

    List<BookingStatusHistory> findByBookingIdOrderByChangedAtDesc(UUID bookingId);
}
