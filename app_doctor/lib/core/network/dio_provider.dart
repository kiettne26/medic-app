import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  // Development: Use localhost with run_dev.bat (auto-runs adb reverse)
  final String baseUrl = 'http://localhost:8080';

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add Interceptors here (Logger, Auth Token)
  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  // Auth Interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        const storage = FlutterSecureStorage();
        final token = await storage.read(key: 'access_token');
        final userId = await storage.read(key: 'user_id');

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Explicitly pass X-User-Id to ensure backend receives it
        // (Useful if Gateway is behaving as a transparent proxy for some routes)
        if (userId != null) {
          options.headers['X-User-Id'] = userId;
        }

        return handler.next(options);
      },
    ),
  );

  return dio;
});
