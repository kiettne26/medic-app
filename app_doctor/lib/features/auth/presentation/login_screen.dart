import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isObscure = true;
  bool _rememberMe = false;

  // Colors extracted from HTML/Tailwind Config
  static const primaryColor = Color(0xFF2A7FFF);
  static const secondaryColor = Color(0xFF00C853);
  static const textColorDark = Color(0xFF0C131D);
  static const textColorLight = Color(0xFF456AA1);
  static const backgroundColor = Color(0xFFF5F7F8);
  static const borderColor = Color(0xFFE6ECF4);
  static const inputBorderColor = Color(0xFFCDD8EA);

  @override
  Widget build(BuildContext context) {
    // Responsive check similar to tailwind 'lg' breakpoint (1024px)
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width >= 1024;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Hệ thống Bác sĩ',
                  style: GoogleFonts.manrope(
                    color: textColorDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.015,
                  ),
                ),
                const Spacer(),
                if (MediaQuery.of(context).size.width > 768) ...[
                  // Hidden on small screens (md breakpoint)
                  _buildNavLink('Trang chủ'),
                  const SizedBox(width: 36),
                  _buildNavLink('Về chúng tôi'),
                  const SizedBox(width: 36),
                  _buildNavLink('Liên hệ'),
                  const SizedBox(width: 32),
                  Container(width: 1, height: 24, color: Colors.grey.shade200),
                  const SizedBox(width: 32),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.help_outline, size: 20),
                    label: const Text('Hỗ trợ kỹ thuật'),
                    style: TextButton.styleFrom(
                      foregroundColor: textColorLight,
                      textStyle: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    clipBehavior: Clip
                        .antiAlias, // To clip content inside rounded corners
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Side (  Visual) - Hidden on smaller screens (< lg)
                          if (isLargeScreen)
                            Expanded(
                              child: Container(
                                color: primaryColor.withOpacity(0.05),
                                child: Stack(
                                  children: [
                                    // Background Blobs (Simplified emulation)
                                    Positioned(
                                      top: -128,
                                      right: -128,
                                      child: Container(
                                        width: 256,
                                        height: 256,
                                        decoration: BoxDecoration(
                                          color: secondaryColor.withOpacity(
                                            0.1,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ), // Blur would typically be applied here
                                    ),
                                    Positioned(
                                      bottom: -128,
                                      left: -128,
                                      child: Container(
                                        width: 256,
                                        height: 256,
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),

                                    // Content Center
                                    Padding(
                                      padding: const EdgeInsets.all(48.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: 256,
                                            margin: const EdgeInsets.only(
                                              bottom: 32,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: primaryColor.withOpacity(
                                                  0.1,
                                                ),
                                              ),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.vaccines,
                                                size: 120,
                                                color: primaryColor.withOpacity(
                                                  0.4,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'Dành cho Chuyên gia Y tế',
                                            style: GoogleFonts.manrope(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: textColorDark,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Hệ thống quản lý lịch khám và tư vấn trực tuyến hiện đại. Giúp bác sĩ kết nối với bệnh nhân mọi lúc, mọi nơi.',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.manrope(
                                              fontSize: 16,
                                              color: textColorLight,
                                              height: 1.6, // leading-relaxed
                                            ),
                                          ),
                                          const SizedBox(height: 32),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: secondaryColor.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    999,
                                                  ), // rounded-full
                                              border: Border.all(
                                                color: secondaryColor
                                                    .withOpacity(0.2),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.verified_user,
                                                  color: secondaryColor,
                                                  size: 14,
                                                ), // text-sm fits -> 14
                                                const SizedBox(width: 8),
                                                Text(
                                                  'BẢO MẬT CHUẨN HIPAA',
                                                  style: GoogleFonts.manrope(
                                                    color: secondaryColor,
                                                    fontSize: 12, // text-xs
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing:
                                                        0.5, // tracking-wider
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Right Side (Form)
                          Expanded(
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(
                                48,
                              ), // p-8 md:p-12 lg:p-16 (Using avg)
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Headline
                                    Center(
                                      child: Column(
                                        // lg:text-left but sticking to center for consistency on mobile/web transition unless specified
                                        crossAxisAlignment: isLargeScreen
                                            ? CrossAxisAlignment.start
                                            : CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Chào mừng Bác sĩ',
                                            style: GoogleFonts.manrope(
                                              fontSize: 30, // text-3xl
                                              fontWeight: FontWeight.w800,
                                              letterSpacing:
                                                  -0.025, // tracking-tight
                                              color: textColorDark,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Đăng nhập vào hệ thống quản lý khám chữa bệnh',
                                            style: GoogleFonts.manrope(
                                              fontSize: 16, // text-base
                                              color: textColorLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 40),

                                    // Email
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Email',
                                          style: GoogleFonts.manrope(
                                            fontSize: 14, // text-sm
                                            fontWeight: FontWeight.bold,
                                            color: textColorDark,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _emailController,
                                          style: GoogleFonts.manrope(
                                            color: textColorDark,
                                          ),
                                          decoration: _buildInputDecoration(
                                            hint: 'Nhập email của bác sĩ',
                                            icon: Icons.mail_outline,
                                          ),
                                          validator: (v) => v!.isEmpty
                                              ? 'Vui lòng nhập email'
                                              : null,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Password
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Mật khẩu',
                                              style: GoogleFonts.manrope(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: textColorDark,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {},
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: Text(
                                                'Quên mật khẩu?',
                                                style: GoogleFonts.manrope(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: _isObscure,
                                          style: GoogleFonts.manrope(
                                            color: textColorDark,
                                          ),
                                          decoration: _buildInputDecoration(
                                            hint: 'Nhập mật khẩu',
                                            icon: Icons.lock_outline,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _isObscure
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                          .visibility_off_outlined,
                                                color: textColorLight,
                                              ),
                                              onPressed: () => setState(
                                                () => _isObscure = !_isObscure,
                                              ),
                                            ),
                                          ),
                                          validator: (v) => v!.isEmpty
                                              ? 'Vui lòng nhập mật khẩu'
                                              : null,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Remember Me
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            activeColor: secondaryColor,
                                            side: const BorderSide(
                                              color: Color(0xFFCBD5E1),
                                            ), // border-slate-300
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            onChanged: (v) => setState(
                                              () => _rememberMe = v!,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Ghi nhớ đăng nhập',
                                          style: GoogleFonts.manrope(
                                            fontSize: 14,
                                            color: textColorLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Login Button
                                    SizedBox(
                                      height: 56, // h-14
                                      child: ElevatedButton(
                                        onPressed: _isLoading
                                            ? null
                                            : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          elevation: 4, // shadow-lg
                                          shadowColor: primaryColor.withOpacity(
                                            0.2,
                                          ), // shadow-primary/20
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ), // rounded-lg
                                          ),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.login,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Đăng nhập',
                                                    style: GoogleFonts.manrope(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              children: [
                Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildFooterLink('Điều khoản sử dụng'),
                    _buildFooterLink('Chính sách bảo mật'),
                    _buildFooterLink('Hỗ trợ kỹ thuật'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '© 2024 HỆ THỐNG QUẢN LÝ Y TẾ DOCTORAPP',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: textColorLight.withOpacity(0.5),
                    letterSpacing: 1.5, // tracking-widest
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String text) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColorLight,
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return InkWell(
      onTap: () {},
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColorLight,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.manrope(color: textColorLight.withOpacity(0.6)),
      prefixIcon: Icon(icon, color: textColorLight, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 16,
      ), // Height is controlled by Container/SizedBox wrapping usually or isDense
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: inputBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: inputBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 2,
        ), // ring-2 ring-primary/20 emulation
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Simulate delay for effect if logic is instant
    // await Future.delayed(const Duration(seconds: 1));

    try {
      final success = await ref
          .read(authControllerProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);

      if (success && mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
