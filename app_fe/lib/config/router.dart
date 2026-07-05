import 'package:app_fe/features/auth/presentation/login_screen.dart';
import 'package:app_fe/features/auth/presentation/register_screen.dart';
import 'package:app_fe/features/auth/presentation/splash_screen.dart';
import 'package:app_fe/features/booking/data/dto/booking_dto.dart';
import 'package:app_fe/features/booking/data/dto/service_dto.dart';
import 'package:app_fe/features/booking/presentation/booking_confirmation_screen.dart';
import 'package:app_fe/features/booking/presentation/booking_detail_screen.dart';
import 'package:app_fe/features/booking/presentation/booking_payment_screen.dart';
import 'package:app_fe/features/booking/presentation/booking_screen.dart';
import 'package:app_fe/features/booking/presentation/select_datetime_screen.dart';
import 'package:app_fe/features/booking/presentation/select_doctor_screen.dart';
import 'package:app_fe/features/booking/presentation/select_service_screen.dart';
import 'package:app_fe/features/chat/presentation/chat_screen.dart';
import 'package:app_fe/features/chatbot/presentation/chatbot_screen.dart';
import 'package:app_fe/features/doctor/data/dto/doctor_dto.dart';
import 'package:app_fe/features/doctor/presentation/doctor_detail_screen.dart';
import 'package:app_fe/features/doctor/presentation/doctor_screen.dart';
import 'package:app_fe/features/home/presentation/home_screen.dart';
import 'package:app_fe/features/home/presentation/main_layout.dart';
import 'package:app_fe/features/notification/presentation/notification_screen.dart';
import 'package:app_fe/features/profile/presentation/edit_profile_screen.dart';
import 'package:app_fe/features/profile/presentation/email_verification_screen.dart';
import 'package:app_fe/features/profile/presentation/help_support_screen.dart';
import 'package:app_fe/features/profile/presentation/medical_history_screen.dart';
import 'package:app_fe/features/profile/presentation/profile_screen.dart';
import 'package:app_fe/features/settings/presentation/about_app_screen.dart';
import 'package:app_fe/features/settings/presentation/security_privacy_screen.dart';
import 'package:app_fe/features/settings/presentation/settings_screen.dart';
import 'package:app_fe/features/settings/presentation/terms_of_use_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Define Routes
enum AppRoute {
  splash,
  login,
  register,
  home,
  doctors,
  booking,
  bookingDetail,
  profile,
  doctorDetail,
  editProfile,
  emailVerification,
  selectService,
  selectDateTime,
  selectDoctor,
  bookingConfirmation,
  bookingPayment,
  settings,
  securityPrivacy,
  termsOfUse,
  aboutApp,
  notification,
  chat,
  chatByDoctor,
  chatbot,
  medicalHistory,
  helpSupport,
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
      GoRoute(
        path: '/doctor/:id',
        name: AppRoute.doctorDetail.name,
        builder: (context, state) {
          final doctorId = state.pathParameters['id'] ?? '';
          return DoctorDetailScreen(doctorId: doctorId);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        name: AppRoute.editProfile.name,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/medical-history',
        name: AppRoute.medicalHistory.name,
        builder: (context, state) => const MedicalHistoryScreen(),
      ),
      GoRoute(
        path: '/help-support',
        name: AppRoute.helpSupport.name,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/email-verification',
        name: AppRoute.emailVerification.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return EmailVerificationScreen(
            userId: (extra?['userId'] as String?) ?? '',
            email: (extra?['email'] as String?) ?? '',
          );
        },
      ),
      GoRoute(
        path: '/settings',
        name: AppRoute.settings.name,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/security-privacy',
        name: AppRoute.securityPrivacy.name,
        builder: (context, state) => const SecurityPrivacyScreen(),
      ),
      GoRoute(
        path: '/terms-of-use',
        name: AppRoute.termsOfUse.name,
        builder: (context, state) => const TermsOfUseScreen(),
      ),
      GoRoute(
        path: '/about-app',
        name: AppRoute.aboutApp.name,
        builder: (context, state) => const AboutAppScreen(),
      ),
      GoRoute(
        path: '/notification',
        name: AppRoute.notification.name,
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/chatbot',
        name: AppRoute.chatbot.name,
        builder: (context, state) => const ChatbotScreen(),
      ),
      GoRoute(
        path: '/booking-detail',
        name: AppRoute.bookingDetail.name,
        builder: (context, state) {
          final booking = state.extra as BookingDto;
          return BookingDetailScreen(booking: booking);
        },
      ),
      GoRoute(
        path: '/select-service',
        name: AppRoute.selectService.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final doctor = extra != null ? extra['doctor'] as dynamic : null;

          return SelectServiceScreen(doctor: doctor);
        },
      ),
      GoRoute(
        path: '/select-doctor',
        name: AppRoute.selectDoctor.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final services = (extra?['services'] as List<ServiceDto>?) ?? [];
          final rawTotalPrice = extra?['totalPrice'];
          final totalPrice = rawTotalPrice is num
              ? rawTotalPrice.toDouble()
              : 0.0;

          return SelectDoctorScreen(
            selectedServices: services,
            totalPrice: totalPrice,
          );
        },
      ),
      GoRoute(
        path: '/select-datetime',
        name: AppRoute.selectDateTime.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final services = (extra?['services'] as List<ServiceDto>?) ?? [];
          final rawTotalPrice = extra?['totalPrice'];
          final totalPrice = rawTotalPrice is num
              ? rawTotalPrice.toDouble()
              : 0.0;
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
      GoRoute(
        path: '/booking-confirmation',
        name: AppRoute.bookingConfirmation.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final services = (extra?['services'] as List<ServiceDto>?) ?? [];
          final rawTotalPrice = extra?['totalPrice'];
          final totalPrice = rawTotalPrice is num
              ? rawTotalPrice.toDouble()
              : 0.0;
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
      GoRoute(
        path: '/booking-payment',
        name: AppRoute.bookingPayment.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final booking = extra?['booking'] as BookingDto;
          final rawTotalPrice = extra?['totalPrice'];
          final totalPrice = rawTotalPrice is num
              ? rawTotalPrice.toDouble()
              : 0.0;

          return BookingPaymentScreen(booking: booking, totalPrice: totalPrice);
        },
      ),
      GoRoute(
        path: '/chat',
        name: AppRoute.chat.name,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final doctor = extra?['doctor'] as DoctorDto? ?? DoctorDto(id: '');
          return ChatScreen(doctor: doctor);
        },
      ),
      GoRoute(
        path: '/chat/:doctorId',
        name: AppRoute.chatByDoctor.name,
        builder: (context, state) {
          final doctorId = state.pathParameters['doctorId'] ?? '';
          return ChatScreen(doctor: DoctorDto(id: doctorId));
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: AppRoute.home.name,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctors',
                name: AppRoute.doctors.name,
                builder: (context, state) {
                  final specialty = state.uri.queryParameters['specialty'];
                  final search = state.uri.queryParameters['search'];
                  return DoctorScreen(
                    initialSpecialty: specialty,
                    initialSearch: search,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/booking',
                name: AppRoute.booking.name,
                builder: (context, state) => const BookingScreen(),
              ),
            ],
          ),
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
