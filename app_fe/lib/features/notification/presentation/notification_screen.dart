import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/dto/notification_dto.dart';
import 'notification_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Tự động làm mới danh sách khi mở trang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).refresh();
    });
  }

  IconData _getIconForType(String type) {
    final normalizedType = type.toUpperCase();
    if (_isCancellationType(normalizedType)) return Icons.event_busy_outlined;
    if (_isReminderType(normalizedType)) return Icons.alarm_outlined;
    if (_isBookingType(normalizedType)) return Icons.event_available_outlined;
    return Icons.info_outline;
  }

  Color _getColorForType(String type) {
    final normalizedType = type.toUpperCase();
    if (_isCancellationType(normalizedType)) return const Color(0xFFEF4444);
    if (_isReminderType(normalizedType)) return const Color(0xFF3982EF);
    if (_isBookingType(normalizedType)) return const Color(0xFF00A86B);
    return const Color(0xFF7C3AED);
  }

  String _formatTime(String createdAtStr) {
    try {
      final dateTime = DateTime.parse(createdAtStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) return 'Vừa xong';
      if (difference.inMinutes < 60) return '${difference.inMinutes} phút trước';
      if (difference.inHours < 24) return '${difference.inHours} giờ trước';
      if (difference.inDays == 1) return 'Hôm qua';
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (_) {
      return 'Vừa xong';
    }
  }

  bool _isToday(String createdAtStr) {
    try {
      final dateTime = DateTime.parse(createdAtStr).toLocal();
      final now = DateTime.now();
      return dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day;
    } catch (_) {
      return true;
    }
  }

  bool _isBookingType(String type) {
    return type == 'BOOKING' ||
        type == 'BOOKING_CREATED' ||
        type == 'BOOKING_CONFIRMED';
  }

  bool _isReminderType(String type) => type == 'REMINDER';

  bool _isCancellationType(String type) {
    return type == 'BOOKING_CANCELLED' || type == 'BOOKING_CANCELED';
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Thông báo',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: unreadCount == 0
                ? null
                : () => ref.read(notificationProvider.notifier).markAllAsRead(),
            child: const Text(
              'Đọc tất cả',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: notificationState.when(
        data: (list) => RefreshIndicator(
          onRefresh: () => ref.read(notificationProvider.notifier).refresh(),
          child: _buildNotificationList(list),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Lỗi tải thông báo: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(notificationProvider.notifier).refresh(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationDto> notifications) {
    final colorScheme = Theme.of(context).colorScheme;

    if (notifications.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant.withOpacity(0.35),
              ),
              const SizedBox(height: 16),
              Text(
                'Không có thông báo nào',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final todayNotifications = notifications
        .where((n) => _isToday(n.createdAt))
        .toList();
    final olderNotifications = notifications
        .where((n) => !_isToday(n.createdAt))
        .toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        if (todayNotifications.isNotEmpty) ...[
          _buildSectionHeader('Hôm nay'),
          ...todayNotifications.map(_buildNotificationItem),
        ],
        if (olderNotifications.isNotEmpty) ...[
          _buildSectionHeader('Trước đó'),
          ...olderNotifications.map(_buildNotificationItem),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationDto notification) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = _getColorForType(notification.type);
    final unreadBackground = colorScheme.brightness == Brightness.dark
        ? const Color(0xFF172554)
        : const Color(0xFFF0F6FF);

    return InkWell(
      onTap: () {
        if (!notification.isRead) {
          ref.read(notificationProvider.notifier).markAsRead(notification.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? colorScheme.surface : unreadBackground,
          border: Border(
            bottom: BorderSide(color: colorScheme.outline.withOpacity(0.12)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForType(notification.type),
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (!notification.isRead) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
