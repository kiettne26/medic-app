import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_fe/config/router.dart';
import 'auth_controller.dart';
import 'package:app_fe/features/home/presentation/home_controller.dart';
import 'package:app_fe/features/notification/presentation/notification_provider.dart';
import 'package:app_fe/features/booking/presentation/booking_list_controller.dart';
import 'package:app_fe/features/chatbot/presentation/chatbot_provider.dart';
import '../../profile/presentation/user_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String _selectedGender = 'Nam';
  DateTime? _selectedDate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn ngày sinh'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final name = _nameController.text;
      final email = _emailController.text;
      final phone = _phoneController.text;
      final address = _addressController.text;
      final gender = _selectedGender;
      // Format YYYY-MM-DD
      final dob = "${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
      final password = _passwordController.text;

      await ref
          .read(authControllerProvider.notifier)
          .register(
            name: name,
            email: email,
            phone: phone,
            password: password,
            address: address,
            gender: gender,
            dob: dob,
          );

      final authState = ref.read(authControllerProvider);
      if (authState.status == AuthState.success) {
        if (mounted) {
          ref.invalidate(userProvider);
          ref.invalidate(homeControllerProvider);
          ref.invalidate(notificationProvider);
          ref.invalidate(bookingListControllerProvider);
          ref.invalidate(chatbotProvider);
          context.goNamed(AppRoute.home.name);
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

                  // Date of birth
                  _buildDatePicker(),
                  const SizedBox(height: 20),

                  // Gender
                  _buildGenderSelection(),
                  const SizedBox(height: 20),

                  // Address
                  _buildInputField(
                    label: 'Địa chỉ',
                    controller: _addressController,
                    icon: Icons.home,
                    hint: 'Nhập địa chỉ của bạn',
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

  Widget _buildGenderSelection() {
    final genders = ['Nam', 'Nữ', 'Khác'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giới tính',
          style: TextStyle(
            color: Color(0xFF0C131D),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: genders.map((gender) {
            final isSelected = _selectedGender == gender;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      gender,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF456AA1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF297EFF),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF297EFF) : const Color(0xFFCDD8EA),
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedGender = gender;
                      });
                    }
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ngày sinh',
          style: TextStyle(
            color: Color(0xFF0C131D),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime(2000, 1, 1),
              firstDate: DateTime(1900),
              lastDate: now,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF297EFF),
                      onPrimary: Colors.white,
                      onSurface: Color(0xFF0C131D),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && picked != _selectedDate) {
              setState(() {
                _selectedDate = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCDD8EA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  _selectedDate == null
                      ? 'Chọn ngày sinh'
                      : "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}",
                  style: TextStyle(
                    color: _selectedDate == null
                        ? const Color(0xFF456AA1)
                        : const Color(0xFF0C131D),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
