import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  _buildIntro(colorScheme),
                  const SizedBox(height: 14),
                  _buildSection(
                    context,
                    title: '1. Phạm vi sử dụng',
                    body:
                        'MediBook hỗ trợ người dùng tìm kiếm bác sĩ, đặt lịch khám, nhận thông báo lịch hẹn, trao đổi thông tin liên quan đến quá trình chăm sóc sức khỏe và quản lý hồ sơ cá nhân.',
                  ),
                  _buildSection(
                    context,
                    title: '2. Tài khoản người dùng',
                    body:
                        'Bạn chịu trách nhiệm bảo mật thông tin đăng nhập và tính chính xác của hồ sơ cá nhân. Ứng dụng có thể yêu cầu xác thực email trước khi cho phép đặt lịch nhằm bảo vệ tài khoản và hạn chế đặt lịch sai thông tin.',
                  ),
                  _buildSection(
                    context,
                    title: '3. Đặt lịch và thay đổi lịch',
                    body:
                        'Thông tin lịch khám phụ thuộc vào khung giờ bác sĩ đã mở và trạng thái xác nhận của hệ thống. Bạn nên có mặt trước giờ hẹn và cập nhật thông tin liên hệ chính xác để nhận thông báo kịp thời.',
                  ),
                  _buildSection(
                    context,
                    title: '4. Thanh toán',
                    body:
                        'Một số dịch vụ có thể yêu cầu thanh toán online hoặc thanh toán theo hướng dẫn của cơ sở khám. Trạng thái thanh toán được cập nhật theo kết quả từ cổng thanh toán hoặc quy trình xác nhận nội bộ.',
                  ),
                  _buildSection(
                    context,
                    title: '5. Thông tin y tế',
                    body:
                        'Nội dung trong ứng dụng không thay thế chẩn đoán trực tiếp của bác sĩ. Trong trường hợp khẩn cấp, bạn cần liên hệ cơ sở y tế gần nhất hoặc gọi số cấp cứu phù hợp.',
                  ),
                  _buildSection(
                    context,
                    title: '6. Quyền riêng tư',
                    body:
                        'Dữ liệu cá nhân và dữ liệu y tế được sử dụng để cung cấp dịch vụ đặt lịch, chăm sóc sau khám, thông báo và cải thiện trải nghiệm. Bạn có thể cập nhật hồ sơ hoặc gửi yêu cầu hỗ trợ liên quan đến dữ liệu cá nhân.',
                  ),
                  _buildSection(
                    context,
                    title: '7. Cập nhật điều khoản',
                    body:
                        'Điều khoản có thể được cập nhật khi ứng dụng thay đổi tính năng hoặc yêu cầu pháp lý. Việc tiếp tục sử dụng ứng dụng sau khi điều khoản được cập nhật đồng nghĩa với việc bạn đồng ý với phiên bản mới.',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Cập nhật lần cuối: 04/07/2026',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
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
              'Điều khoản sử dụng',
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

  Widget _buildIntro(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.18)),
      ),
      child: Text(
        'Vui lòng đọc kỹ các điều khoản dưới đây trước khi sử dụng dịch vụ. Nội dung này giúp làm rõ quyền và trách nhiệm khi bạn dùng MediBook.',
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
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
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
