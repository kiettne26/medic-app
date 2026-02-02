// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PatientDto _$PatientDtoFromJson(Map<String, dynamic> json) {
  return _PatientDto.fromJson(json);
}

/// @nodoc
mixin _$PatientDto {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get fullName => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get dob => throw _privateConstructorUsedError;

  /// Serializes this PatientDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PatientDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PatientDtoCopyWith<PatientDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientDtoCopyWith<$Res> {
  factory $PatientDtoCopyWith(
    PatientDto value,
    $Res Function(PatientDto) then,
  ) = _$PatientDtoCopyWithImpl<$Res, PatientDto>;
  @useResult
  $Res call({
    String id,
    String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? address,
    String? gender,
    String? dob,
  });
}

/// @nodoc
class _$PatientDtoCopyWithImpl<$Res, $Val extends PatientDto>
    implements $PatientDtoCopyWith<$Res> {
  _$PatientDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PatientDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? fullName = freezed,
    Object? phone = freezed,
    Object? avatarUrl = freezed,
    Object? address = freezed,
    Object? gender = freezed,
    Object? dob = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: freezed == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String?,
            dob: freezed == dob
                ? _value.dob
                : dob // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PatientDtoImplCopyWith<$Res>
    implements $PatientDtoCopyWith<$Res> {
  factory _$$PatientDtoImplCopyWith(
    _$PatientDtoImpl value,
    $Res Function(_$PatientDtoImpl) then,
  ) = __$$PatientDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? address,
    String? gender,
    String? dob,
  });
}

/// @nodoc
class __$$PatientDtoImplCopyWithImpl<$Res>
    extends _$PatientDtoCopyWithImpl<$Res, _$PatientDtoImpl>
    implements _$$PatientDtoImplCopyWith<$Res> {
  __$$PatientDtoImplCopyWithImpl(
    _$PatientDtoImpl _value,
    $Res Function(_$PatientDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PatientDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? fullName = freezed,
    Object? phone = freezed,
    Object? avatarUrl = freezed,
    Object? address = freezed,
    Object? gender = freezed,
    Object? dob = freezed,
  }) {
    return _then(
      _$PatientDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: freezed == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String?,
        dob: freezed == dob
            ? _value.dob
            : dob // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PatientDtoImpl implements _PatientDto {
  const _$PatientDtoImpl({
    required this.id,
    required this.userId,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.address,
    this.gender,
    this.dob,
  });

  factory _$PatientDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? fullName;
  @override
  final String? phone;
  @override
  final String? avatarUrl;
  @override
  final String? address;
  @override
  final String? gender;
  @override
  final String? dob;

  @override
  String toString() {
    return 'PatientDto(id: $id, userId: $userId, fullName: $fullName, phone: $phone, avatarUrl: $avatarUrl, address: $address, gender: $gender, dob: $dob)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.dob, dob) || other.dob == dob));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    fullName,
    phone,
    avatarUrl,
    address,
    gender,
    dob,
  );

  /// Create a copy of PatientDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientDtoImplCopyWith<_$PatientDtoImpl> get copyWith =>
      __$$PatientDtoImplCopyWithImpl<_$PatientDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientDtoImplToJson(this);
  }
}

abstract class _PatientDto implements PatientDto {
  const factory _PatientDto({
    required final String id,
    required final String userId,
    final String? fullName,
    final String? phone,
    final String? avatarUrl,
    final String? address,
    final String? gender,
    final String? dob,
  }) = _$PatientDtoImpl;

  factory _PatientDto.fromJson(Map<String, dynamic> json) =
      _$PatientDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String? get fullName;
  @override
  String? get phone;
  @override
  String? get avatarUrl;
  @override
  String? get address;
  @override
  String? get gender;
  @override
  String? get dob;

  /// Create a copy of PatientDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PatientDtoImplCopyWith<_$PatientDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
