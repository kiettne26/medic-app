import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../booking/data/appointment_repository.dart';
import '../../booking/data/dto/booking_dto.dart';

class DashboardController extends StateNotifier<AsyncValue<List<BookingDto>>> {
  final AppointmentRepository _repository;

  DashboardController(this._repository) : super(const AsyncValue.loading()) {
    getAppointments();
  }

  Future<void> getAppointments() async {
    try {
      state = const AsyncValue.loading();
      final appointments = await _repository.getAppointments();
      state = AsyncValue.data(appointments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> confirmBooking(String id) async {
    try {
      await _repository.confirmBooking(id);
      await getAppointments(); // Refresh list
    } catch (e) {
      // Handle error
    }
  }
}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, AsyncValue<List<BookingDto>>>((
      ref,
    ) {
      final repository = ref.watch(appointmentRepositoryProvider);
      return DashboardController(repository);
    });
