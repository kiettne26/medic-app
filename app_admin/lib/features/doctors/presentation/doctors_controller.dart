import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../doctors/data/dto/doctor_dto.dart';
import '../../doctors/data/doctors_api.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

final doctorsControllerProvider =
    AsyncNotifierProvider<DoctorsController, List<DoctorDto>>(() {
      return DoctorsController();
    });

class DoctorsController extends AsyncNotifier<List<DoctorDto>> {
  @override
  FutureOr<List<DoctorDto>> build() async {
    return _fetchDoctors();
  }

  Future<List<DoctorDto>> _fetchDoctors() async {
    final api = ref.read(doctorsApiProvider);
    return api.getDoctors();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchDoctors());
  }

  Future<void> createDoctor(Map<String, dynamic> data) async {
    final api = ref.read(doctorsApiProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.createDoctor(data);
      return _fetchDoctors();
    });
  }

  Future<void> updateDoctor(String id, Map<String, dynamic> data) async {
    final api = ref.read(doctorsApiProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.updateDoctor(id, data);
      return _fetchDoctors();
    });
  }

  Future<void> deleteDoctor(String id) async {
    final api = ref.read(doctorsApiProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.deleteDoctor(id);
      return _fetchDoctors();
    });
  }

  Future<String?> uploadAvatar(XFile file) async {
    final api = ref.read(doctorsApiProvider);
    // Don't set global state loading for avatar upload to avoid table refresh
    try {
      final bytes = await file.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: file.name),
      });
      return await api.uploadAvatar(formData);
    } catch (e) {
      // Handle error gracefully or rethrow
      rethrow;
    }
  }
}
