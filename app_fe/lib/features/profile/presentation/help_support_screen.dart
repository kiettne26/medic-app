import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể mở ứng dụng gọi điện thoại: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Hỗ trợ ứng dụng MediBook',
      },
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể mở ứng dụng gửi Email: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _launchWebsite(BuildContext context, String url) async {
    final Uri launchUri = Uri.parse(url);
    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể truy cập trang web này: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Trợ giúp & Hỗ trợ',
          style: TextStyle(
            color: Color(0xFF101418),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF101418), size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Welcome Card
            _buildWelcomeCard(),
            const SizedBox(height: 16),
            
            // Quick Contact Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildContactRow(context),
            ),
            const SizedBox(height: 24),

            // FAQs List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildFaqSection(),
            ),
            const SizedBox(height: 32),

            // Footer
            _buildFooter(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF297EFF), Color(0xFF63A4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.help_center_outlined, color: Colors.white, size: 48),
          SizedBox(height: 16),
          Text(
            'Chúng tôi có thể giúp gì cho bạn?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tìm kiếm các câu hỏi thường gặp bên dưới hoặc liên hệ trực tiếp với bộ phận chăm sóc khách hàng của MediBook.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(BuildContext context) {
    return Row(
      children: [
        // Hotline Button
        Expanded(
          child: _buildContactCard(
            icon: Icons.phone_in_talk,
            color: const Color(0xFF297EFF),
            title: 'Gọi hotline',
            subtitle: '0377 844 243',
            onTap: () => _makePhoneCall(context, '0377844243'),
          ),
        ),
        const SizedBox(width: 16),
        // Email Button
        Expanded(
          child: _buildContactCard(
            icon: Icons.mail_outline,
            color: const Color(0xFF00C853),
            title: 'Gửi Email',
            subtitle: 'support@medibook.vn',
            onTap: () => _sendEmail(context, 'support@medibook.vn'),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101418),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF718096),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Câu hỏi thường gặp (FAQs)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101418),
          ),
        ),
        const SizedBox(height: 12),
        _buildFaqItem(
          question: 'Làm thế nào để đặt lịch khám?',
          answer: 'Bước 1: Chọn dịch vụ chuyên khoa hoặc bác sĩ bạn mong muốn tại màn hình chính.\n'
              'Bước 2: Chọn ca khám còn trống (giờ và ngày khám phù hợp).\n'
              'Bước 3: Xác nhận thông tin và bấm đặt lịch khám.',
        ),
        _buildFaqItem(
          question: 'Tôi có thể hủy lịch khám đã đặt không?',
          answer: 'Có, bạn hoàn toàn có thể hủy lịch khám trước thời gian hẹn khám ít nhất 2 tiếng.\n'
              'Vui lòng vào màn hình Lịch hẹn, chọn ca khám muốn hủy và nhấn nút "Hủy lịch". Số tiền đã thanh toán (nếu có) sẽ được hoàn lại theo chính sách của hệ thống.',
        ),
        _buildFaqItem(
          question: 'Hệ thống hỗ trợ những phương thức thanh toán nào?',
          answer: 'Ứng dụng MediBook hỗ trợ thanh toán trực tuyến nhanh chóng thông qua ví điện tử ZaloPay, hoặc bạn có thể chọn thanh toán bằng tiền mặt/thẻ trực tiếp tại quầy tiếp đón của phòng khám.',
        ),
        _buildFaqItem(
          question: 'Xem chẩn đoán và đơn thuốc của bác sĩ ở đâu?',
          answer: 'Sau khi ca khám hoàn thành, bác sĩ sẽ nhập chẩn đoán và dặn dò lên hệ thống. Bạn có thể xem lại bất kỳ lúc nào bằng cách vào trang Cá nhân -> chọn Lịch sử khám bệnh và bấm vào ca khám tương ứng.',
        ),
      ],
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDF2F7)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          childrenPadding: const EdgeInsets.all(16).copyWith(top: 0),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              answer,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4A5568),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => context.push('/terms-of-use'),
              child: const Text(
                'Điều khoản dịch vụ',
                style: TextStyle(color: Color(0xFF297EFF), fontSize: 13),
              ),
            ),
            const Text('•', style: TextStyle(color: Color(0xFFA0AEC0))),
            TextButton(
              onPressed: () => context.push('/security-privacy'),
              child: const Text(
                'Chính sách bảo mật',
                style: TextStyle(color: Color(0xFF297EFF), fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _launchWebsite(context, 'https://www.medibook.vn'),
          child: const Text(
            'Truy cập website: www.medibook.vn',
            style: TextStyle(
              color: Color(0xFF718096),
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'MediBook v1.0.0',
          style: TextStyle(color: Color(0xFFA0AEC0), fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
