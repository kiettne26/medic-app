import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dto/doctor_dto.dart';
import 'source/doctor_api.dart';

class DoctorRepository {
  final DoctorApi _api;

  DoctorRepository(this._api);

  Future<List<DoctorDto>> getAllDoctors() => _api.getAllDoctors();

  Future<List<DoctorDto>> getAvailableDoctors() => _api.getAvailableDoctors();

  Future<DoctorDto> getDoctorById(String id) => _api.getDoctorById(id);

  Future<List<DoctorDto>> getDoctorsBySpecialty(String specialty) =>
      _api.getDoctorsBySpecialty(specialty);

  Future<List<DoctorDto>> searchDoctors(String query) =>
      _api.searchDoctors(query);

  Future<List<DoctorDto>> getDoctorsByService(String serviceId) =>
      _api.getDoctorsByService(serviceId);
}

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepository(ref.watch(doctorApiProvider));
});
