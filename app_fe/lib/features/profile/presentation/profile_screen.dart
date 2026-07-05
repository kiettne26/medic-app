import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_fe/features/auth/presentation/auth_controller.dart';
import 'package:app_fe/config/router.dart';
import 'package:app_fe/features/home/presentation/home_controller.dart';
import 'package:app_fe/features/notification/presentation/notification_provider.dart';
import 'package:app_fe/features/booking/presentation/booking_list_controller.dart';
import 'package:app_fe/features/chatbot/presentation/chatbot_provider.dart';
import '../presentation/user_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                    _buildUserInfo(
                      userName,
                      userState.email,
                      userAvatar,
                      userState.id,
                    ),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Cá nhân',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(
    String userName,
    String userEmail,
    String userAvatar,
    String userId,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

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
                border: Border.all(color: colorScheme.surface, width: 3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12), // Reduced from 16
        Text(
          userName,
          style: TextStyle(
            fontSize: 20, // Reduced from 24
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2), // Reduced from 4
        Text(
          userEmail.isNotEmpty ? userEmail : 'Chưa cập nhật email',
          style: TextStyle(
            fontSize: 14, // Reduced from 16
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
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
            onTap: () {
              context.push('/medical-history');
            },
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
            onTap: () {
              context.push('/help-support');
            },
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final effectiveIconBgColor = iconBgColor != null && !isDark
        ? iconBgColor
        : color.withOpacity(0.12);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ), // Reduced vertical padding from 16
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0 : 0.02),
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
                color: effectiveIconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22), // Reduced icon size
            ),
            const SizedBox(width: 14), // Reduced from 16
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15, // Reduced from 16
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
              size: 18,
            ), // Reduced size
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            // Call logout to clear tokens
            await ref.read(authControllerProvider.notifier).logout();
            // Clear user state and all related cache from provider memory
            ref.invalidate(userProvider);
            ref.invalidate(homeControllerProvider);
            ref.invalidate(notificationProvider);
            ref.invalidate(bookingListControllerProvider);
            ref.invalidate(chatbotProvider);
            // Navigate to login screen
            if (context.mounted) {
              context.goNamed(AppRoute.login.name);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(
              0xFFEF4444,
            ).withOpacity(isDark ? 0.14 : 0.12),
            foregroundColor: isDark
                ? const Color(0xFFFCA5A5)
                : const Color(0xFFEF4444),
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
