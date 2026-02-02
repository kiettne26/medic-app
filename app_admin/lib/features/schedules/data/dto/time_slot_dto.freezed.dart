// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_slot_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TimeSlotDto _$TimeSlotDtoFromJson(Map<String, dynamic> json) {
  return _TimeSlotDto.fromJson(json);
}

/// @nodoc
mixin _$TimeSlotDto {
  String get id => throw _privateConstructorUsedError;
  String get doctorId => throw _privateConstructorUsedError;
  String? get doctorName => throw _privateConstructorUsedError;
  String? get doctorAvatar => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  String get endTime => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

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
  $Res call({
    String id,
    String doctorId,
    String? doctorName,
    String? doctorAvatar,
    String date,
    String startTime,
    String endTime,
    bool isAvailable,
    String status,
  });
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
    Object? doctorId = null,
    Object? doctorName = freezed,
    Object? doctorAvatar = freezed,
    Object? date = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? isAvailable = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            doctorId: null == doctorId
                ? _value.doctorId
                : doctorId // ignore: cast_nullable_to_non_nullable
                      as String,
            doctorName: freezed == doctorName
                ? _value.doctorName
                : doctorName // ignore: cast_nullable_to_non_nullable
                      as String?,
            doctorAvatar: freezed == doctorAvatar
                ? _value.doctorAvatar
                : doctorAvatar // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            isAvailable: null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
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
  $Res call({
    String id,
    String doctorId,
    String? doctorName,
    String? doctorAvatar,
    String date,
    String startTime,
    String endTime,
    bool isAvailable,
    String status,
  });
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
    Object? doctorId = null,
    Object? doctorName = freezed,
    Object? doctorAvatar = freezed,
    Object? date = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? isAvailable = null,
    Object? status = null,
  }) {
    return _then(
      _$TimeSlotDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        doctorId: null == doctorId
            ? _value.doctorId
            : doctorId // ignore: cast_nullable_to_non_nullable
                  as String,
        doctorName: freezed == doctorName
            ? _value.doctorName
            : doctorName // ignore: cast_nullable_to_non_nullable
                  as String?,
        doctorAvatar: freezed == doctorAvatar
            ? _value.doctorAvatar
            : doctorAvatar // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        isAvailable: null == isAvailable
            ? _value.isAvailable
            : isAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
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
    required this.doctorId,
    this.doctorName,
    this.doctorAvatar,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.status = 'PENDING',
  });

  factory _$TimeSlotDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeSlotDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String doctorId;
  @override
  final String? doctorName;
  @override
  final String? doctorAvatar;
  @override
  final String date;
  @override
  final String startTime;
  @override
  final String endTime;
  @override
  @JsonKey()
  final bool isAvailable;
  @override
  @JsonKey()
  final String status;

  @override
  String toString() {
    return 'TimeSlotDto(id: $id, doctorId: $doctorId, doctorName: $doctorName, doctorAvatar: $doctorAvatar, date: $date, startTime: $startTime, endTime: $endTime, isAvailable: $isAvailable, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeSlotDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.doctorName, doctorName) ||
                other.doctorName == doctorName) &&
            (identical(other.doctorAvatar, doctorAvatar) ||
                other.doctorAvatar == doctorAvatar) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    doctorId,
    doctorName,
    doctorAvatar,
    date,
    startTime,
    endTime,
    isAvailable,
    status,
  );

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
    required final String doctorId,
    final String? doctorName,
    final String? doctorAvatar,
    required final String date,
    required final String startTime,
    required final String endTime,
    final bool isAvailable,
    final String status,
  }) = _$TimeSlotDtoImpl;

  factory _TimeSlotDto.fromJson(Map<String, dynamic> json) =
      _$TimeSlotDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get doctorId;
  @override
  String? get doctorName;
  @override
  String? get doctorAvatar;
  @override
  String get date;
  @override
  String get startTime;
  @override
  String get endTime;
  @override
  bool get isAvailable;
  @override
  String get status;

  /// Create a copy of TimeSlotDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeSlotDtoImplCopyWith<_$TimeSlotDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
