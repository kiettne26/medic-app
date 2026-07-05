import 'package:json_annotation/json_annotation.dart';

part 'booking_dto.g.dart';

@JsonSerializable()
class BookingDto {
  final String id;
  final String? patientId;
  final String? doctorId;
  final String? serviceId;
  final TimeSlotDto? timeSlot;
  final String? status;
  final String? notes;
  final String? doctorNotes;
  final String? cancellationReason;
  final double? totalAmount;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? paymentReference;
  final DateTime? paidAt;
  // Thông tin hiển thị (từ Backend)
  final String? doctorName;
  @JsonKey(readValue: _readDoctorAvatarUrl)
  final String? doctorAvatarUrl;
  final String? serviceName;
  final String? patientName;
  final String? patientAvatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingDto({
    required this.id,
    this.patientId,
    this.doctorId,
    this.serviceId,
    this.timeSlot,
    this.status,
    this.notes,
    this.doctorNotes,
    this.cancellationReason,
    this.totalAmount,
    this.paymentStatus,
    this.paymentMethod,
    this.paymentReference,
    this.paidAt,
    this.doctorName,
    this.doctorAvatarUrl,
    this.serviceName,
    this.patientName,
    this.patientAvatar,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingDto.fromJson(Map<String, dynamic> json) =>
      _$BookingDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BookingDtoToJson(this);
}

Object? _readDoctorAvatarUrl(Map json, String key) {
  return json['doctorAvatarUrl'] ?? json['doctorAvatar'];
}

@JsonSerializable()
class TimeSlotDto {
  final String id;
  final DateTime date;
  final String startTime; // LocalTime format "HH:mm:ss"
  final String endTime; // LocalTime format "HH:mm:ss"

  TimeSlotDto({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory TimeSlotDto.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSlotDtoToJson(this);
}

@JsonSerializable()
class CreateBookingRequest {
  final String doctorId;
  final String serviceId;
  final String timeSlotId;
  final String? notes;

  CreateBookingRequest({
    required this.doctorId,
    required this.serviceId,
    required this.timeSlotId,
    this.notes,
  });

  Map<String, dynamic> toJson() => _$CreateBookingRequestToJson(this);
}

class InitiatePaymentRequest {
  final String paymentMethod;

  InitiatePaymentRequest({required this.paymentMethod});

  Map<String, dynamic> toJson() => {'paymentMethod': paymentMethod};
}

class PaymentInitDto {
  final String bookingId;
  final double amount;
  final String paymentMethod;
  final String paymentStatus;
  final String? provider;
  final String? appTransId;
  final String? orderUrl;
  final String? qrCode;
  final String? zpTransToken;
  final String? orderToken;
  final String? message;

  PaymentInitDto({
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.provider,
    this.appTransId,
    this.orderUrl,
    this.qrCode,
    this.zpTransToken,
    this.orderToken,
    this.message,
  });

  factory PaymentInitDto.fromJson(Map<String, dynamic> json) {
    return PaymentInitDto(
      bookingId: json['bookingId'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['paymentMethod'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String? ?? '',
      provider: json['provider'] as String?,
      appTransId: json['appTransId'] as String?,
      orderUrl: json['orderUrl'] as String?,
      qrCode: json['qrCode'] as String?,
      zpTransToken: json['zpTransToken'] as String?,
      orderToken: json['orderToken'] as String?,
      message: json['message'] as String?,
    );
  }
}
