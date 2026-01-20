import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_fe/config/router.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final email = _emailController.text;
      final phone = _phoneController.text;
      final password = _passwordController.text;

      await ref
          .read(authControllerProvider.notifier)
          .register(name, email, phone, password);

      final authState = ref.read(authControllerProvider);
      if (authState.status == AuthState.success) {
        if (mounted) context.goNamed(AppRoute.home.name);
      } else if (authState.status == AuthState.registerSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Đăng ký thành công! Vui lòng đăng nhập.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.goNamed(AppRoute.login.name);
        }
      } else if (authState.status == AuthState.error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authState.errorMessage ?? 'Registration Failed',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthState.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8), // background-light
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Navigation Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Color(0xFF0C131D),
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            hoverColor: Colors.grey[200],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF297EFF), // primary
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.health_and_safety,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'MediCare',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0C131D),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 40), // Spacer
                      ],
                    ),
                  ),

                  // Header Section
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tạo tài khoản mới',
                          style: TextStyle(
                            color: Color(0xFF0C131D),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tham gia cộng đồng chăm sóc sức khỏe trực tuyến của chúng tôi ngay hôm nay.',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Full Name
                  _buildInputField(
                    label: 'Họ tên',
                    controller: _nameController,
                    icon: Icons.person,
                    hint: 'Nhập họ và tên của bạn',
                  ),
                  const SizedBox(height: 20),

                  // Email
                  _buildInputField(
                    label: 'Email',
                    controller: _emailController,
                    icon: Icons.mail,
                    hint: 'example@email.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // Phone Number
                  _buildInputField(
                    label: 'Số điện thoại',
                    controller: _phoneController,
                    icon: Icons.call,
                    hint: 'Nhập số điện thoại',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),

                  // Password
                  _buildInputField(
                    label: 'Mật khẩu',
                    controller: _passwordController,
                    icon: Icons.lock,
                    hint: '••••••••',
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onTogglePassword: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password
                  _buildInputField(
                    label: 'Xác nhận mật khẩu',
                    controller: _confirmPasswordController,
                    icon: Icons.enhanced_encryption,
                    hint: '••••••••',
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    onTogglePassword: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                    validator: (val) {
                      if (val != _passwordController.text)
                        return 'Mật khẩu không khớp';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Terms
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: true,
                          activeColor: const Color(0xFF297EFF),
                          onChanged: (val) {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            children: [
                              TextSpan(text: 'Tôi đồng ý với các '),
                              TextSpan(
                                text: 'Điều khoản dịch vụ',
                                style: TextStyle(
                                  color: Color(0xFF297EFF),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(text: ' và '),
                              TextSpan(
                                text: 'Chính sách bảo mật',
                                style: TextStyle(
                                  color: Color(0xFF297EFF),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Register Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _onRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF297EFF), // primary
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFF297EFF).withOpacity(0.3),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Đăng ký',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward),
                            ],
                          ),
                  ),

                  const SizedBox(height: 16),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Đã có tài khoản? ',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => context.goNamed(
                          AppRoute.login.name,
                        ), // Go back or replace? Usually goNamed
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            color: Color(0xFF297EFF),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0C131D),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF456AA1),
            ), // placeholder color ish
            prefixIcon: Icon(icon, color: Colors.grey),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCDD8EA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCDD8EA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF297EFF), width: 2),
            ),
          ),
          validator:
              validator ??
              (val) {
                if (val == null || val.isEmpty)
                  return 'Vui lòng nhập thông tin';
                return null;
              },
        ),
      ],
    );
  }
}
