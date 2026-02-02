import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dto/booking_dto.dart';
import '../data/bookings_api.dart';
import '../../auth/presentation/auth_controller.dart';

/// State cho trang Bookings
class BookingsState {
  final List<BookingDto> bookings;
  final BookingStatsDto stats;
  final List<DoctorSimpleDto> doctors;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final int pageSize;
  
  // Filters
  final String? statusFilter;
  final String? doctorFilter;
  final String? dateFilter;
  final String? searchQuery;

  const BookingsState({
    this.bookings = const [],
    this.stats = const BookingStatsDto(),
    this.doctors = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 0,
    this.totalPages = 0,
    this.totalElements = 0,
    this.pageSize = 10,
    this.statusFilter,
    this.doctorFilter,
    this.dateFilter,
    this.searchQuery,
  });

  BookingsState copyWith({
    List<BookingDto>? bookings,
    BookingStatsDto? stats,
    List<DoctorSimpleDto>? doctors,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalElements,
    int? pageSize,
    String? statusFilter,
    String? doctorFilter,
    String? dateFilter,
    String? searchQuery,
  }) {
    return BookingsState(
      bookings: bookings ?? this.bookings,
      stats: stats ?? this.stats,
      doctors: doctors ?? this.doctors,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      pageSize: pageSize ?? this.pageSize,
      statusFilter: statusFilter ?? this.statusFilter,
      doctorFilter: doctorFilter ?? this.doctorFilter,
      dateFilter: dateFilter ?? this.dateFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final bookingsControllerProvider =
    StateNotifierProvider<BookingsController, BookingsState>((ref) {
  final api = ref.watch(bookingsApiProvider);
  final authState = ref.watch(authControllerProvider);
  return BookingsController(api, authState.userId ?? '');
});

class BookingsController extends StateNotifier<BookingsState> {
  final BookingsApi _api;
  final String _adminUserId;

  BookingsController(this._api, this._adminUserId) : super(const BookingsState()) {
    // Load initial data
    loadInitialData();
  }

  /// Load dữ liệu ban đầu (stats, doctors, bookings)
  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Load all data in parallel
      final results = await Future.wait([
        _api.getBookingStats(),
        _api.getDoctorsForFilter(),
        _api.getBookings(page: 0, size: state.pageSize),
      ]);

      final stats = results[0] as BookingStatsDto;
      final doctors = results[1] as List<DoctorSimpleDto>;
      final pageDto = results[2] as BookingPageDto;

      state = state.copyWith(
        stats: stats,
        doctors: doctors,
        bookings: pageDto.content,
        totalElements: pageDto.totalElements,
        totalPages: pageDto.totalPages,
        currentPage: pageDto.currentPage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh bookings với filters hiện tại
  Future<void> refresh() async {
    await _fetchBookings();
  }

  /// Fetch bookings với filters
  Future<void> _fetchBookings({int? page}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final pageDto = await _api.getBookings(
        status: state.statusFilter,
        doctorId: state.doctorFilter,
        date: state.dateFilter,
        search: state.searchQuery,
        page: page ?? state.currentPage,
        size: state.pageSize,
      );

      // Also refresh stats
      final stats = await _api.getBookingStats();

      state = state.copyWith(
        bookings: pageDto.content,
        stats: stats,
        totalElements: pageDto.totalElements,
        totalPages: pageDto.totalPages,
        currentPage: pageDto.currentPage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Cập nhật filter trạng thái
  void setStatusFilter(String? status) {
    state = state.copyWith(
      statusFilter: status == 'ALL' ? null : status,
      currentPage: 0,
    );
    _fetchBookings(page: 0);
  }

  /// Cập nhật filter bác sĩ
  void setDoctorFilter(String? doctorId) {
    state = state.copyWith(
      doctorFilter: doctorId,
      currentPage: 0,
    );
    _fetchBookings(page: 0);
  }

  /// Cập nhật filter ngày
  void setDateFilter(String? date) {
    state = state.copyWith(
      dateFilter: date,
      currentPage: 0,
    );
    _fetchBookings(page: 0);
  }

  /// Cập nhật search query
  void setSearchQuery(String? query) {
    state = state.copyWith(
      searchQuery: query,
      currentPage: 0,
    );
    _fetchBookings(page: 0);
  }

  /// Áp dụng tất cả filters (khi nhấn nút Lọc)
  void applyFilters({
    String? status,
    String? doctorId,
    String? date,
  }) {
    state = state.copyWith(
      statusFilter: status == 'ALL' ? null : status,
      doctorFilter: doctorId,
      dateFilter: date,
      currentPage: 0,
    );
    _fetchBookings(page: 0);
  }

  /// Reset tất cả filters
  void resetFilters() {
    state = state.copyWith(
      statusFilter: null,
      doctorFilter: null,
      dateFilter: null,
      searchQuery: null,
      currentPage: 0,
    );
    _fetchBookings(page: 0);
  }

  /// Chuyển trang
  void goToPage(int page) {
    if (page < 0 || page >= state.totalPages) return;
    state = state.copyWith(currentPage: page);
    _fetchBookings(page: page);
  }

  /// Trang trước
  void previousPage() {
    if (state.currentPage > 0) {
      goToPage(state.currentPage - 1);
    }
  }

  /// Trang sau
  void nextPage() {
    if (state.currentPage < state.totalPages - 1) {
      goToPage(state.currentPage + 1);
    }
  }

  /// Xác nhận lịch hẹn
  Future<bool> confirmBooking(String id) async {
    try {
      await _api.confirmBooking(id, _adminUserId);
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Không thể xác nhận lịch hẹn: ${e.toString()}');
      return false;
    }
  }

  /// Hoàn thành lịch hẹn
  Future<bool> completeBooking(String id) async {
    try {
      await _api.completeBooking(id, _adminUserId);
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Không thể hoàn thành lịch hẹn: ${e.toString()}');
      return false;
    }
  }

  /// Hủy lịch hẹn
  Future<bool> cancelBooking(String id, {String? reason}) async {
    try {
      await _api.cancelBooking(id, _adminUserId, reason: reason);
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Không thể hủy lịch hẹn: ${e.toString()}');
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
