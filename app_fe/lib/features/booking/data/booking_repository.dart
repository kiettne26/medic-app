import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dto/booking_dto.dart';
import 'source/booking_api.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(bookingApiProvider));
});

class BookingRepository {
  final BookingApi _api;

  BookingRepository(this._api);

  Future<List<TimeSlotDto>> getAvailableSlots(String doctorId, String date) {
    return _api.getAvailableSlots(doctorId, date);
  }

  Future<BookingDto> createBooking(CreateBookingRequest request) {
    return _api.createBooking(request);
  }

  Future<List<BookingDto>> getMyBookings() {
    return _api.getMyBookings();
  }
}
