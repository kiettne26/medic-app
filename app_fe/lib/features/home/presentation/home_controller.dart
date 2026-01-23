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
      // Load featured doctors (top 5 available doctors)
      final doctors = await _doctorRepository.getAvailableDoctors();
      final featuredDoctors = doctors.take(5).toList();

      // Load upcoming booking từ API
      BookingDto? upcomingBooking;
      try {
        final bookings = await _bookingRepository.getMyBookings();
        // Lọc các booking có status PENDING hoặc CONFIRMED
        final upcomingBookings = bookings.where((b) {
          final status = b.status?.toUpperCase();
          return status == 'PENDING' || status == 'CONFIRMED';
        }).toList();

        // Sắp xếp theo ngày gần nhất và lấy booking đầu tiên
        if (upcomingBookings.isNotEmpty) {
          upcomingBookings.sort((a, b) {
            final dateA = a.timeSlot?.date ?? DateTime.now();
            final dateB = b.timeSlot?.date ?? DateTime.now();
            return dateA.compareTo(dateB);
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
