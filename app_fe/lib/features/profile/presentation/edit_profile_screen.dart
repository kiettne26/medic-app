import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../data/dto/profile_dto.dart';
import '../data/source/profile_api.dart';
import 'user_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();

  String? _userId;
  String? _avatarUrl;
  String? _selectedGender;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _emailVerified = false;

  final List<Map<String, String>> _genderOptions = [
    {'value': 'MALE', 'label': 'Nam'},
    {'value': 'FEMALE', 'label': 'Nữ'},
    {'value': 'OTHER', 'label': 'Khác'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final userId = await _storage.read(key: 'user_id');
    if (userId == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    _userId = userId;

    // Load từ storage trước
    final fullName = await _storage.read(key: 'user_name');
    final avatarUrl = await _storage.read(key: 'user_avatar');
    final email = await _storage.read(key: 'user_email');
    final emailVerified = await _storage.read(key: 'email_verified');
    final phone = await _storage.read(key: 'user_phone');
    final address = await _storage.read(key: 'user_address');
    final dob = await _storage.read(key: 'user_dob');
    final gender = await _storage.read(key: 'user_gender');

    if (mounted) {
      setState(() {
        _fullNameController.text = fullName ?? '';
        _emailController.text = email ?? '';
        _emailVerified = emailVerified == 'true';
        _phoneController.text = phone ?? '';
        _addressController.text = address ?? '';
        _dobController.text = dob ?? '';
        _selectedGender = gender;
        _avatarUrl = avatarUrl;
        _isLoading = false;
      });
    }

    // Sau đó load từ API
    final profileApi = ref.read(profileApiProvider);
    final profile = await profileApi.getProfileByUserId(userId);

    if (mounted && profile != null) {
      setState(() {
        _fullNameController.text = profile.fullName ?? _fullNameController.text;
        _emailController.text = profile.email ?? _emailController.text;
        _emailVerified = profile.emailVerified;
        _phoneController.text = profile.phone ?? _phoneController.text;
        _addressController.text = profile.address ?? _addressController.text;
        _dobController.text = profile.dob ?? _dobController.text;
        _selectedGender = profile.gender ?? _selectedGender;
        _avatarUrl = profile.avatarUrl ?? _avatarUrl;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  }

  Future<void> _openEmailVerification() async {
    if (_userId == null) return;
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email hợp lệ')),
      );
      return;
    }

    final profile = await context.push<ProfileDto>(
      '/email-verification',
      extra: {'userId': _userId!, 'email': email},
    );

    if (!mounted || profile == null) return;

    setState(() {
      _emailController.text = profile.email ?? email;
      _emailVerified = profile.emailVerified;
    });

    await _writeProfileToStorage(profile, fallbackEmail: email);
    await ref.read(userProvider.notifier).refreshProfile();
  }

  Future<void> _writeProfileToStorage(
    ProfileDto profile, {
    String? fallbackFullName,
    String? fallbackEmail,
    String? fallbackPhone,
    String? fallbackAddress,
    String? fallbackDob,
    String? fallbackGender,
    String? fallbackAvatarUrl,
  }) async {
    final fullName = profile.fullName ?? fallbackFullName;
    final email = profile.email ?? fallbackEmail;
    final phone = profile.phone ?? fallbackPhone;
    final address = profile.address ?? fallbackAddress;
    final dob = profile.dob ?? fallbackDob;
    final gender = profile.gender ?? fallbackGender;
    final avatarUrl = profile.avatarUrl ?? fallbackAvatarUrl;

    if (fullName != null) {
      await _storage.write(key: 'user_name', value: fullName);
    }
    if (email != null) {
      await _storage.write(key: 'user_email', value: email);
    }
    if (phone != null) {
      await _storage.write(key: 'user_phone', value: phone);
    }
    if (address != null) {
      await _storage.write(key: 'user_address', value: address);
    }
    if (dob != null) {
      await _storage.write(key: 'user_dob', value: dob);
    }
    if (gender != null) {
      await _storage.write(key: 'user_gender', value: gender);
    }
    if (avatarUrl != null) {
      await _storage.write(key: 'user_avatar', value: avatarUrl);
    }
    await _storage.write(
      key: 'email_verified',
      value: profile.emailVerified.toString(),
    );
  }

  Future<void> _saveProfile() async {
    if (_userId == null || !_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final request = UpdateProfileRequest(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      gender: _selectedGender,
      dob: _dobController.text.trim().isEmpty
          ? null
          : _dobController.text.trim(),
      avatarUrl: _avatarUrl,
    );

    final profileApi = ref.read(profileApiProvider);
    final result = await profileApi.updateProfile(_userId!, request);

    if (mounted) {
      setState(() => _isSaving = false);

      if (result != null) {
        await _writeProfileToStorage(
          result,
          fallbackFullName: request.fullName,
          fallbackEmail: request.email,
          fallbackPhone: request.phone,
          fallbackAddress: request.address,
          fallbackDob: request.dob,
          fallbackGender: request.gender,
          fallbackAvatarUrl: request.avatarUrl,
        );

        // Refresh global user state
        ref.read(userProvider.notifier).refreshProfile();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật hồ sơ thành công!'),
            backgroundColor: Color(0xFF00C853),
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2A7FFF)),
                  )
                : SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildAvatarSection(),
                          _buildFormFields(),
                          _buildSaveButton(),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 4,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: const Color(0xFF101418),
          ),
          const Expanded(
            child: Text(
              'Chỉnh sửa hồ sơ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF101418),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 40), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 4,
                ),
                image: _avatarUrl != null && _avatarUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(_avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _avatarUrl == null || _avatarUrl!.isEmpty
                  ? const Icon(Icons.person, size: 56, color: Color(0xFF2A7FFF))
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A7FFF),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildTextField(
            label: 'Họ và tên',
            controller: _fullNameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập họ tên';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            suffixIcon: _emailVerified
                ? const Icon(Icons.verified, color: Color(0xFF00C853))
                : TextButton(
                    onPressed: _openEmailVerification,
                    child: const Text('Xác thực'),
                  ),
            onChanged: (_) {
              if (_emailVerified) {
                setState(() => _emailVerified = false);
              }
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!_isValidEmail(value)) {
                return 'Email không hợp lệ';
              }
              if (!_emailVerified) {
                return 'Vui lòng xác thực email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Số điện thoại',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Ngày sinh',
            controller: _dobController,
            readOnly: true,
            onTap: _selectDate,
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _buildGenderDropdown(),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Địa chỉ',
            controller: _addressController,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'Giới tính',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
            hint: const Text(
              'Chọn giới tính',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF101418),
            ),
            icon: const Icon(Icons.expand_more, color: Colors.grey),
            items: _genderOptions.map((option) {
              return DropdownMenuItem<String>(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF101418),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A7FFF)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2A7FFF),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: const Color(0xFF2A7FFF).withOpacity(0.3),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Lưu thay đổi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      if (mounted) setState(() => _isLoading = true);

      final profileApi = ref.read(profileApiProvider);
      final url = await profileApi.uploadAvatar(File(image.path));

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (url != null) {
            if (url.startsWith('http')) {
              _avatarUrl = url;
            } else {
              _avatarUrl = "https://mocha-exchange-scoff.ngrok-free.dev$url";
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upload ảnh thất bại')),
            );
          }
        });
      }
    }
  }
}
