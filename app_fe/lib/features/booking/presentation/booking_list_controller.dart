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
      final now = DateTime.now();

      for (final booking in allBookings) {
        final status = booking.status?.toUpperCase() ?? '';
        if (status == 'COMPLETED' || status == 'CANCELLED') {
          completed.add(booking);
          continue;
        }

        // Kiểm tra xem lịch hẹn đã trôi qua chưa dựa trên timeSlot
        final ts = booking.timeSlot;
        if (ts != null) {
          try {
            final date = ts.date;
            final parts = ts.startTime.split(':');
            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1]);
            final slotDateTime = DateTime(
              date.year,
              date.month,
              date.day,
              hour,
              minute,
            );
            if (slotDateTime.isBefore(now)) {
              completed.add(booking); // Cho vào danh sách đã qua nếu quá giờ hẹn
              continue;
            }
          } catch (e) {
            // Dự phòng: chỉ so sánh ngày
            if (ts.date.isBefore(now.subtract(const Duration(days: 1)))) {
              completed.add(booking);
              continue;
            }
          }
        }

        upcoming.add(booking);
      }

      // Sắp xếp: lịch sắp tới gần nhất lên đầu
      upcoming.sort((a, b) {
        final tsA = a.timeSlot;
        final tsB = b.timeSlot;
        if (tsA == null || tsB == null) return 0;
        return tsA.date.compareTo(tsB.date);
      });

      // Sắp xếp: lịch sử mới nhất lên đầu
      completed.sort((a, b) {
        final tsA = a.timeSlot;
        final tsB = b.timeSlot;
        if (tsA == null || tsB == null) return 0;
        return tsB.date.compareTo(tsA.date);
      });

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
