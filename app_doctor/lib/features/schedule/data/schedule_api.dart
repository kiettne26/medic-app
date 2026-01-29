import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/network/dio_provider.dart';
import 'dto/schedule_dto.dart';

/// API service cho schedule/time slots
class ScheduleApi {
  final Dio _dio;

  ScheduleApi(this._dio);

  /// Lấy danh sách time slots của bác sĩ theo tuần
  Future<List<ScheduleSlotDto>> getTimeSlots({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.get(
        '/api/slots/doctor/week',
        queryParameters: {
          'startDate': DateFormat('yyyy-MM-dd').format(startDate),
          'endDate': DateFormat('yyyy-MM-dd').format(endDate),
        },
      );

      if (response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ScheduleSlotDto.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      // Log chi tiết lỗi để debug
      print(
        '[ScheduleApi] DioException: ${e.type}, Status: ${e.response?.statusCode}, Message: ${e.message}',
      );
      print('[ScheduleApi] Response data: ${e.response?.data}');

      final statusCode = e.response?.statusCode;
      final serverMessage = e.response?.data?['message'];
      final errorMsg =
          serverMessage ??
          (statusCode != null
              ? 'Lỗi server ($statusCode)'
              : 'Không thể kết nối đến server');

      throw Exception(errorMsg);
    }
  }

  /// Tạo time slot mới
  Future<ScheduleSlotDto> createTimeSlot(
    CreateScheduleSlotRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/slots',
        data: {
          'date': DateFormat('yyyy-MM-dd').format(request.date),
          'startTime': request.startTime,
          'endTime': request.endTime,
        },
      );

      return ScheduleSlotDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Không thể tạo khung giờ',
      );
    }
  }

  /// Xóa time slot
  Future<void> deleteTimeSlot(String slotId) async {
    try {
      await _dio.delete('/api/slots/$slotId');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Không thể xóa khung giờ',
      );
    }
  }
}

/// Provider cho ScheduleApi
final scheduleApiProvider = Provider<ScheduleApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ScheduleApi(dio);
});
