import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../features/dashboard/presentation/admin_layout.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/chat/presentation/pages/messages_screen.dart';
import '../features/chat/presentation/pages/chat_screen.dart';
import '../features/chat/domain/models/conversation.dart';
import '../features/notification/presentation/pages/notification_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) async {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access_token');
      final isLoggedIn = token != null;
      final isLoggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      if (isLoggedIn && isLoggingIn) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AdminLayout(
            currentLocation: state.uri.toString(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/appointments',
            builder: (context, state) =>
                const Center(child: Text('Appointments Screen')),
          ),
          GoRoute(
            path: '/patients',
            builder: (context, state) =>
                const Center(child: Text('Patients Screen')),
          ),
          GoRoute(
            path: '/messages',
            builder: (context, state) => const MessagesScreen(),
          ),
          GoRoute(
            path: '/messages/detail',
            builder: (context, state) {
              final conversation = state.extra as Conversation;
              return ChatScreen(conversation: conversation);
            },
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) =>
                const Center(child: Text('Settings Screen')),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ],
  );
});
