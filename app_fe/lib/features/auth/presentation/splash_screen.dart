import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../config/router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Add artificial delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');

    if (mounted) {
      if (token != null) {
        context.goNamed(AppRoute.home.name);
      } else {
        context.goNamed(AppRoute.login.name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services, size: 100, color: Colors.teal),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.teal),
          ],
        ),
      ),
    );
  }
}
