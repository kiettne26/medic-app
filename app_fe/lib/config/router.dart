import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_fe/features/auth/presentation/login_screen.dart';
import 'package:app_fe/features/auth/presentation/register_screen.dart';
import 'package:app_fe/features/auth/presentation/splash_screen.dart';
import 'package:app_fe/features/home/presentation/home_screen.dart';
import 'package:app_fe/features/home/presentation/main_layout.dart';
import 'package:app_fe/features/profile/presentation/profile_screen.dart';

// Define Routes
enum AppRoute { splash, login, register, home, booking, profile, doctorDetail }

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: AppRoute.register.name,
        builder: (context, state) => const RegisterScreen(),
      ),
      // Shell Route for Bottom Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: AppRoute.home.name,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Tab 2: Doctors (Placeholder)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctors',
                name: AppRoute.doctorDetail.name, // Temporary reuse
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Danh sách Bác sĩ')),
                ),
              ),
            ],
          ),
          // Tab 3: Booking (Placeholder)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/booking',
                name: AppRoute.booking.name,
                builder: (context, state) =>
                    const Scaffold(body: Center(child: Text('Đặt lịch khám'))),
              ),
            ],
          ),
          // Tab 4: Profile (Placeholder)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: AppRoute.profile.name,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
