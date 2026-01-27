import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/doctor_repository.dart';
import '../data/dto/doctor_dto.dart';

class DoctorController extends StateNotifier<AsyncValue<DoctorDto?>> {
  final DoctorRepository _repository;
  final _storage = const FlutterSecureStorage();

  DoctorController(this._repository) : super(const AsyncValue.loading()) {
    getDoctor();
  }

  Future<void> getDoctor() async {
    try {
      state = const AsyncValue.loading();
      final userId = await _storage.read(key: 'user_id');
      if (userId != null) {
        final doctor = await _repository.getDoctorByUserId(userId);
        state = AsyncValue.data(doctor);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateDoctor(Map<String, dynamic> data) async {
    // Only update if we have a loaded doctor
    if (!state.hasValue || state.value == null) return;

    try {
      final currentDoctor = state.value!;
      // Optimistic update could happen here, but for now we'll wait for API
      final updatedDoctor = await _repository.updateDoctor(
        currentDoctor.id,
        data,
      );
      if (updatedDoctor != null) {
        state = AsyncValue.data(updatedDoctor);
      }
    } catch (e, st) {
      // Handle error (maybe show notification)
      // state = AsyncValue.error(e, st); // Don't reset state to error, just show toast?
      // For now, let's just log it or rethrow if we want UI to know
      print('Update failed: $e');
    }
  }
}

final doctorControllerProvider =
    StateNotifierProvider<DoctorController, AsyncValue<DoctorDto?>>((ref) {
      final repository = ref.watch(doctorRepositoryProvider);
      return DoctorController(repository);
    });
