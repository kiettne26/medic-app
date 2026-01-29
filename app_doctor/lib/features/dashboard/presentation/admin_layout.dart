import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../profile/presentation/profile_controller.dart';

class AdminLayout extends ConsumerWidget {
  final Widget child;
  final String currentLocation;

  const AdminLayout({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  static const primaryColor = Color(0xFF297EFF);
  static const textColorDark = Color(0xFF0C131D);
  static const textColorLight = Color(0xFF456AA1);
  static const borderColor = Color(0xFFE6ECF4);
  static const backgroundColor = Color(0xFFF5F7F8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: borderColor)),
            ),
            child: Column(
              children: [
                // Profile Section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: profileState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('Error loading profile'),
                    data: (profile) {
                      final name = profile?.fullName ?? 'Bác sĩ';
                      final avatar =
                          profile?.avatarUrl ??
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuC747gNLZAspVd7KtgmM7I6n1tBlPtrIc7J9WyEao6rAn24DdKFcQRRxfAYJz54Jd6GPlj5g2JwFjuqgl1yRq1sqcXADY61x7AT7et78sKmobfMxmB94nMcx7SzTb6iDuWlDXeOImM-Cns6FLmVC2uu0UkEyCUQ2Pe-DpTCEdh3WndqVH7uRofUCeiaDeMwYLT1dk-D4WKVM6b7VW_p1YYbX7cadAT8CT_Bozb60Al9IhxPLCOeNrkxZ0XNE-hhwz4YKXKpDgycPVQ';

                      return Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryColor.withOpacity(0.2),
                                width: 2,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(avatar),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textColorDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  profile?.specialty != null
                                      ? 'Chuyên khoa ${profile!.specialty}'
                                      : 'Bác sĩ',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Nav Links
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _SidebarItem(
                        icon: Icons.dashboard_outlined,
                        title: 'Trang tổng quan',
                        isSelected: currentLocation.startsWith('/dashboard'),
                        onTap: () => context.go('/dashboard'),
                      ),
                      const SizedBox(height: 4),
                      _SidebarItem(
                        icon: Icons.calendar_month_outlined,
                        title: 'Lịch hẹn',
                        isSelected: currentLocation.startsWith('/appointments'),
                        onTap: () => context.go('/appointments'),
                      ),
                      const SizedBox(height: 4),
                      _SidebarItem(
                        icon: Icons.schedule_outlined,
                        title: 'Lịch làm việc',
                        isSelected: currentLocation.startsWith('/schedule'),
                        onTap: () => context.go('/schedule'),
                      ),
                      const SizedBox(height: 4),
                      _SidebarItem(
                        icon: Icons.star_outline,
                        title: 'Đánh giá',
                        isSelected: currentLocation.startsWith('/reviews'),
                        onTap: () => context.go('/reviews'),
                      ),
                      const SizedBox(height: 4),
                      _SidebarItem(
                        icon: Icons.notifications_none,
                        title: 'Thông báo',
                        isSelected: currentLocation.startsWith(
                          '/notifications',
                        ),
                        onTap: () => context.go('/notifications'),
                      ),
                      const SizedBox(height: 4),
                      _SidebarItem(
                        icon: Icons.chat_bubble_outline,
                        title: 'Tin nhắn',
                        isSelected: currentLocation.startsWith('/messages'),
                        onTap: () => context.go('/messages'),
                      ),
                      const SizedBox(height: 4),
                      _SidebarItem(
                        icon: Icons.person_outline,
                        title: 'Hồ sơ',
                        isSelected: currentLocation.startsWith('/profile'),
                        onTap: () => context.go('/profile'),
                      ),
                    ],
                  ),
                ),

                // Logout
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide.none,
                      backgroundColor: Colors.grey[50],
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.logout, size: 20),
                    label: Text(
                      'Đăng xuất',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors
                        .white, // In designs typically semi-transparent blur, but white is safer
                    border: Border(bottom: BorderSide(color: borderColor)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    children: [
                      Text(
                        'Trang tổng quan',
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: textColorDark,
                        ),
                      ),
                      const SizedBox(width: 40),
                      // Search
                      Container(
                        width: 300,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm bệnh nhân...',
                            hintStyle: GoogleFonts.manrope(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              size: 20,
                              color: Colors.grey[400],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Notification
                      Stack(
                        children: [
                          IconButton(
                            onPressed: () => context.go('/notifications'),
                            icon: const Icon(Icons.notifications_outlined),
                            color: textColorLight,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: borderColor),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.fromBorderSide(
                                  BorderSide(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.settings_outlined),
                        color: textColorLight,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: borderColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(width: 1, height: 32, color: borderColor),
                      const SizedBox(width: 16),
                      // Dynamic Avatar in Header
                      profileState.when(
                        loading: () =>
                            const CircleAvatar(backgroundColor: Colors.grey),
                        error: (_, __) =>
                            const CircleAvatar(backgroundColor: Colors.red),
                        data: (profile) => Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(
                                profile?.avatarUrl ??
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBQKc7IaGzr6HZvz31LYqzfwGmd74qHbPkObocf51WTFfMSXuRa9Xfyc5STysIZp9QE5KTxpR4nmdROpvGZ2wr9za0JUIM14BRAgA-OTqNEwfKrmNuBoDdWWQaCxisXrc_yCheTb7uZCV4mk-Ql5HPJ-eowKAdVs3nspO9tfa9hYn5dvV61FnTcwk2-sfPuFqz2F0T6KGsh6VajBxiLza_nxGD9vTWeuhKTlFUKPUS73zk9q7iUCk2QvyKFqmp1wk7ax3fFdEDT40M',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF297EFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF297EFF).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF456AA1),
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.manrope(
                  color: isSelected ? Colors.white : const Color(0xFF456AA1),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
