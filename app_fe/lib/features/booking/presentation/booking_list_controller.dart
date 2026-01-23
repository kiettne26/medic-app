import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dto/booking_dto.dart';
import '../data/source/booking_api.dart';

/// State cho Booking List Screen
class BookingListState {
  final List<BookingDto> upcomingBookings;
  final List<BookingDto> completedBookings;
  final bool isLoading;
  final String? errorMessage;

  BookingListState({
    this.upcomingBookings = const [],
    this.completedBookings = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  BookingListState copyWith({
    List<BookingDto>? upcomingBookings,
    List<BookingDto>? completedBookings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BookingListState(
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
      completedBookings: completedBookings ?? this.completedBookings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Controller cho Booking List Screen
class BookingListController extends StateNotifier<BookingListState> {
  final BookingApi _bookingApi;

  BookingListController(this._bookingApi) : super(BookingListState()) {
    loadBookings();
  }

  /// Load tất cả bookings của user
  Future<void> loadBookings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final allBookings = await _bookingApi.getMyBookings();

      // Phân loại bookings
      final upcoming = <BookingDto>[];
      final completed = <BookingDto>[];

      for (final booking in allBookings) {
        final status = booking.status?.toUpperCase() ?? '';
        if (status == 'COMPLETED' || status == 'CANCELLED') {
          completed.add(booking);
        } else {
          upcoming.add(booking);
        }
      }

      state = state.copyWith(
        upcomingBookings: upcoming,
        completedBookings: completed,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải danh sách lịch hẹn: $e',
      );
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadBookings();
  }
}

/// Provider cho BookingListController
final bookingListControllerProvider =
    StateNotifierProvider<BookingListController, BookingListState>((ref) {
      return BookingListController(ref.watch(bookingApiProvider));
    });
