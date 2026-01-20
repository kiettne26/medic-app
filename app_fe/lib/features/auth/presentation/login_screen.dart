import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_fe/config/router.dart';
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

  void _onLogin() async {
    if (_formKey.currentState!.validate()) {
      // Allow user to login
      final email = _emailController.text;
      final password = _passwordController.text;

      // Call AuthController
      await ref.read(authControllerProvider.notifier).login(email, password);

      // Check state
      final authState = ref.read(authControllerProvider);

      if (authState.status == AuthState.success) {
        if (mounted) context.goNamed(AppRoute.home.name);
      } else if (authState.status == AuthState.error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authState.errorMessage ?? 'Login Failed',
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
    // Watch state to update UI (loading)
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthState.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8), // background-light
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) context.pop();
                    },
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: Color(0xFF0C131D),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 48), // Balance spacing
                      child: Text(
                        'Chào mừng trở lại',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF0C131D),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo Section
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF297EFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.medical_services,
                            size: 48,
                            color: Color(0xFF297EFF), // primary
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Email Input
                      const Text(
                        'Email',
                        style: TextStyle(
                          color: Color(0xFF0C131D),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Nhập email của bạn',
                          hintStyle: TextStyle(
                            color: const Color(0xFF456AA1).withOpacity(0.6),
                            fontWeight: FontWeight.normal,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.mail_outline,
                            color: Color(0xFF456AA1),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFCDD8EA),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFCDD8EA),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF297EFF),
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Password Input
                      const Text(
                        'Mật khẩu',
                        style: TextStyle(
                          color: Color(0xFF0C131D),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Nhập mật khẩu',
                          hintStyle: TextStyle(
                            color: const Color(0xFF456AA1).withOpacity(0.6),
                            fontWeight: FontWeight.normal,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF456AA1),
                          ),
                          suffixIcon: const Icon(
                            Icons.visibility_outlined, // Simplified for now
                            color: Color(0xFF456AA1),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFCDD8EA),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFCDD8EA),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF297EFF),
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          return null;
                        },
                      ),

                      // Forgot Password check
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              color: const Color(0xFF297EFF),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Login Button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF297EFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            shadowColor: const Color(
                              0xFF297EFF,
                            ).withOpacity(0.2),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      // Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Divider(color: Color(0xFFCDD8EA)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'hoặc',
                                style: TextStyle(
                                  color: const Color(0xFF456AA1),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: Color(0xFFCDD8EA)),
                            ),
                          ],
                        ),
                      ),

                      // Social Login
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () async {
                                  await ref
                                      .read(authControllerProvider.notifier)
                                      .socialLogin('google');

                                  // Check state and navigate
                                  final authState = ref.read(
                                    authControllerProvider,
                                  );
                                  if (authState.status == AuthState.success) {
                                    if (mounted)
                                      context.goNamed(AppRoute.home.name);
                                  } else if (authState.status ==
                                      AuthState.error) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            authState.errorMessage ??
                                                'Social Login Failed',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFFCDD8EA),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Image.network(
                                        'https://www.google.com/favicon.ico',
                                        width: 20,
                                        height: 20,
                                        errorBuilder: (context, error, stackTrace) {
                                          // Fallback to text "G" if image fails
                                          return Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                color: const Color(0xFFCDD8EA),
                                              ),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'G',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF4285F4),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Google',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF5E718D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () async {
                                  await ref
                                      .read(authControllerProvider.notifier)
                                      .socialLogin('facebook');

                                  // Check state and navigate
                                  final authState = ref.read(
                                    authControllerProvider,
                                  );
                                  if (authState.status == AuthState.success) {
                                    if (mounted)
                                      context.goNamed(AppRoute.home.name);
                                  } else if (authState.status ==
                                      AuthState.error) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            authState.errorMessage ??
                                                'Social Login Failed',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0xFFCDD8EA),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Icon(
                                  Icons
                                      .facebook, // Fallback for social_leaderboard/facebook
                                  color: Color(0xFF1877F2),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Register Link
                      Padding(
                        padding: const EdgeInsets.only(top: 40, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Chưa có tài khoản? ',
                              style: TextStyle(
                                color: Color(0xFF0C131D),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  context.pushNamed(AppRoute.register.name),
                              child: const Text(
                                'Đăng ký ngay',
                                style: TextStyle(
                                  color: Color(0xFF297EFF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.support_agent,
                    size: 16,
                    color: Color(0xFF456AA1),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Trung tâm hỗ trợ y tế 24/7',
                    style: TextStyle(
                      color: const Color(0xFF456AA1),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
