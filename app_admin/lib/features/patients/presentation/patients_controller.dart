import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dto/patient_dto.dart';
import '../data/patients_api.dart';

final patientsControllerProvider =
    AsyncNotifierProvider<PatientsController, List<PatientDto>>(() {
      return PatientsController();
    });

class PatientsController extends AsyncNotifier<List<PatientDto>> {
  @override
  FutureOr<List<PatientDto>> build() async {
    return _fetchPatients();
  }

  Future<List<PatientDto>> _fetchPatients({String? search}) async {
    final api = ref.read(patientsApiProvider);
    return api.getPatients(search: search);
  }

  Future<void> refresh({String? search}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPatients(search: search));
  }

  Future<void> updatePatient(String userId, Map<String, dynamic> data) async {
    final api = ref.read(patientsApiProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.updatePatient(userId, data);
      return _fetchPatients();
    });
  }

  Future<void> deletePatient(String userId) async {
    final api = ref.read(patientsApiProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.deletePatient(userId);
      return _fetchPatients();
    });
  }
}
