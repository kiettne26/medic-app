import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/booking_repository.dart';
import '../data/dto/booking_dto.dart';

final paymentControllerProvider =
    StateNotifierProvider.autoDispose<PaymentController, PaymentState>((ref) {
      return PaymentController(ref.watch(bookingRepositoryProvider));
    });

class PaymentState {
  final bool isLoading;
  final bool isCheckingStatus;
  final String? error;
  final PaymentInitDto? payment;
  final BookingDto? booking;

  const PaymentState({
    this.isLoading = false,
    this.isCheckingStatus = false,
    this.error,
    this.payment,
    this.booking,
  });

  PaymentState copyWith({
    bool? isLoading,
    bool? isCheckingStatus,
    String? error,
    PaymentInitDto? payment,
    BookingDto? booking,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      isCheckingStatus: isCheckingStatus ?? this.isCheckingStatus,
      error: error,
      payment: payment ?? this.payment,
      booking: booking ?? this.booking,
    );
  }
}

class PaymentController extends StateNotifier<PaymentState> {
  final BookingRepository _repository;

  PaymentController(this._repository) : super(const PaymentState());

  Future<PaymentInitDto?> initiatePayment({
    required String bookingId,
    required String paymentMethod,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final payment = await _repository.initiatePayment(
        bookingId,
        InitiatePaymentRequest(paymentMethod: paymentMethod),
      );
      state = state.copyWith(isLoading: false, payment: payment, error: null);
      return payment;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<BookingDto?> refreshPaymentStatus(String bookingId) async {
    try {
      state = state.copyWith(isCheckingStatus: true, error: null);
      final booking = await _repository.refreshPaymentStatus(bookingId);
      state = state.copyWith(
        isCheckingStatus: false,
        booking: booking,
        error: null,
      );
      return booking;
    } catch (e) {
      state = state.copyWith(isCheckingStatus: false, error: e.toString());
      return null;
    }
  }
}
