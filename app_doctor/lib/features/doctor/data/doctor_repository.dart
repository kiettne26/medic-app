import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dto/doctor_dto.dart';
import 'source/doctor_api.dart';

class DoctorRepository {
  final DoctorApi _api;

  DoctorRepository(this._api);

  Future<DoctorDto?> getDoctorByUserId(String userId) {
    return _api.getDoctorByUserId(userId);
  }

  Future<DoctorDto?> updateDoctor(String id, Map<String, dynamic> data) {
    return _api.updateDoctor(id, data);
  }
}

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  final api = ref.watch(doctorApiProvider);
  return DoctorRepository(api);
});
