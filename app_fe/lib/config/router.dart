import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_fe/features/auth/presentation/login_screen.dart';
import 'package:app_fe/features/auth/presentation/register_screen.dart';
import 'package:app_fe/features/auth/presentation/splash_screen.dart';
import 'package:app_fe/features/home/presentation/home_screen.dart';
import 'package:app_fe/features/home/presentation/main_layout.dart';
import 'package:app_fe/features/profile/presentation/profile_screen.dart';
import 'package:app_fe/features/doctor/presentation/doctor_screen.dart';
import 'package:app_fe/features/doctor/presentation/doctor_detail_screen.dart';
import 'package:app_fe/features/profile/presentation/edit_profile_screen.dart';
import 'package:app_fe/features/booking/presentation/booking_screen.dart';
import 'package:app_fe/features/booking/presentation/select_service_screen.dart';
import 'package:app_fe/features/booking/presentation/select_datetime_screen.dart';
import 'package:app_fe/features/booking/presentation/select_doctor_screen.dart';
import 'package:app_fe/features/booking/presentation/booking_confirmation_screen.dart';
import 'package:app_fe/features/booking/data/dto/service_dto.dart';
import 'package:app_fe/features/settings/presentation/settings_screen.dart';
import 'package:app_fe/features/notification/presentation/notification_screen.dart';
import 'package:app_fe/features/chat/presentation/chat_screen.dart';

// Define Routes
enum AppRoute {
  splash,
  login,
  register,
  home,
  doctors,
  booking,
  profile,
  doctorDetail,
  editProfile,
  selectService,
  selectDateTime,
  selectDoctor,
  bookingConfirmation,
  settings,
  notification,
  chat,
}

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
      // Doctor Detail (outside shell to show full screen)
      GoRoute(
        path: '/doctor/:id',
        name: AppRoute.doctorDetail.name,
        builder: (context, state) {
          final doctorId = state.pathParameters['id'] ?? '';
          return DoctorDetailScreen(doctorId: doctorId);
        },
      ),
      // Edit Profile (outside shell to show full screen)
      GoRoute(
        path: '/edit-profile',
        name: AppRoute.editProfile.name,
        builder: (context, state) => const EditProfileScreen(),
      ),
      // Settings Screen
      GoRoute(
        path: '/settings',
        name: AppRoute.settings.name,
        builder: (context, state) => const SettingsScreen(),
      ),
      // Notification Screen
      GoRoute(
        path: '/notification',
        name: AppRoute.notification.name,
        builder: (context, state) => const NotificationScreen(),
      ),
      // Select Service Screen (booking flow step 1)
      GoRoute(
        path: '/select-service',
        name: AppRoute.selectService.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final doctor = extra != null ? extra['doctor'] as dynamic : null;

          return SelectServiceScreen(doctor: doctor);
        },
      ),
      // Select Doctor Screen (booking flow step 2)
      GoRoute(
        path: '/select-doctor',
        name: AppRoute.selectDoctor.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final services = (extra?['services'] as List<ServiceDto>?) ?? [];
          final totalPrice = (extra?['totalPrice'] as double?) ?? 0.0;
          return SelectDoctorScreen(
            selectedServices: services,
            totalPrice: totalPrice,
          );
        },
      ),
      // Select DateTime Screen (booking flow step 3)
      GoRoute(
        path: '/select-datetime',
        name: AppRoute.selectDateTime.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final services = (extra?['services'] as List<ServiceDto>?) ?? [];
          final totalPrice = (extra?['totalPrice'] as double?) ?? 0.0;
          final doctorId = (extra?['doctorId'] as String?) ?? '';
          final doctorName = extra?['doctorName'] as String?;
          final doctorAvatarUrl = extra?['doctorAvatarUrl'] as String?;
          return SelectDateTimeScreen(
            selectedServices: services,
            totalPrice: totalPrice,
            doctorId: doctorId,
            doctorName: doctorName,
            doctorAvatarUrl: doctorAvatarUrl,
          );
        },
      ),

      // Booking Confirmation Screen (booking flow step 4)
      GoRoute(
        path: '/booking-confirmation',
        name: AppRoute.bookingConfirmation.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final services = (extra?['services'] as List<ServiceDto>?) ?? [];
          final totalPrice = (extra?['totalPrice'] as double?) ?? 0.0;
          final doctorId = (extra?['doctorId'] as String?) ?? '';
          final doctorName = extra?['doctorName'] as String?;
          final doctorAvatarUrl = extra?['doctorAvatarUrl'] as String?;
          final selectedDate =
              extra?['selectedDate'] as DateTime? ?? DateTime.now();
          final selectedTime = (extra?['selectedTime'] as String?) ?? '';
          final timeSlotId = (extra?['timeSlotId'] as String?) ?? '';
          return BookingConfirmationScreen(
            selectedServices: services,
            totalPrice: totalPrice,
            doctorId: doctorId,
            doctorName: doctorName,
            doctorAvatarUrl: doctorAvatarUrl,
            selectedDate: selectedDate,
            selectedTime: selectedTime,
            timeSlotId: timeSlotId,
          );
        },
      ),
      // Chat Screen
      GoRoute(
        path: '/chat',
        name: AppRoute.chat.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final doctor = extra?['doctor'] as dynamic; // Cast appropriately
          return ChatScreen(doctor: doctor);
        },
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
          // Tab 2: Doctors
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctors',
                name: AppRoute.doctors.name,
                builder: (context, state) => const DoctorScreen(),
              ),
            ],
          ),
          // Tab 3: Booking (Placeholder)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/booking',
                name: AppRoute.booking.name,
                builder: (context, state) => const BookingScreen(),
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
