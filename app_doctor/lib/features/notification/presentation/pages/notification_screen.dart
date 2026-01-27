import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Mock data
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Lịch hẹn mới',
      'body': 'Bệnh nhân Nguyễn Văn A đã đặt lịch hẹn khám vào 14:00 ngày mai.',
      'time': DateTime.now().subtract(const Duration(minutes: 10)),
      'isRead': false,
      'type': 'APPOINTMENT',
    },
    {
      'id': '2',
      'title': 'Nhắc nhở',
      'body': 'Bạn có cuộc họp lúc 16:00 hôm nay.',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
      'type': 'REMINDER',
    },
    {
      'id': '3',
      'title': 'Đánh giá mới',
      'body': 'Bệnh nhân Trần Thị B đã đánh giá 5 sao cho bạn.',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
      'type': 'REVIEW',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tất cả thông báo',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF101418),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (var n in _notifications) {
                        n['isRead'] = true;
                      }
                    });
                  },
                  child: Text(
                    'Đánh dấu đã đọc',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF297EFF),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Container(
                  color: notification['isRead']
                      ? Colors.transparent
                      : Colors.blue[50],
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIcon(notification['type']),
                        color: const Color(0xFF297EFF),
                        size: 20,
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: const Color(0xFF101418),
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(notification['time']),
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        notification['body'],
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          color: const Color(0xFF5E718D),
                          height: 1.4,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        notification['isRead'] = true;
                      });
                      // Handle navigation if needed
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'APPOINTMENT':
        return Icons.calendar_today;
      case 'REVIEW':
        return Icons.star;
      case 'REMINDER':
        return Icons.access_time;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate = DateTime(time.year, time.month, time.day);

    if (notificationDate == today) {
      return DateFormat('HH:mm').format(time);
    } else if (notificationDate == today.subtract(const Duration(days: 1))) {
      return 'Hôm qua';
    } else {
      return DateFormat('dd/MM').format(time);
    }
  }
}
