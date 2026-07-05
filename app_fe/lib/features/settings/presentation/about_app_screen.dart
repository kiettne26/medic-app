import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  static const _appName = 'MediBook';
  static const _version = '1.2.0';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildAppSummary(context),
                  const SizedBox(height: 16),
                  _buildSectionTitle(context, 'Thông tin ứng dụng'),
                  _buildInfoCard(
                    context,
                    children: const [
                      _InfoRow(label: 'Tên ứng dụng', value: _appName),
                      _InfoRow(label: 'Phiên bản', value: _version),
                      _InfoRow(label: 'Nền tảng', value: 'Android, iOS'),
                      _InfoRow(label: 'Trạng thái', value: 'Đang phát triển'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle(context, 'MediBook hỗ trợ'),
                  _buildFeatureCard(
                    context,
                    icon: Icons.calendar_month_outlined,
                    title: 'Đặt lịch khám',
                    body:
                        'Tìm bác sĩ, chọn dịch vụ, chọn khung giờ phù hợp và theo dõi trạng thái lịch hẹn.',
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    context,
                    icon: Icons.payments_outlined,
                    title: 'Thanh toán',
                    body:
                        'Hỗ trợ thanh toán sau khi đặt lịch bằng các phương thức online được hệ thống cấu hình.',
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    context,
                    icon: Icons.health_and_safety_outlined,
                    title: 'Hồ sơ chăm sóc sức khỏe',
                    body:
                        'Lưu thông tin cá nhân, lịch sử đặt khám và dữ liệu cần thiết cho quá trình chăm sóc.',
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle(context, 'Hỗ trợ'),
                  _buildInfoCard(
                    context,
                    children: const [
                      _InfoRow(
                        label: 'Email',
                        value: 'medibook.support@gmail.com',
                      ),
                      _InfoRow(
                        label: 'Thời gian hỗ trợ',
                        value: '08:00 - 17:00',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Cảm ơn bạn đã sử dụng MediBook.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
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

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.92),
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withOpacity(0.14)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          Expanded(
            child: Text(
              'Về ứng dụng',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAppSummary(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.local_hospital_outlined,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _appName,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ứng dụng đặt lịch khám và quản lý chăm sóc sức khỏe cá nhân.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Text(
        title,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF297EFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF297EFF), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
