import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dto/notification_dto.dart';
import '../data/notification_repository.dart';

class NotificationNotifier
    extends StateNotifier<AsyncValue<List<NotificationDto>>> {
  final NotificationRepository _repository;

  NotificationNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      state = const AsyncValue.loading();
      final list = await _repository.getUserNotifications();
      state = AsyncValue.data(list);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    try {
      final list = await _repository.getUserNotifications();
      state = AsyncValue.data(list);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> markAsRead(String id) async {
    final currentList = state.value;
    if (currentList == null) return;

    // Optimistic update
    state = AsyncValue.data(
      currentList.map((n) {
        if (n.id == id) {
          return NotificationDto(
            id: n.id,
            userId: n.userId,
            title: n.title,
            message: n.message,
            type: n.type,
            relatedId: n.relatedId,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList(),
    );

    // Call API
    final success = await _repository.markAsRead(id);
    if (!success) {
      // Revert or reload if failed
      refresh();
    }
  }

  Future<void> markAllAsRead() async {
    final currentList = state.value;
    if (currentList == null) return;

    // Optimistic update
    state = AsyncValue.data(
      currentList.map((n) {
        return NotificationDto(
          id: n.id,
          userId: n.userId,
          title: n.title,
          message: n.message,
          type: n.type,
          relatedId: n.relatedId,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList(),
    );

    // Call API
    final success = await _repository.markAllAsRead();
    if (!success) {
      refresh();
    }
  }
}

final notificationProvider =
    StateNotifierProvider<
      NotificationNotifier,
      AsyncValue<List<NotificationDto>>
    >((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return NotificationNotifier(repository);
    });

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notificationState = ref.watch(notificationProvider);
  return notificationState.maybeWhen(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
