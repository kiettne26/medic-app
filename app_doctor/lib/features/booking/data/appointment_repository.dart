import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'source/appointment_api.dart';
import 'dto/booking_dto.dart';

class AppointmentRepository {
  final AppointmentApi _api;

  AppointmentRepository(this._api);

  Future<List<BookingDto>> getAppointments() async {
    return _api.getAppointments();
  }

  Future<void> confirmBooking(String id) => _api.confirmBooking(id);
  Future<void> completeBooking(String id, String notes) =>
      _api.completeBooking(id, notes);
  Future<void> cancelBooking(String id, String reason) =>
      _api.cancelBooking(id, reason);
}

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  final api = ref.watch(appointmentApiProvider);
  return AppointmentRepository(api);
});
