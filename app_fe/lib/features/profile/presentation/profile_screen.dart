import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_fe/features/auth/presentation/auth_controller.dart';
import 'package:app_fe/config/router.dart';
import '../presentation/user_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _userEmail = 'user@example.com';

  @override
  void initState() {
    super.initState();
    // Refresh user profile on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider.notifier).refreshProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final userName = userState.name;
    final userAvatar = userState.avatar;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8), // background-light
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  bottom: 100,
                ), // Add padding for BottomNav
                child: Column(
                  children: [
                    const SizedBox(height: 16), // Reduced from 24
                    const SizedBox(height: 16), // Reduced from 24
                    _buildUserInfo(userName, userAvatar, userState.id),
                    const SizedBox(height: 24), // Reduced from 32
                    _buildMenuOptions(),
                    const SizedBox(height: 32), // Reduced from 48
                    _buildLogoutButton(context, ref),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              // Logic for back if applicable
            },
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Color(0xFF101418),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Cá nhân',
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

  Widget _buildUserInfo(String userName, String userAvatar, String userId) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100, // Reduced from 128
              height: 100, // Reduced from 128
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF297EFF).withOpacity(0.1),
                  width: 4,
                ),
                image: userAvatar.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(userAvatar),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: userAvatar.isEmpty
                  ? const Icon(Icons.person, size: 60, color: Color(0xFF297EFF))
                  : null,
            ),
            Container(
              width: 20, // Reduced from 24
              height: 20, // Reduced from 24
              decoration: BoxDecoration(
                color: const Color(0xFF00C853),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12), // Reduced from 16
        Text(
          userName,
          style: const TextStyle(
            fontSize: 20, // Reduced from 24
            fontWeight: FontWeight.bold,
            color: Color(0xFF101418),
          ),
        ),
        const SizedBox(height: 2), // Reduced from 4
        Text(
          _userEmail,
          style: const TextStyle(
            fontSize: 14, // Reduced from 16
            fontWeight: FontWeight.w500,
            color: Color(0xFF5E718D),
          ),
        ),
        const SizedBox(height: 6), // Reduced from 8
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 2,
          ), // Reduced padding
          decoration: BoxDecoration(
            color: const Color(0xFF297EFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            'ID: $userId',
            style: const TextStyle(
              color: Color(0xFF297EFF),
              fontSize: 11, // Reduced from 12
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline, // person_edit replacement
            label: 'Chỉnh sửa hồ sơ',
            color: const Color(0xFF297EFF),
            onTap: () async {
              await context.push('/edit-profile');
              // Reload profile info when returning from edit screen
              ref.read(userProvider.notifier).refreshProfile();
            },
          ),
          const SizedBox(height: 12), // Reduced from 16
          _buildMenuItem(
            icon: Icons.history_edu,
            label: 'Lịch sử y tế',
            color: const Color(0xFF00C853),
            onTap: () {},
          ),
          const SizedBox(height: 12), // Reduced from 16
          _buildMenuItem(
            icon: Icons.settings_outlined,
            label: 'Cài đặt',
            color: const Color(0xFF5E718D),
            iconBgColor: const Color(0xFFF1F5F9), // slate-100
            onTap: () {
              context.push('/settings');
            },
          ),
          const SizedBox(height: 12), // Reduced from 16
          _buildMenuItem(
            icon: Icons.help_outline,
            label: 'Trợ giúp & Hỗ trợ',
            color: const Color(0xFF5E718D),
            iconBgColor: const Color(0xFFF1F5F9),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    Color? iconBgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ), // Reduced vertical padding from 16
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40, // Reduced from 44
              height: 40, // Reduced from 44
              decoration: BoxDecoration(
                color: iconBgColor ?? color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22), // Reduced icon size
            ),
            const SizedBox(width: 14), // Reduced from 16
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15, // Reduced from 16
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101418),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFA0AEC0),
              size: 18,
            ), // Reduced size
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            // Call logout to clear tokens
            await ref.read(authControllerProvider.notifier).logout();
            // Navigate to login screen
            if (context.mounted) {
              context.goNamed(AppRoute.login.name);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFEE2E2), // error-soft
            foregroundColor: const Color(0xFFEF4444), // error-text
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ), // Reduced from 16
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 18), // Reduced from 20
              SizedBox(width: 8),
              Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ), // Reduced from 16
              ),
            ],
          ),
        ),
      ),
    );
  }
}
