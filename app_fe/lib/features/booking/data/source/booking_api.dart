import 'package:dio/dio.dart';
import '../dto/booking_dto.dart';
import '../../../../core/network/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingApi {
  final Dio _dio;

  BookingApi(this._dio);

  Future<List<TimeSlotDto>> getAvailableSlots(
    String doctorId,
    String date,
  ) async {
    final response = await _dio.get(
      '/api/slots/available',
      queryParameters: {'doctorId': doctorId, 'date': date},
    );

    // Response format: { "success": true, "data": [...] }
    final data = response.data['data'] as List;
    return data.map((json) => TimeSlotDto.fromJson(json)).toList();
  }

  Future<BookingDto> createBooking(CreateBookingRequest request) async {
    final response = await _dio.post('/api/bookings', data: request.toJson());

    // Response format: { "success": true, "data": { ... } }
    return BookingDto.fromJson(response.data['data']);
  }

  /// Lấy danh sách bookings của user hiện tại
  Future<List<BookingDto>> getMyBookings() async {
    final response = await _dio.get('/api/bookings/my');

    // Response format: { "success": true, "data": [...] }
    final data = response.data['data'] as List? ?? [];
    return data.map((json) => BookingDto.fromJson(json)).toList();
  }
}

final bookingApiProvider = Provider<BookingApi>((ref) {
  final dio = ref.watch(dioProvider);
  return BookingApi(dio);
});
