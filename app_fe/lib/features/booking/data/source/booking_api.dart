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
    try {
      final response = await _dio.get(
        '/api/slots/available',
        queryParameters: {'doctorId': doctorId, 'date': date},
      );

      // Response format: { "success": true, "data": [...] }
      final data = response.data['data'] as List;
      return data.map((json) => TimeSlotDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw BookingApiException(
        _extractErrorMessage(
          e,
          fallback: 'KhÃ´ng thá»ƒ táº£i lá»‹ch. Vui lÃ²ng thá»­ láº¡i.',
        ),
      );
    }
  }

  Future<BookingDto> createBooking(CreateBookingRequest request) async {
    try {
      final response = await _dio.post('/api/bookings', data: request.toJson());

      // Response format: { "success": true, "data": { ... } }
      return BookingDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw BookingApiException(
        _extractErrorMessage(
          e,
          fallback: 'KhÃ´ng thá»ƒ Ä‘áº·t lá»‹ch. Vui lÃ²ng thá»­ láº¡i.',
        ),
      );
    }
  }

  /// Láº¥y danh sÃ¡ch bookings cá»§a user hiá»‡n táº¡i
  Future<PaymentInitDto> initiatePayment(
    String bookingId,
    InitiatePaymentRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/bookings/$bookingId/payment/initiate',
        data: request.toJson(),
      );

      return PaymentInitDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw BookingApiException(
        _extractErrorMessage(
          e,
          fallback:
              'KhÃƒÂ´ng thÃ¡Â»Æ’ tÃ¡ÂºÂ¡o thanh toÃƒÂ¡n. Vui lÃƒÂ²ng thÃ¡Â»Â­ lÃ¡ÂºÂ¡i.',
        ),
      );
    }
  }

  Future<BookingDto> refreshPaymentStatus(String bookingId) async {
    try {
      final response = await _dio.get(
        '/api/bookings/$bookingId/payment/status',
      );
      return BookingDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw BookingApiException(
        _extractErrorMessage(
          e,
          fallback:
              'KhÃƒÂ´ng thÃ¡Â»Æ’ kiÃ¡Â»Æ’m tra thanh toÃƒÂ¡n. Vui lÃƒÂ²ng thÃ¡Â»Â­ lÃ¡ÂºÂ¡i.',
        ),
      );
    }
  }

  Future<List<BookingDto>> getMyBookings() async {
    final response = await _dio.get('/api/bookings/patient');

    // Response format: { "success": true, "data": { "content": [...], ... } }
    final data = response.data['data'];
    if (data == null) return [];

    final List content = data['content'] as List? ?? [];
    return content.map((json) => BookingDto.fromJson(json)).toList();
  }

  Future<BookingDto> cancelBooking(String bookingId, String reason) async {
    try {
      final response = await _dio.put(
        '/api/bookings/$bookingId/cancel',
        data: {'reason': reason},
      );
      return BookingDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw BookingApiException(
        _extractErrorMessage(
          e,
          fallback: 'Không thể hủy lịch khám. Vui lòng thử lại.',
        ),
      );
    }
  }
}

class BookingApiException implements Exception {
  final String message;

  BookingApiException(this.message);

  @override
  String toString() => message;
}

String _extractErrorMessage(DioException error, {required String fallback}) {
  final data = error.response?.data;
  if (data is Map<String, dynamic>) {
    final message = data['message'] ?? data['error'] ?? data['errorMessage'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
  }

  if (error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    return 'KhÃ´ng thá»ƒ káº¿t ná»‘i mÃ¡y chá»§. Vui lÃ²ng thá»­ láº¡i.';
  }

  return fallback;
}

final bookingApiProvider = Provider<BookingApi>((ref) {
  final dio = ref.watch(dioProvider);
  return BookingApi(dio);
});
