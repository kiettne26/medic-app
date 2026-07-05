import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'source/notification_api.dart';
import 'dto/notification_dto.dart';

class NotificationRepository {
  final NotificationApi _notificationApi;

  NotificationRepository(this._notificationApi);

  Future<List<NotificationDto>> getUserNotifications() async {
    return await _notificationApi.getUserNotifications();
  }

  Future<bool> markAsRead(String id) async {
    return await _notificationApi.markAsRead(id);
  }

  Future<bool> markAllAsRead() async {
    return await _notificationApi.markAllAsRead();
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final api = ref.watch(notificationApiProvider);
  return NotificationRepository(api);
});
