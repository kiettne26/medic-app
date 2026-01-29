import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/appointment_repository.dart';
import '../data/dto/booking_dto.dart';

/// State cho trang lịch hẹn
class AppointmentState {
  final List<BookingDto> appointments;
  final bool isLoading;
  final String? error;
  final String? selectedStatus; // Filter: null = all
  final DateTime selectedDate; // Filter by date: defaults to today

  AppointmentState({
    this.appointments = const [],
    this.isLoading = false,
    this.error,
    this.selectedStatus,
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  AppointmentState copyWith({
    List<BookingDto>? appointments,
    bool? isLoading,
    String? error,
    String? selectedStatus,
    DateTime? selectedDate,
    bool clearError = false,
    bool clearDate = false,
    bool clearStatus = false,
  }) {
    return AppointmentState(
      appointments: appointments ?? this.appointments,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedStatus: clearStatus
          ? null
          : (selectedStatus ?? this.selectedStatus),
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
    );
  }

  /// Lọc appointments theo status và date
  List<BookingDto> get filteredAppointments {
    var result = appointments;

    // Filter by status
    if (selectedStatus != null) {
      result = result.where((a) => a.status == selectedStatus).toList();
    }

    // Filter by date (always filter since selectedDate defaults to today)
    result = result.where((a) {
      if (a.timeSlot?.date == null) return false;
      final bookingDate = a.timeSlot!.date;
      return bookingDate.year == selectedDate.year &&
          bookingDate.month == selectedDate.month &&
          bookingDate.day == selectedDate.day;
    }).toList();

    return result;
  }
}

/// Controller quản lý lịch hẹn
class AppointmentController extends StateNotifier<AppointmentState> {
  final AppointmentRepository _repository;

  AppointmentController(this._repository) : super(AppointmentState()) {
    loadAppointments();
  }

  /// Load danh sách lịch hẹn
  Future<void> loadAppointments() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final appointments = await _repository.getAppointments();
      state = state.copyWith(appointments: appointments, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Filter theo trạng thái
  void filterByStatus(String? status) {
    if (status == null) {
      state = state.copyWith(clearStatus: true);
    } else {
      state = state.copyWith(selectedStatus: status);
    }
  }

  /// Filter theo ngày
  void filterByDate(DateTime? date) {
    if (date == null) {
      state = state.copyWith(clearDate: true);
    } else {
      state = state.copyWith(selectedDate: date);
    }
  }

  /// Xác nhận lịch hẹn
  Future<bool> confirmBooking(String id) async {
    try {
      await _repository.confirmBooking(id);
      await loadAppointments(); // Refresh list
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Không thể xác nhận: ${e.toString()}');
      return false;
    }
  }

  /// Hoàn thành lịch hẹn
  Future<bool> completeBooking(String id, {String? notes}) async {
    try {
      await _repository.completeBooking(id, notes ?? '');
      await loadAppointments();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Không thể hoàn thành: ${e.toString()}');
      return false;
    }
  }

  /// Hủy lịch hẹn
  Future<bool> cancelBooking(String id, String reason) async {
    try {
      await _repository.cancelBooking(id, reason);
      await loadAppointments();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Không thể hủy: ${e.toString()}');
      return false;
    }
  }
}

/// Provider cho AppointmentController
final appointmentControllerProvider =
    StateNotifierProvider<AppointmentController, AppointmentState>((ref) {
      final repository = ref.watch(appointmentRepositoryProvider);
      return AppointmentController(repository);
    });
