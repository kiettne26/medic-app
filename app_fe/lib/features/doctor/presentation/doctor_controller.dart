import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dto/doctor_dto.dart';
import '../data/doctor_repository.dart';

/// State cho Doctor list
class DoctorState {
  final List<DoctorDto> doctors;
  final List<DoctorDto> filteredDoctors;
  final bool isLoading;
  final String? errorMessage;
  final String selectedCategory;
  final String searchQuery;

  DoctorState({
    this.doctors = const [],
    this.filteredDoctors = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedCategory = 'Tất cả',
    this.searchQuery = '',
  });

  DoctorState copyWith({
    List<DoctorDto>? doctors,
    List<DoctorDto>? filteredDoctors,
    bool? isLoading,
    String? errorMessage,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return DoctorState(
      doctors: doctors ?? this.doctors,
      filteredDoctors: filteredDoctors ?? this.filteredDoctors,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Controller cho Doctor list
class DoctorController extends StateNotifier<DoctorState> {
  final DoctorRepository _repository;

  DoctorController(this._repository) : super(DoctorState()) {
    loadDoctors();
  }

  /// Load tất cả bác sĩ từ API
  Future<void> loadDoctors() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final doctors = await _repository.getAllDoctors();
      state = state.copyWith(
        doctors: doctors,
        filteredDoctors: doctors,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải danh sách bác sĩ: $e',
      );
    }
  }

  /// Load bác sĩ theo dịch vụ
  Future<void> loadDoctorsByService(String serviceId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final doctors = await _repository.getDoctorsByService(serviceId);
      state = state.copyWith(
        doctors: doctors,
        filteredDoctors: doctors,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải danh sách bác sĩ theo dịch vụ: $e',
      );
    }
  }

  /// Lọc theo chuyên khoa
  void filterByCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    _applyFilters();
  }

  /// Tìm kiếm bác sĩ
  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  /// Áp dụng filters (category + search)
  void _applyFilters() {
    var filtered = state.doctors;

    // Filter by category
    if (state.selectedCategory != 'Tất cả') {
      filtered = filtered.where((d) {
        final specialty = d.specialty?.toLowerCase() ?? '';
        final category = state.selectedCategory.toLowerCase();
        return specialty.contains(category);
      }).toList();
    }

    // Filter by search query
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((d) {
        final name = d.fullName?.toLowerCase() ?? '';
        final specialty = d.specialty?.toLowerCase() ?? '';
        return name.contains(query) || specialty.contains(query);
      }).toList();
    }

    state = state.copyWith(filteredDoctors: filtered);
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadDoctors();
  }
}

/// Provider cho DoctorController
final doctorControllerProvider =
    StateNotifierProvider<DoctorController, DoctorState>((ref) {
      return DoctorController(ref.watch(doctorRepositoryProvider));
    });
