import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Content
          navigationShell,

          // Chatbot floating button (Only show on Home Screen)
          if (navigationShell.currentIndex == 0)
            Positioned(
              bottom: 76, // Height of bottom nav (60) + 16px padding
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  context.push('/chatbot');
                },
                backgroundColor: const Color(0xFF297EFF),
                elevation: 4,
                child: const Icon(
                  Icons.support_agent,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),

          // Custom Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.outline.withOpacity(0.14)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(context, 0, Icons.home, 'Trang chủ'),
                  _buildNavItem(context, 1, Icons.people, 'Bác sĩ'),
                  _buildNavItem(context, 2, Icons.calendar_month, 'Đặt lịch'),
                  _buildNavItem(context, 3, Icons.person, 'Cá nhân'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final isActive = navigationShell.currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;
    final color = isActive
        ? const Color(0xFF297EFF)
        : colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60, // Increase touch area
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
