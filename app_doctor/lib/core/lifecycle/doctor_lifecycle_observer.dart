import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Widget theo dõi vòng đời ứng dụng web của bác sĩ
/// Tự động cập nhật trạng thái offline khi bác sĩ rời khỏi ứng dụng
class DoctorLifecycleObserver extends StatefulWidget {
  final Widget child;

  const DoctorLifecycleObserver({super.key, required this.child});

  @override
  State<DoctorLifecycleObserver> createState() =>
      _DoctorLifecycleObserverState();
}

class _DoctorLifecycleObserverState extends State<DoctorLifecycleObserver>
    with WidgetsBindingObserver {
  final _storage = const FlutterSecureStorage();
  final _dio = Dio(BaseOptions(baseUrl: 'https://medibook.dpdns.org'));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        _updateStatus(false);
        break;
      case AppLifecycleState.resumed:
        _updateStatus(true);
        break;
      default:
        break;
    }
  }

  Future<void> _updateStatus(bool isOnline) async {
    final userId = await _storage.read(key: 'user_id');
    if (userId == null || userId.isEmpty) return;
    try {
      await _dio.put(
        '/api/doctors/user/$userId/online-status',
        queryParameters: {'isOnline': isOnline},
      );
    } catch (e) {
      debugPrint('Warning: Could not update online status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
