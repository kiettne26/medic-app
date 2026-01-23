import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/booking_repository.dart';
import '../data/dto/booking_dto.dart';

// Provider for available time slots
final timeSlotsProvider =
    StateNotifierProvider.autoDispose<
      TimeSlotsNotifier,
      AsyncValue<List<TimeSlotDto>>
    >((ref) {
      return TimeSlotsNotifier(ref.watch(bookingRepositoryProvider));
    });

class TimeSlotsNotifier extends StateNotifier<AsyncValue<List<TimeSlotDto>>> {
  final BookingRepository _repository;

  TimeSlotsNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadAvailableSlots(String doctorId, DateTime date) async {
    try {
      state = const AsyncValue.loading();
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final slots = await _repository.getAvailableSlots(doctorId, dateStr);
      state = AsyncValue.data(slots);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Controller for booking actions (create booking)
final bookingControllerProvider =
    StateNotifierProvider<BookingController, BookingState>((ref) {
      return BookingController(ref.watch(bookingRepositoryProvider));
    });

class BookingState {
  final bool isLoading;
  final String? error;
  final BookingDto? successData;

  BookingState({this.isLoading = false, this.error, this.successData});

  BookingState copyWith({
    bool? isLoading,
    String? error,
    BookingDto? successData,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // If not provided, error is cleared (nullable)
      successData: successData ?? this.successData,
    );
  }
}

class BookingController extends StateNotifier<BookingState> {
  final BookingRepository _repository;

  BookingController(this._repository) : super(BookingState());

  Future<bool> createBooking({
    required String doctorId,
    required String serviceId,
    required String timeSlotId,
    String? notes,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final request = CreateBookingRequest(
        doctorId: doctorId,
        serviceId: serviceId,
        timeSlotId: timeSlotId,
        notes: notes,
      );

      final booking = await _repository.createBooking(request);
      state = state.copyWith(isLoading: false, successData: booking);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
