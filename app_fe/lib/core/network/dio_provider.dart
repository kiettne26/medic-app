import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';

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

  return dio;
});
