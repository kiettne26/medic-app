import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_fe/features/doctor/data/dto/doctor_dto.dart';
import 'package:app_fe/features/doctor/data/doctor_repository.dart';
import 'package:app_fe/features/booking/data/dto/booking_dto.dart';
import 'package:app_fe/features/booking/data/booking_repository.dart';

/// State cho Home Screen
class HomeState {
  final List<DoctorDto> featuredDoctors;
  final BookingDto? upcomingBooking;
  final bool isLoading;
  final String? errorMessage;

  HomeState({
    this.featuredDoctors = const [],
    this.upcomingBooking,
    this.isLoading = false,
    this.errorMessage,
  });

  HomeState copyWith({
    List<DoctorDto>? featuredDoctors,
    BookingDto? upcomingBooking,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      featuredDoctors: featuredDoctors ?? this.featuredDoctors,
      upcomingBooking: upcomingBooking ?? this.upcomingBooking,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Controller cho Home Screen
class HomeController extends StateNotifier<HomeState> {
  final DoctorRepository _doctorRepository;
  final BookingRepository _bookingRepository;

  HomeController(this._doctorRepository, this._bookingRepository)
    : super(HomeState()) {
    loadHomeData();
  }

  /// Load tất cả dữ liệu cho Home Screen
  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Load featured doctors (top 5 doctors)
      final doctors = await _doctorRepository.getAllDoctors();
      final featuredDoctors = doctors.take(5).toList();

      // Load upcoming booking từ API
      BookingDto? upcomingBooking;
      try {
        final bookings = await _bookingRepository.getMyBookings();
        final now = DateTime.now();
        // Lọc các booking có status PENDING hoặc CONFIRMED và chưa qua thời gian khám
        final upcomingBookings = bookings.where((b) {
          final status = b.status?.toUpperCase();
          if (status != 'PENDING' && status != 'CONFIRMED') {
            return false;
          }

          final ts = b.timeSlot;
          if (ts == null) return false;

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
            return slotDateTime.isAfter(now);
          } catch (e) {
            // Dự phòng: so sánh ngày
            return ts.date.isAfter(now.subtract(const Duration(days: 1)));
          }
        }).toList();

        // Sắp xếp theo ngày giờ gần nhất và lấy booking đầu tiên
        if (upcomingBookings.isNotEmpty) {
          upcomingBookings.sort((a, b) {
            final tsA = a.timeSlot;
            final tsB = b.timeSlot;
            if (tsA == null || tsB == null) return 0;

            try {
              final dateA = tsA.date;
              final partsA = tsA.startTime.split(':');
              final hourA = int.parse(partsA[0]);
              final minuteA = int.parse(partsA[1]);
              final dateTimeA = DateTime(dateA.year, dateA.month, dateA.day, hourA, minuteA);

              final dateB = tsB.date;
              final partsB = tsB.startTime.split(':');
              final hourB = int.parse(partsB[0]);
              final minuteB = int.parse(partsB[1]);
              final dateTimeB = DateTime(dateB.year, dateB.month, dateB.day, hourB, minuteB);

              return dateTimeA.compareTo(dateTimeB);
            } catch (e) {
              return tsA.date.compareTo(tsB.date);
            }
          });
          upcomingBooking = upcomingBookings.first;
        }
      } catch (e) {
        // Ignore booking fetch errors, just show no upcoming booking
      }

      state = state.copyWith(
        featuredDoctors: featuredDoctors,
        upcomingBooking: upcomingBooking,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải dữ liệu: $e',
      );
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadHomeData();
  }
}

/// Provider cho HomeController
final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  (ref) {
    return HomeController(
      ref.watch(doctorRepositoryProvider),
      ref.watch(bookingRepositoryProvider),
    );
  },
);
