import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/dto/booking_dto.dart';
import 'booking_list_controller.dart';
import 'payment_controller.dart';
import '../../home/presentation/home_controller.dart';

class BookingPaymentScreen extends ConsumerStatefulWidget {
  final BookingDto booking;
  final double totalPrice;

  const BookingPaymentScreen({
    super.key,
    required this.booking,
    required this.totalPrice,
  });

  @override
  ConsumerState<BookingPaymentScreen> createState() =>
      _BookingPaymentScreenState();
}

class _BookingPaymentScreenState extends ConsumerState<BookingPaymentScreen> with WidgetsBindingObserver {
  static const Duration _paymentHoldDuration = Duration(minutes: 15);

  String _selectedMethod = 'ZALOPAY';
  Timer? _countdownTimer;
  DateTime _now = DateTime.now();
  bool _hasShownSuccess = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(paymentControllerProvider);
      final currentBooking = state.booking ?? widget.booking;
      if (currentBooking.paymentStatus?.toUpperCase() == 'PAID') {
        _showSuccessDialog();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentControllerProvider);
    final payment = state.payment;
    final currentBooking = state.booking ?? widget.booking;
    final paymentStatus =
        currentBooking.paymentStatus?.toUpperCase() ?? 'UNPAID';
    final isPaid = paymentStatus == 'PAID';
    final bookingStatus = currentBooking.status?.toUpperCase() ?? '';
    final isCancelled =
        bookingStatus == 'CANCELED' || bookingStatus == 'CANCELLED';
    final isHoldExpired = !isPaid && _isPaymentHoldExpired(currentBooking);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: const Text(
          'Thanh toán lịch hẹn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF101418),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSummary(currentBooking, isPaid, isCancelled, isHoldExpired),
              if (!isPaid) ...[
                const SizedBox(height: 16),
                _buildRequiredPaymentNotice(currentBooking, isHoldExpired),
              ],
              const SizedBox(height: 16),
              _buildPaymentMethods(isPaid || isHoldExpired || isCancelled),
              if (payment != null) ...[
                const SizedBox(height: 16),
                _buildPaymentOrder(payment),
              ],
              if (state.error != null) ...[
                const SizedBox(height: 16),
                _buildError(state.error!),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(
        state,
        isPaid,
        payment,
        isHoldExpired,
        isCancelled,
      ),
    );
  }

  Widget _buildSummary(
    BookingDto booking,
    bool isPaid,
    bool isCancelled,
    bool isHoldExpired,
  ) {
    final amount = booking.totalAmount ?? widget.totalPrice;
    final badgeText = isPaid
        ? 'Đã thanh toán'
        : isCancelled || isHoldExpired
        ? 'Hết hạn giữ chỗ'
        : 'Đang giữ chỗ thanh toán';
    final badgeColor = isPaid
        ? const Color(0xFF00C853)
        : isCancelled || isHoldExpired
        ? const Color(0xFFFF5252)
        : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF297EFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPaid ? Icons.verified_rounded : Icons.receipt_long_rounded,
                  color: const Color(0xFF297EFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceName ?? 'Dịch vụ khám',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101418),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mã lịch hẹn: #${booking.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5E718D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán',
                style: TextStyle(fontSize: 14, color: Color(0xFF5E718D)),
              ),
              Text(
                '${_formatPrice(amount)}đ',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF297EFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildStatusBadge(badgeText, badgeColor),
        ],
      ),
    );
  }

  Widget _buildRequiredPaymentNotice(BookingDto booking, bool isHoldExpired) {
    final remaining = _remainingPaymentHold(booking);
    final countdownText = remaining != null
        ? _formatRemaining(remaining)
        : null;
    final color = isHoldExpired
        ? const Color(0xFFD32F2F)
        : const Color(0xFFE68A00);
    final backgroundColor = isHoldExpired
        ? const Color(0xFFFFF2F2)
        : const Color(0xFFFFF7E6);
    final borderColor = isHoldExpired
        ? const Color(0xFFFFD1D1)
        : const Color(0xFFFFC46B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isHoldExpired ? Icons.error_outline_rounded : Icons.timer_outlined,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHoldExpired
                      ? 'Thời gian giữ chỗ đã hết. Lịch sẽ được hủy tự động và khung giờ này được mở lại cho người khác.'
                      : 'Xin lỗi vì sự bất tiện. Để tránh tình trạng khung giờ khám bị bỏ trống, hệ thống chỉ giữ chỗ trong 15 phút. Vui lòng thanh toán phí dịch vụ trước khi hết thời gian giữ chỗ.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isHoldExpired
                        ? const Color(0xFF8C1D1D)
                        : const Color(0xFF7A4A00),
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!isHoldExpired && countdownText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Còn lại: $countdownText',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF101418),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethods(bool isDisabled) {
    return IgnorePointer(
      ignoring: isDisabled,
      child: Opacity(
        opacity: isDisabled ? 0.55 : 1,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Phương thức thanh toán online',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101418),
                ),
              ),
              const SizedBox(height: 14),
              _buildMethodTile(
                method: 'ZALOPAY',
                title: 'ZaloPay',
                subtitle: 'Thanh toán bằng ví ZaloPay hoặc Zalo',
                icon: Icons.account_balance_wallet_rounded,
                color: const Color(0xFF0068FF),
              ),
              const SizedBox(height: 12),
              _buildMethodTile(
                method: 'BANK_APP',
                title: 'App ngân hàng',
                subtitle: 'Thanh toán bằng QR VietQR qua app ngân hàng',
                icon: Icons.account_balance_rounded,
                color: const Color(0xFF00A86B),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodTile({
    required String method,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedMethod == method;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = method),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : const Color(0xFFF5F7F8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101418),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5E718D),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? color : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOrder(PaymentInitDto payment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF297EFF).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đơn thanh toán đã được tạo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF101418),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            payment.appTransId ?? '',
            style: const TextStyle(fontSize: 13, color: Color(0xFF5E718D)),
          ),
          if (_looksLikeUrl(payment.qrCode)) ...[
            const SizedBox(height: 16),
            Center(
              child: Image.network(
                payment.qrCode!,
                width: 190,
                height: 190,
                fit: BoxFit.contain,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: payment.orderUrl ?? ''));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã sao chép link thanh toán vào bộ nhớ tạm.'),
                  ),
                );
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Sao chép link thanh toán'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF297EFF),
                side: const BorderSide(color: Color(0xFF297EFF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Đây là môi trường ZaloPay Sandbox. Nếu dùng ví, hãy quét QR bằng app ZaloPay Sandbox; nếu dùng cổng web, có thể dùng thẻ test. Sau khi hoàn tất, quay lại đây và bấm kiểm tra trạng thái.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF5E718D),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD1D1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFD32F2F)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Color(0xFF8C1D1D), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    PaymentState state,
    bool isPaid,
    PaymentInitDto? payment,
    bool isHoldExpired,
    bool isCancelled,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPaid)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(bookingListControllerProvider);
                  context.go('/booking');
                },
                icon: const Icon(Icons.event_available_rounded),
                label: const Text('Xem lịch hẹn'),
                style: _primaryButtonStyle(),
              ),
            )
          else if (isHoldExpired || isCancelled) ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(bookingListControllerProvider);
                  context.go('/booking');
                },
                icon: const Icon(Icons.event_repeat_rounded),
                label: const Text('Chọn khung giờ khác'),
                style: _primaryButtonStyle(),
              ),
            ),
            if (!isCancelled) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: state.isCheckingStatus
                      ? null
                      : _refreshPaymentStatus,
                  icon: state.isCheckingStatus
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: const Text('Cập nhật trạng thái'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF297EFF),
                    side: const BorderSide(color: Color(0xFF297EFF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: state.isLoading ? null : _startPayment,
                icon: state.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.open_in_new_rounded),
                label: Text(
                  payment == null
                      ? 'Thanh toán online ngay'
                      : 'Mở lại trang thanh toán',
                ),
                style: _primaryButtonStyle(),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: state.isCheckingStatus
                    ? null
                    : _refreshPaymentStatus,
                icon: state.isCheckingStatus
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                label: const Text('Tôi đã thanh toán'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF297EFF),
                  side: const BorderSide(color: Color(0xFF297EFF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF297EFF),
      foregroundColor: Colors.white,
      disabledBackgroundColor: Colors.grey[300],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Future<void> _startPayment() async {
    final currentBooking =
        ref.read(paymentControllerProvider).booking ?? widget.booking;
    if (_isBookingCancelled(currentBooking) ||
        _isPaymentHoldExpired(currentBooking)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Thời gian giữ chỗ đã hết, vui lòng chọn khung giờ khác.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final existingPayment = ref.read(paymentControllerProvider).payment;
    final payment =
        existingPayment ??
        await ref
            .read(paymentControllerProvider.notifier)
            .initiatePayment(
              bookingId: widget.booking.id,
              paymentMethod: _selectedMethod,
            );

    if (payment == null) return;

    final orderUrl = payment.orderUrl;
    if (orderUrl == null || orderUrl.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa nhận được link thanh toán.'),
        ),
      );
      return;
    }

    await launchUrl(
      Uri.parse(orderUrl),
      mode: LaunchMode.inAppBrowserView,
    );
  }

  Future<void> _refreshPaymentStatus() async {
    final booking = await ref
        .read(paymentControllerProvider.notifier)
        .refreshPaymentStatus(widget.booking.id);

    if (!mounted || booking == null) return;

    final isPaid = booking.paymentStatus?.toUpperCase() == 'PAID';
    final isCancelled = _isBookingCancelled(booking);

    if (isPaid) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCancelled
                ? 'Lịch đã hết thời gian giữ chỗ và được hủy tự động.'
                : 'Thanh toán chưa hoàn tất, vui lòng thử lại sau.',
          ),
          backgroundColor: isCancelled ? const Color(0xFFFF5252) : Colors.orange,
        ),
      );
    }
  }

  bool _isBookingCancelled(BookingDto booking) {
    final status = booking.status?.toUpperCase() ?? '';
    return status == 'CANCELED' || status == 'CANCELLED';
  }

  bool _isPaymentHoldExpired(BookingDto booking) {
    if (_isBookingCancelled(booking)) return true;
    final paymentStatus = booking.paymentStatus?.toUpperCase() ?? 'UNPAID';
    if (paymentStatus == 'PAID') return false;

    final remaining = _remainingPaymentHold(booking);
    return remaining != null && remaining <= Duration.zero;
  }

  Duration? _remainingPaymentHold(BookingDto booking) {
    final createdAt = booking.createdAt;
    if (createdAt == null) return null;

    final deadline = createdAt.add(_paymentHoldDuration);
    final remaining = deadline.difference(_now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String _formatRemaining(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool _looksLikeUrl(String? value) {
    if (value == null) return false;
    return value.startsWith('http://') || value.startsWith('https://');
  }

  String _formatPrice(double price) {
    return NumberFormat('#,###', 'vi').format(price);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPaymentStatus();
    }
  }

  void _showSuccessDialog() {
    if (_hasShownSuccess) return;
    _hasShownSuccess = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Đặt lịch thành công!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101418),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lịch khám của bạn đã được thanh toán và xác nhận thành công.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5E718D),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  height: 1,
                  color: const Color(0xFFDADFE7),
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Bác sĩ:', widget.booking.doctorName ?? 'Bác sĩ'),
                const SizedBox(height: 8),
                _buildDetailRow('Dịch vụ:', widget.booking.serviceName ?? 'Tư vấn khám'),
                const SizedBox(height: 8),
                _buildDetailRow('Ngày khám:', widget.booking.timeSlot?.date?.toString() ?? ''),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Thời gian:',
                  '${widget.booking.timeSlot?.startTime.substring(0, 5) ?? ''} - ${widget.booking.timeSlot?.endTime.substring(0, 5) ?? ''}',
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ref.invalidate(bookingListControllerProvider);
                          ref.invalidate(homeControllerProvider);
                          context.go('/home');
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF297EFF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Trang chủ',
                          style: TextStyle(
                            color: Color(0xFF297EFF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ref.invalidate(bookingListControllerProvider);
                          ref.invalidate(homeControllerProvider);
                          context.go('/booking');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF297EFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Xem lịch hẹn',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5E718D),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF101418),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
