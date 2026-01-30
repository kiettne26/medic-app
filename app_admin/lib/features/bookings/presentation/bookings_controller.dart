import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../bookings/data/dto/booking_dto.dart';
import '../../bookings/data/bookings_api.dart';

final bookingsControllerProvider =
    AsyncNotifierProvider<BookingsController, List<BookingDto>>(() {
      return BookingsController();
    });

class BookingsController extends AsyncNotifier<List<BookingDto>> {
  @override
  FutureOr<List<BookingDto>> build() async {
    return _fetchBookings();
  }

  Future<List<BookingDto>> _fetchBookings({String? status}) async {
    final api = ref.read(bookingsApiProvider);
    return api.getBookings(status: status);
  }

  Future<void> refresh({String? status}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchBookings(status: status));
  }
}
