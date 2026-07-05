import 'dart:async';

import 'package:app_fe/features/profile/data/dto/profile_dto.dart';
import 'package:app_fe/features/profile/data/source/profile_api.dart';
import 'package:app_fe/features/profile/presentation/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String userId;
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  static const _resendCooldownSeconds = 60;

  final _storage = const FlutterSecureStorage();
  final _codeController = TextEditingController();

  Timer? _timer;
  int _remainingSeconds = 0;
  int _resendSeconds = 0;
  bool _isSending = false;
  bool _isVerifying = false;
  String? _message;
  bool _messageIsError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendCode());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
      _message = null;
      _messageIsError = false;
    });

    final result = await ref
        .read(profileApiProvider)
        .requestEmailVerification(widget.userId, widget.email);

    if (!mounted) return;

    if (result == null) {
      setState(() {
        _isSending = false;
        _message = 'Không gửi được mã xác thực. Vui lòng thử lại.';
        _messageIsError = true;
      });
      return;
    }

    setState(() {
      _isSending = false;
      _remainingSeconds = result.expiresInSeconds;
      _resendSeconds = _resendCooldownSeconds;
      _message = 'Mã xác thực đã được gửi đến email của bạn.';
      _messageIsError = false;
    });
    _startTimer();
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      _showSnackBar('Vui lòng nhập mã gồm 6 số.', isError: true);
      return;
    }
    if (_remainingSeconds <= 0) {
      _showSnackBar('Mã đã hết hạn. Vui lòng gửi lại mã.', isError: true);
      return;
    }

    setState(() => _isVerifying = true);
    final profile = await ref
        .read(profileApiProvider)
        .confirmEmailVerification(widget.userId, code);

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (profile != null && profile.emailVerified) {
      await _storage.write(key: 'user_email', value: profile.email ?? widget.email);
      await _storage.write(key: 'email_verified', value: 'true');
      await ref.read(userProvider.notifier).refreshProfile();

      if (mounted) {
        _showSnackBar('Email đã được xác thực.');
        context.pop<ProfileDto>(profile);
      }
      return;
    }

    _showSnackBar('Mã xác thực không đúng hoặc đã hết hạn.', isError: true);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 0 && _resendSeconds <= 0) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) _remainingSeconds--;
        if (_resendSeconds > 0) _resendSeconds--;
      });
    });
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF00C853),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canResend = !_isSending && _resendSeconds == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildIcon(),
                    const SizedBox(height: 24),
                    const Text(
                      'Xác thực email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF101418),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Nhập mã 6 số đã gửi đến ${widget.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF5E718D),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildCountdown(),
                    const SizedBox(height: 24),
                    _buildCodeField(),
                    if (_message != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _message!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _messageIsError ? Colors.red : const Color(0xFF00A35C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isVerifying ? null : _verifyCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A7FFF),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isVerifying
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Xác thực',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: canResend ? _sendCode : null,
                      child: Text(
                        _isSending
                            ? 'Đang gửi mã...'
                            : _resendSeconds > 0
                                ? 'Gửi lại sau ${_formatDuration(_resendSeconds)}'
                                : 'Gửi lại mã',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: const Color(0xFF101418),
          ),
          const Expanded(
            child: Text(
              'Xác thực email',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF101418),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: const Color(0xFF2A7FFF).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.mark_email_read_outlined,
          color: Color(0xFF2A7FFF),
          size: 42,
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    final expired = _remainingSeconds <= 0 && !_isSending;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: expired ? const Color(0xFFFFF1F2) : const Color(0xFFF1F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: expired ? const Color(0xFFFFCCD5) : const Color(0xFFD6E8FF),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            color: expired ? Colors.red : const Color(0xFF2A7FFF),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _isSending
                ? 'Đang gửi mã...'
                : expired
                    ? 'Mã đã hết hạn'
                    : 'Mã hết hạn sau ${_formatDuration(_remainingSeconds)}',
            style: TextStyle(
              color: expired ? Colors.red : const Color(0xFF1E5EA8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeField() {
    return TextField(
      controller: _codeController,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 6,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      style: const TextStyle(
        color: Color(0xFF101418),
        fontSize: 28,
        fontWeight: FontWeight.bold,

      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: '000000',
        hintStyle: TextStyle(
          color: Colors.grey.withOpacity(0.45),
  
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A7FFF), width: 1.5),
        ),
      ),
    );
  }
}
