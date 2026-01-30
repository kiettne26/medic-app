// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BookingDto _$BookingDtoFromJson(Map<String, dynamic> json) {
  return _BookingDto.fromJson(json);
}

/// @nodoc
mixin _$BookingDto {
  String get id => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  String get doctorId => throw _privateConstructorUsedError;
  String get serviceId => throw _privateConstructorUsedError;
  TimeSlotDto get timeSlot => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // BookingStatus enum as String
  String? get notes => throw _privateConstructorUsedError;
  String? get doctorNotes => throw _privateConstructorUsedError;
  String? get cancellationReason => throw _privateConstructorUsedError;
  String? get patientName => throw _privateConstructorUsedError;
  String? get patientAvatar => throw _privateConstructorUsedError;
  String? get doctorName => throw _privateConstructorUsedError;
  String? get doctorAvatar => throw _privateConstructorUsedError;
  String? get serviceName => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this BookingDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingDtoCopyWith<BookingDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingDtoCopyWith<$Res> {
  factory $BookingDtoCopyWith(
    BookingDto value,
    $Res Function(BookingDto) then,
  ) = _$BookingDtoCopyWithImpl<$Res, BookingDto>;
  @useResult
  $Res call({
    String id,
    String patientId,
    String doctorId,
    String serviceId,
    TimeSlotDto timeSlot,
    String status,
    String? notes,
    String? doctorNotes,
    String? cancellationReason,
    String? patientName,
    String? patientAvatar,
    String? doctorName,
    String? doctorAvatar,
    String? serviceName,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  $TimeSlotDtoCopyWith<$Res> get timeSlot;
}

/// @nodoc
class _$BookingDtoCopyWithImpl<$Res, $Val extends BookingDto>
    implements $BookingDtoCopyWith<$Res> {
  _$BookingDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? doctorId = null,
    Object? serviceId = null,
    Object? timeSlot = null,
    Object? status = null,
    Object? notes = freezed,
    Object? doctorNotes = freezed,
    Object? cancellationReason = freezed,
    Object? patientName = freezed,
    Object? patientAvatar = freezed,
    Object? doctorName = freezed,
    Object? doctorAvatar = freezed,
    Object? serviceName = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            patientId: null == patientId
                ? _value.patientId
                : patientId // ignore: cast_nullable_to_non_nullable
                      as String,
            doctorId: null == doctorId
                ? _value.doctorId
                : doctorId // ignore: cast_nullable_to_non_nullable
                      as String,
            serviceId: null == serviceId
                ? _value.serviceId
                : serviceId // ignore: cast_nullable_to_non_nullable
                      as String,
            timeSlot: null == timeSlot
                ? _value.timeSlot
                : timeSlot // ignore: cast_nullable_to_non_nullable
                      as TimeSlotDto,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            doctorNotes: freezed == doctorNotes
                ? _value.doctorNotes
                : doctorNotes // ignore: cast_nullable_to_non_nullable
                      as String?,
            cancellationReason: freezed == cancellationReason
                ? _value.cancellationReason
                : cancellationReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            patientName: freezed == patientName
                ? _value.patientName
                : patientName // ignore: cast_nullable_to_non_nullable
                      as String?,
            patientAvatar: freezed == patientAvatar
                ? _value.patientAvatar
                : patientAvatar // ignore: cast_nullable_to_non_nullable
                      as String?,
            doctorName: freezed == doctorName
                ? _value.doctorName
                : doctorName // ignore: cast_nullable_to_non_nullable
                      as String?,
            doctorAvatar: freezed == doctorAvatar
                ? _value.doctorAvatar
                : doctorAvatar // ignore: cast_nullable_to_non_nullable
                      as String?,
            serviceName: freezed == serviceName
                ? _value.serviceName
                : serviceName // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of BookingDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeSlotDtoCopyWith<$Res> get timeSlot {
    return $TimeSlotDtoCopyWith<$Res>(_value.timeSlot, (value) {
      return _then(_value.copyWith(timeSlot: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BookingDtoImplCopyWith<$Res>
    implements $BookingDtoCopyWith<$Res> {
  factory _$$BookingDtoImplCopyWith(
    _$BookingDtoImpl value,
    $Res Function(_$BookingDtoImpl) then,
  ) = __$$BookingDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String patientId,
    String doctorId,
    String serviceId,
    TimeSlotDto timeSlot,
    String status,
    String? notes,
    String? doctorNotes,
    String? cancellationReason,
    String? patientName,
    String? patientAvatar,
    String? doctorName,
    String? doctorAvatar,
    String? serviceName,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  @override
  $TimeSlotDtoCopyWith<$Res> get timeSlot;
}

/// @nodoc
class __$$BookingDtoImplCopyWithImpl<$Res>
    extends _$BookingDtoCopyWithImpl<$Res, _$BookingDtoImpl>
    implements _$$BookingDtoImplCopyWith<$Res> {
  __$$BookingDtoImplCopyWithImpl(
    _$BookingDtoImpl _value,
    $Res Function(_$BookingDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BookingDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? doctorId = null,
    Object? serviceId = null,
    Object? timeSlot = null,
    Object? status = null,
    Object? notes = freezed,
    Object? doctorNotes = freezed,
    Object? cancellationReason = freezed,
    Object? patientName = freezed,
    Object? patientAvatar = freezed,
    Object? doctorName = freezed,
    Object? doctorAvatar = freezed,
    Object? serviceName = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$BookingDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        patientId: null == patientId
            ? _value.patientId
            : patientId // ignore: cast_nullable_to_non_nullable
                  as String,
        doctorId: null == doctorId
            ? _value.doctorId
            : doctorId // ignore: cast_nullable_to_non_nullable
                  as String,
        serviceId: null == serviceId
            ? _value.serviceId
            : serviceId // ignore: cast_nullable_to_non_nullable
                  as String,
        timeSlot: null == timeSlot
            ? _value.timeSlot
            : timeSlot // ignore: cast_nullable_to_non_nullable
                  as TimeSlotDto,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        doctorNotes: freezed == doctorNotes
            ? _value.doctorNotes
            : doctorNotes // ignore: cast_nullable_to_non_nullable
                  as String?,
        cancellationReason: freezed == cancellationReason
            ? _value.cancellationReason
            : cancellationReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        patientName: freezed == patientName
            ? _value.patientName
            : patientName // ignore: cast_nullable_to_non_nullable
                  as String?,
        patientAvatar: freezed == patientAvatar
            ? _value.patientAvatar
            : patientAvatar // ignore: cast_nullable_to_non_nullable
                  as String?,
        doctorName: freezed == doctorName
            ? _value.doctorName
            : doctorName // ignore: cast_nullable_to_non_nullable
                  as String?,
        doctorAvatar: freezed == doctorAvatar
            ? _value.doctorAvatar
            : doctorAvatar // ignore: cast_nullable_to_non_nullable
                  as String?,
        serviceName: freezed == serviceName
            ? _value.serviceName
            : serviceName // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingDtoImpl implements _BookingDto {
  const _$BookingDtoImpl({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.serviceId,
    required this.timeSlot,
    required this.status,
    required this.notes,
    required this.doctorNotes,
    required this.cancellationReason,
    required this.patientName,
    required this.patientAvatar,
    required this.doctorName,
    required this.doctorAvatar,
    required this.serviceName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$BookingDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String patientId;
  @override
  final String doctorId;
  @override
  final String serviceId;
  @override
  final TimeSlotDto timeSlot;
  @override
  final String status;
  // BookingStatus enum as String
  @override
  final String? notes;
  @override
  final String? doctorNotes;
  @override
  final String? cancellationReason;
  @override
  final String? patientName;
  @override
  final String? patientAvatar;
  @override
  final String? doctorName;
  @override
  final String? doctorAvatar;
  @override
  final String? serviceName;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'BookingDto(id: $id, patientId: $patientId, doctorId: $doctorId, serviceId: $serviceId, timeSlot: $timeSlot, status: $status, notes: $notes, doctorNotes: $doctorNotes, cancellationReason: $cancellationReason, patientName: $patientName, patientAvatar: $patientAvatar, doctorName: $doctorName, doctorAvatar: $doctorAvatar, serviceName: $serviceName, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            (identical(other.timeSlot, timeSlot) ||
                other.timeSlot == timeSlot) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.doctorNotes, doctorNotes) ||
                other.doctorNotes == doctorNotes) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            (identical(other.patientName, patientName) ||
                other.patientName == patientName) &&
            (identical(other.patientAvatar, patientAvatar) ||
                other.patientAvatar == patientAvatar) &&
            (identical(other.doctorName, doctorName) ||
                other.doctorName == doctorName) &&
            (identical(other.doctorAvatar, doctorAvatar) ||
                other.doctorAvatar == doctorAvatar) &&
            (identical(other.serviceName, serviceName) ||
                other.serviceName == serviceName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    patientId,
    doctorId,
    serviceId,
    timeSlot,
    status,
    notes,
    doctorNotes,
    cancellationReason,
    patientName,
    patientAvatar,
    doctorName,
    doctorAvatar,
    serviceName,
    createdAt,
    updatedAt,
  );

  /// Create a copy of BookingDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingDtoImplCopyWith<_$BookingDtoImpl> get copyWith =>
      __$$BookingDtoImplCopyWithImpl<_$BookingDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingDtoImplToJson(this);
  }
}

abstract class _BookingDto implements BookingDto {
  const factory _BookingDto({
    required final String id,
    required final String patientId,
    required final String doctorId,
    required final String serviceId,
    required final TimeSlotDto timeSlot,
    required final String status,
    required final String? notes,
    required final String? doctorNotes,
    required final String? cancellationReason,
    required final String? patientName,
    required final String? patientAvatar,
    required final String? doctorName,
    required final String? doctorAvatar,
    required final String? serviceName,
    required final DateTime? createdAt,
    required final DateTime? updatedAt,
  }) = _$BookingDtoImpl;

  factory _BookingDto.fromJson(Map<String, dynamic> json) =
      _$BookingDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get patientId;
  @override
  String get doctorId;
  @override
  String get serviceId;
  @override
  TimeSlotDto get timeSlot;
  @override
  String get status; // BookingStatus enum as String
  @override
  String? get notes;
  @override
  String? get doctorNotes;
  @override
  String? get cancellationReason;
  @override
  String? get patientName;
  @override
  String? get patientAvatar;
  @override
  String? get doctorName;
  @override
  String? get doctorAvatar;
  @override
  String? get serviceName;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of BookingDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingDtoImplCopyWith<_$BookingDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimeSlotDto _$TimeSlotDtoFromJson(Map<String, dynamic> json) {
  return _TimeSlotDto.fromJson(json);
}

/// @nodoc
mixin _$TimeSlotDto {
  String get id => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError; // LocalDate as String
  String get startTime =>
      throw _privateConstructorUsedError; // LocalTime as String
  String get endTime => throw _privateConstructorUsedError;

  /// Serializes this TimeSlotDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeSlotDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeSlotDtoCopyWith<TimeSlotDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeSlotDtoCopyWith<$Res> {
  factory $TimeSlotDtoCopyWith(
    TimeSlotDto value,
    $Res Function(TimeSlotDto) then,
  ) = _$TimeSlotDtoCopyWithImpl<$Res, TimeSlotDto>;
  @useResult
  $Res call({String id, String date, String startTime, String endTime});
}

/// @nodoc
class _$TimeSlotDtoCopyWithImpl<$Res, $Val extends TimeSlotDto>
    implements $TimeSlotDtoCopyWith<$Res> {
  _$TimeSlotDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeSlotDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? startTime = null,
    Object? endTime = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as String,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimeSlotDtoImplCopyWith<$Res>
    implements $TimeSlotDtoCopyWith<$Res> {
  factory _$$TimeSlotDtoImplCopyWith(
    _$TimeSlotDtoImpl value,
    $Res Function(_$TimeSlotDtoImpl) then,
  ) = __$$TimeSlotDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String date, String startTime, String endTime});
}

/// @nodoc
class __$$TimeSlotDtoImplCopyWithImpl<$Res>
    extends _$TimeSlotDtoCopyWithImpl<$Res, _$TimeSlotDtoImpl>
    implements _$$TimeSlotDtoImplCopyWith<$Res> {
  __$$TimeSlotDtoImplCopyWithImpl(
    _$TimeSlotDtoImpl _value,
    $Res Function(_$TimeSlotDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimeSlotDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? startTime = null,
    Object? endTime = null,
  }) {
    return _then(
      _$TimeSlotDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as String,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeSlotDtoImpl implements _TimeSlotDto {
  const _$TimeSlotDtoImpl({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory _$TimeSlotDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeSlotDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String date;
  // LocalDate as String
  @override
  final String startTime;
  // LocalTime as String
  @override
  final String endTime;

  @override
  String toString() {
    return 'TimeSlotDto(id: $id, date: $date, startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeSlotDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, date, startTime, endTime);

  /// Create a copy of TimeSlotDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeSlotDtoImplCopyWith<_$TimeSlotDtoImpl> get copyWith =>
      __$$TimeSlotDtoImplCopyWithImpl<_$TimeSlotDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeSlotDtoImplToJson(this);
  }
}

abstract class _TimeSlotDto implements TimeSlotDto {
  const factory _TimeSlotDto({
    required final String id,
    required final String date,
    required final String startTime,
    required final String endTime,
  }) = _$TimeSlotDtoImpl;

  factory _TimeSlotDto.fromJson(Map<String, dynamic> json) =
      _$TimeSlotDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get date; // LocalDate as String
  @override
  String get startTime; // LocalTime as String
  @override
  String get endTime;

  /// Create a copy of TimeSlotDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeSlotDtoImplCopyWith<_$TimeSlotDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
