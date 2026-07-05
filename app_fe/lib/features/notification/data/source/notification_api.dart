import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_fe/core/network/dio_provider.dart';
import '../dto/notification_dto.dart';

class NotificationApi {
  final Dio _dio;

  NotificationApi(this._dio);

  /// Lấy danh sách thông báo của user (phân trang)
  Future<List<NotificationDto>> getUserNotifications({int page = 0, int size = 50}) async {
    try {
      final response = await _dio.get(
        '/api/notifications',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );
      
      final data = response.data['data'];
      if (data == null || data['content'] == null) return [];
      
      final list = data['content'] as List;
      return list.map((item) => NotificationDto.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  /// Đánh dấu một thông báo đã đọc
  Future<bool> markAsRead(String id) async {
    try {
      final response = await _dio.put('/api/notifications/$id/read');
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification $id as read: $e');
      return false;
    }
  }

  /// Đánh dấu tất cả thông báo đã đọc
  Future<bool> markAllAsRead() async {
    try {
      final response = await _dio.put('/api/notifications/read-all');
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }
}

final notificationApiProvider = Provider<NotificationApi>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationApi(dio);
});
