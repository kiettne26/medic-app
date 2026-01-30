import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/data/dto/medical_service_dto.dart';
import '../../services/data/services_api.dart';

final servicesControllerProvider =
    AsyncNotifierProvider<ServicesController, List<MedicalServiceDto>>(() {
      return ServicesController();
    });

class ServicesController extends AsyncNotifier<List<MedicalServiceDto>> {
  @override
  FutureOr<List<MedicalServiceDto>> build() async {
    return _fetchServices();
  }

  Future<List<MedicalServiceDto>> _fetchServices() async {
    final api = ref.read(servicesApiProvider);
    return api.getServices();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchServices());
  }

  Future<void> createService(Map<String, dynamic> data) async {
    final api = ref.read(servicesApiProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.createService(data);
      return _fetchServices();
    });
  }

  Future<void> updateService(String id, Map<String, dynamic> data) async {
    final api = ref.read(servicesApiProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.updateService(id, data);
      return _fetchServices();
    });
  }

  Future<void> deleteService(String id) async {
    final api = ref.read(servicesApiProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.deleteService(id);
      return _fetchServices();
    });
  }

  Future<void> toggleService(String id) async {
    final api = ref.read(servicesApiProvider);
    // Optimistic update or loading? Loading for safety.
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await api.toggleService(id);
      return _fetchServices();
    });
  }
}
