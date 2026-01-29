import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/presentation/auth_controller.dart';

/// Màu sắc chính của Admin Portal
class AdminColors {
  static const Color primary = Color(0xFF2E80FA);
  static const Color backgroundLight = Color(0xFFF5F7F8);
  static const Color backgroundDark = Color(0xFF0F1723);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1A222C);
  static const Color textPrimary = Color(0xFF111418);
  static const Color textSecondary = Color(0xFF5F718C);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color success = Color(0xFF07883B);
  static const Color warning = Color(0xFFFACC15);
  static const Color error = Color(0xFFF43F5E);
}

/// Admin Layout với Sidebar Navigation theo design mới
class AdminLayout extends ConsumerStatefulWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  ConsumerState<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends ConsumerState<AdminLayout> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final authState = ref.watch(authControllerProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      drawer: isMobile ? _buildDrawer(currentPath) : null,
      body: Row(
        children: [
          // Sidebar - ẩn trên mobile
          if (!isMobile) _buildSidebar(currentPath),

          // Main Content Area
          Expanded(
            child: Container(
              color: AdminColors.backgroundLight,
              child: Column(
                children: [
                  // Top Navigation Bar
                  _buildTopBar(context, authState, isMobile),

                  // Content
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(String currentPath) {
    return Drawer(
      child: _buildSidebarContent(currentPath),
    );
  }

  Widget _buildSidebar(String currentPath) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: AdminColors.cardLight,
        border: Border(
          right: BorderSide(color: AdminColors.borderLight),
        ),
      ),
      child: _buildSidebarContent(currentPath),
    );
  }

  Widget _buildSidebarContent(String currentPath) {
    return Column(
      children: [
        // Logo Header
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AdminColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MedAdmin',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Quản trị hệ thống',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Navigation Items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _NavItem(
                icon: Icons.dashboard_rounded,
                label: 'Tổng quan',
                path: '/',
                currentPath: currentPath,
                filled: true,
              ),
              _NavItem(
                icon: Icons.medical_services_outlined,
                label: 'Bác sĩ',
                path: '/doctors',
                currentPath: currentPath,
              ),
              _NavItem(
                icon: Icons.group_outlined,
                label: 'Bệnh nhân',
                path: '/patients',
                currentPath: currentPath,
              ),
              _NavItem(
                icon: Icons.calendar_month_outlined,
                label: 'Lịch hẹn',
                path: '/bookings',
                currentPath: currentPath,
              ),
              _NavItem(
                icon: Icons.medical_information_outlined,
                label: 'Dịch vụ',
                path: '/services',
                currentPath: currentPath,
              ),
              _NavItem(
                icon: Icons.payments_outlined,
                label: 'Doanh thu',
                path: '/revenue',
                currentPath: currentPath,
              ),
            ],
          ),
        ),

        // Bottom Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AdminColors.borderLight),
              ),
            ),
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to create booking
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  'Thêm lịch mới',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(
      BuildContext context, AuthState authState, bool isMobile) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AdminColors.cardLight,
        border: Border(
          bottom: BorderSide(color: AdminColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          // Menu button for mobile
          if (isMobile)
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu, color: AdminColors.textSecondary),
            ),

          // Search Bar
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm bệnh nhân, bác sĩ, mã lịch hẹn...',
                  hintStyle: GoogleFonts.manrope(
                    color: AdminColors.textSecondary,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AdminColors.textSecondary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF0F2F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 24),

          // Notification & Settings
          Row(
            children: [
              _TopBarIconButton(
                icon: Icons.notifications_outlined,
                hasNotification: true,
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              _TopBarIconButton(
                icon: Icons.settings_outlined,
                onPressed: () {},
              ),
            ],
          ),

          // Divider
          Container(
            height: 32,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            color: AdminColors.borderLight,
          ),

          // User Profile
          InkWell(
            onTap: () => _showUserMenu(context),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      authState.userName ?? 'Admin Medcare',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Quản trị viên',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AdminColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AdminColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AdminColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUserMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 60, 24, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person_outline, size: 20),
              const SizedBox(width: 12),
              Text('Hồ sơ', style: GoogleFonts.manrope()),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings_outlined, size: 20),
              const SizedBox(width: 12),
              Text('Cài đặt', style: GoogleFonts.manrope()),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, color: AdminColors.error, size: 20),
              const SizedBox(width: 12),
              Text(
                'Đăng xuất',
                style: GoogleFonts.manrope(color: AdminColors.error),
              ),
            ],
          ),
        ),
      ],
    ).then((value) async {
      if (value == 'logout') {
        await ref.read(authControllerProvider.notifier).logout();
        if (context.mounted) {
          context.go('/login');
        }
      }
    });
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final String currentPath;
  final bool filled;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.currentPath,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentPath == path;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            context.go(path);
            // Close drawer if on mobile
            if (Scaffold.of(context).isDrawerOpen) {
              Navigator.of(context).pop();
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AdminColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  isActive && filled ? _getFilledIcon(icon) : icon,
                  color: isActive ? Colors.white : AdminColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? Colors.white : AdminColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getFilledIcon(IconData icon) {
    if (icon == Icons.dashboard_outlined) return Icons.dashboard_rounded;
    if (icon == Icons.dashboard_rounded) return Icons.dashboard_rounded;
    return icon;
  }
}

class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final bool hasNotification;
  final VoidCallback onPressed;

  const _TopBarIconButton({
    required this.icon,
    this.hasNotification = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                icon,
                color: AdminColors.textSecondary,
                size: 22,
              ),
            ),
          ),
        ),
        if (hasNotification)
          Positioned(
            top: 8,
            right: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AdminColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
