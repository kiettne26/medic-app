import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/api/api_client.dart';
import 'dto/time_slot_dto.dart';

final timeSlotsApiProvider = Provider(
  (ref) => TimeSlotsApi(ref.watch(apiClientProvider)),
);

class TimeSlotsApi {
  final ApiClient _client;
  final _dateFormat = DateFormat('yyyy-MM-dd');

  TimeSlotsApi(this._client);

  /// Lấy tất cả slots (Admin) - có thể filter theo status và khoảng ngày
  Future<List<TimeSlotDto>> getAllSlots({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (startDate != null) {
      queryParams['startDate'] = _dateFormat.format(startDate);
    }
    if (endDate != null) {
      queryParams['endDate'] = _dateFormat.format(endDate);
    }
    
    final response = await _client.get(
      '/slots/admin/all',
      queryParameters: queryParams,
    );
    
    final rawData = response.data['data'];
    if (rawData == null) return [];
    final data = rawData as List;
    return data.map((e) => TimeSlotDto.fromJson(e)).toList();
  }

  /// Lấy slots chờ duyệt
  Future<List<TimeSlotDto>> getPendingSlots() async {
    final response = await _client.get('/slots/pending');
    
    final rawData = response.data['data'];
    if (rawData == null) return [];
    final data = rawData as List;
    return data.map((e) => TimeSlotDto.fromJson(e)).toList();
  }

  /// Duyệt 1 slot
  Future<TimeSlotDto> approveSlot(String slotId) async {
    final response = await _client.put('/slots/$slotId/approve');
    return TimeSlotDto.fromJson(response.data['data']);
  }

  /// Từ chối 1 slot
  Future<TimeSlotDto> rejectSlot(String slotId) async {
    final response = await _client.put('/slots/$slotId/reject');
    return TimeSlotDto.fromJson(response.data['data']);
  }

  /// Duyệt nhiều slots
  Future<String> approveBulkSlots(List<String> slotIds) async {
    final response = await _client.put('/slots/approve-bulk', data: slotIds);
    return response.data['data'];
  }

  /// Từ chối nhiều slots
  Future<String> rejectBulkSlots(List<String> slotIds) async {
    final response = await _client.put('/slots/reject-bulk', data: slotIds);
    return response.data['data'];
  }
}
