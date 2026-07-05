import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/presentation/user_provider.dart';

class SecurityPrivacyScreen extends ConsumerStatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  ConsumerState<SecurityPrivacyScreen> createState() =>
      _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends ConsumerState<SecurityPrivacyScreen> {
  static const _storage = FlutterSecureStorage();
  bool _isChangingPassword = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, 'Bảo mật & Quyền riêng tư'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionTitle('Tài khoản'),
                  _buildActionTile(
                    icon: Icons.lock_outline,
                    title: 'Đổi mật khẩu',
                    subtitle: 'Cập nhật mật khẩu đăng nhập của bạn',
                    onTap: _showChangePasswordDialog,
                  ),
                  const SizedBox(height: 10),
                  _buildActionTile(
                    icon: Icons.verified_user_outlined,
                    title: 'Xác thực email',
                    subtitle: 'Bắt buộc để đặt lịch khám',
                    onTap: _openEmailVerification,
                  ),
                  const SizedBox(height: 10),
                  _buildActionTile(
                    icon: Icons.person_outline,
                    title: 'Thông tin cá nhân',
                    subtitle: 'Chỉnh sửa hồ sơ, số điện thoại và địa chỉ',
                    onTap: () async {
                      await context.push('/edit-profile');
                      ref.read(userProvider.notifier).refreshProfile();
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Quyền riêng tư'),
                  _buildInfoTile(
                    icon: Icons.medical_information_outlined,
                    title: 'Dữ liệu y tế',
                    body:
                        'Thông tin triệu chứng, lịch khám và ghi chú bác sĩ chỉ được dùng để phục vụ quy trình khám và chăm sóc sau khám.',
                  ),
                  const SizedBox(height: 10),
                  _buildInfoTile(
                    icon: Icons.notifications_none,
                    title: 'Thông báo',
                    body:
                        'Ứng dụng có thể gửi thông báo nhắc lịch, cập nhật trạng thái đặt lịch và tin nhắn liên quan đến chăm sóc sức khỏe.',
                  ),
                  const SizedBox(height: 10),
                  _buildActionTile(
                    icon: Icons.delete_outline,
                    title: 'Yêu cầu xóa dữ liệu',
                    subtitle: 'Xem cách gửi yêu cầu xóa tài khoản và hồ sơ',
                    isDestructive: true,
                    onTap: _showDeleteDataDialog,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
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
              title,
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

  Widget _buildSectionTitle(String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = isDestructive
        ? const Color(0xFFFF5252)
        : const Color(0xFF297EFF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildIconBox(icon, accent),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive ? accent : colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
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
          _buildIconBox(icon, const Color(0xFF297EFF)),
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

  Widget _buildIconBox(IconData icon, Color color) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Future<void> _openEmailVerification() async {
    final userId = await _storage.read(key: 'user_id');
    final email = await _storage.read(key: 'user_email');
    if (!mounted) return;

    if (userId == null || email == null || email.isEmpty) {
      _showSnackBar('Không tìm thấy thông tin tài khoản.', isError: true);
      return;
    }

    context.push(
      '/email-verification',
      extra: {'userId': userId, 'email': email},
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final formKey = GlobalKey<FormState>();
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              if (!(formKey.currentState?.validate() ?? false)) return;

              setDialogState(() => _isChangingPassword = true);
              try {
                await ref
                    .read(authRepositoryProvider)
                    .changePassword(
                      oldPassword: oldPasswordController.text.trim(),
                      newPassword: newPasswordController.text.trim(),
                    );
                if (!mounted || !dialogContext.mounted) return;
                setDialogState(() => _isChangingPassword = false);
                Navigator.of(dialogContext).pop();
                _showSnackBar('Đổi mật khẩu thành công.');
              } catch (e) {
                if (!mounted || !dialogContext.mounted) return;
                setDialogState(() => _isChangingPassword = false);
                _showSnackBar(_extractErrorMessage(e), isError: true);
              }
            }

            return AlertDialog(
              title: const Text('Đổi mật khẩu'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPasswordField(
                      controller: oldPasswordController,
                      label: 'Mật khẩu hiện tại',
                    ),
                    const SizedBox(height: 12),
                    _buildPasswordField(
                      controller: newPasswordController,
                      label: 'Mật khẩu mới',
                      validator: (value) {
                        if (value == null || value.trim().length < 6) {
                          return 'Mật khẩu mới cần ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildPasswordField(
                      controller: confirmPasswordController,
                      label: 'Nhập lại mật khẩu mới',
                      validator: (value) {
                        if (value != newPasswordController.text) {
                          return 'Mật khẩu nhập lại chưa khớp';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isChangingPassword
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: _isChangingPassword ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF297EFF),
                    foregroundColor: Colors.white,
                  ),
                  child: _isChangingPassword
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Lưu'),
                ),
              ],
              backgroundColor: colorScheme.surface,
            );
          },
        );
      },
    );

    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập $label';
            }
            return null;
          },
    );
  }

  void _showDeleteDataDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Yêu cầu xóa dữ liệu'),
        content: const Text(
          'Để xóa tài khoản và hồ sơ, vui lòng gửi yêu cầu đến email hỗ trợ. Dữ liệu lịch khám cần được kiểm tra trước khi xóa để bảo đảm nghĩa vụ lưu trữ y tế.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF00C853),
      ),
    );
  }

  String _extractErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message =
            data['message'] ?? data['error'] ?? data['errorMessage'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
    }
    return 'Không thể đổi mật khẩu. Vui lòng thử lại.';
  }
}
