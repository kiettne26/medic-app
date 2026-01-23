import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dummy data - sẽ được thay bằng API sau
  final List<NotificationItem> _allNotifications = [
    NotificationItem(
      id: '1',
      type: NotificationType.appointment,
      title: 'Xác nhận lịch hẹn mới',
      message:
          'Lịch hẹn khám của bạn với BS. Nguyễn Văn A vào lúc 09:00 ngày mai đã được xác nhận thành công.',
      timeAgo: '5 phút',
      isRead: false,
      isToday: true,
    ),
    NotificationItem(
      id: '2',
      type: NotificationType.medication,
      title: 'Nhắc nhở uống thuốc',
      message:
          'Đã đến giờ uống thuốc Paracetamol 500mg. Vui lòng uống thuốc sau khi ăn no.',
      timeAgo: '1 giờ',
      isRead: false,
      isToday: true,
    ),
    NotificationItem(
      id: '3',
      type: NotificationType.system,
      title: 'Cập nhật hệ thống',
      message:
          'Ứng dụng vừa được cập nhật phiên bản 2.4.0. Khám phá ngay các tính năng theo dõi sức khỏe mới.',
      timeAgo: 'Hôm qua',
      isRead: true,
      isToday: false,
    ),
    NotificationItem(
      id: '4',
      type: NotificationType.labResult,
      title: 'Kết quả xét nghiệm',
      message:
          'Kết quả xét nghiệm tổng quát của bạn đã có. Nhấp để xem chi tiết và lời khuyên từ bác sĩ.',
      timeAgo: '2 ngày trước',
      isRead: true,
      isToday: false,
    ),
    NotificationItem(
      id: '5',
      type: NotificationType.promotion,
      title: 'Ưu đãi đặc biệt',
      message:
          'Giảm ngay 20% gói khám tầm soát sức khỏe định kỳ cho cả gia đình trong tháng này.',
      timeAgo: '3 ngày trước',
      isRead: true,
      isToday: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<NotificationItem> get _filteredNotifications {
    switch (_tabController.index) {
      case 1: // Hẹn khám
        return _allNotifications
            .where((n) => n.type == NotificationType.appointment)
            .toList();
      case 2: // Nhắc thuốc
        return _allNotifications
            .where((n) => n.type == NotificationType.medication)
            .toList();
      default: // Tất cả
        return _allNotifications;
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _allNotifications) {
        notification.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF111418)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: Color(0xFF111418),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Đọc tất cả',
              style: TextStyle(
                color: Color(0xFF3982EF),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          indicatorColor: const Color(0xFF3982EF),
          indicatorWeight: 2,
          labelColor: const Color(0xFF3982EF),
          unselectedLabelColor: Colors.grey[500],
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Hẹn khám'),
            Tab(text: 'Nhắc thuốc'),
          ],
        ),
      ),
      body: _buildNotificationList(),
    );
  }

  Widget _buildNotificationList() {
    final notifications = _filteredNotifications;

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Không có thông báo nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Chia thông báo theo ngày
    final todayNotifications = notifications.where((n) => n.isToday).toList();
    final olderNotifications = notifications.where((n) => !n.isToday).toList();

    return ListView(
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[400],
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return InkWell(
      onTap: () {
        setState(() {
          notification.isRead = true;
        });
        // TODO: Navigate to notification detail
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: notification.iconBackgroundColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                notification.icon,
                color: notification.iconBackgroundColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Content
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111418),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            notification.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (!notification.isRead) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3982EF),
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
                      color: notification.isRead
                          ? Colors.grey[500]
                          : Colors.grey[600],
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

// Notification types
enum NotificationType { appointment, medication, system, labResult, promotion }

// Notification model
class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String timeAgo;
  bool isRead;
  final bool isToday;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.isRead,
    required this.isToday,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.appointment:
        return Icons.event_available;
      case NotificationType.medication:
        return Icons.medication;
      case NotificationType.system:
        return Icons.info_outline;
      case NotificationType.labResult:
        return Icons.description_outlined;
      case NotificationType.promotion:
        return Icons.card_giftcard;
    }
  }

  Color get iconBackgroundColor {
    switch (type) {
      case NotificationType.appointment:
        return const Color(0xFF00C853);
      case NotificationType.medication:
        return const Color(0xFF3982EF);
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.labResult:
        return const Color(0xFF00C853);
      case NotificationType.promotion:
        return const Color(0xFF3982EF);
    }
  }
}
