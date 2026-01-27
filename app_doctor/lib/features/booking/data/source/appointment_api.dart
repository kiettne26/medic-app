import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../dto/booking_dto.dart';

class AppointmentApi {
  final Dio _dio;

  AppointmentApi(this._dio);

  Future<List<BookingDto>> getAppointments() async {
    try {
      // Calling GET /bookings/doctor
      final response = await _dio.get('/api/bookings/doctor');
      final data = response.data['data']['content'] as List<dynamic>;
      return data.map((e) => BookingDto.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> confirmBooking(String id) async {
    await _dio.put('/api/bookings/$id/confirm');
  }

  Future<void> completeBooking(String id, String? notes) async {
    await _dio.put(
      '/api/bookings/$id/complete',
      queryParameters: notes != null ? {'doctorNotes': notes} : null,
    );
  }

  Future<void> cancelBooking(String id, String reason) async {
    await _dio.put('/api/bookings/$id/cancel', data: {'reason': reason});
  }
}

final appointmentApiProvider = Provider<AppointmentApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AppointmentApi(dio);
});
