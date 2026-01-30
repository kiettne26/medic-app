// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'doctor_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DoctorDto _$DoctorDtoFromJson(Map<String, dynamic> json) {
  return _DoctorDto.fromJson(json);
}

/// @nodoc
mixin _$DoctorDto {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get specialty => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  int? get totalReviews => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  double? get consultationFee => throw _privateConstructorUsedError;
  List<MedicalServiceDto>? get services => throw _privateConstructorUsedError;

  /// Serializes this DoctorDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DoctorDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DoctorDtoCopyWith<DoctorDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DoctorDtoCopyWith<$Res> {
  factory $DoctorDtoCopyWith(DoctorDto value, $Res Function(DoctorDto) then) =
      _$DoctorDtoCopyWithImpl<$Res, DoctorDto>;
  @useResult
  $Res call({
    String id,
    String userId,
    String fullName,
    String specialty,
    String? description,
    String? phone,
    String? avatarUrl,
    double? rating,
    int? totalReviews,
    bool isAvailable,
    double? consultationFee,
    List<MedicalServiceDto>? services,
  });
}

/// @nodoc
class _$DoctorDtoCopyWithImpl<$Res, $Val extends DoctorDto>
    implements $DoctorDtoCopyWith<$Res> {
  _$DoctorDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DoctorDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? fullName = null,
    Object? specialty = null,
    Object? description = freezed,
    Object? phone = freezed,
    Object? avatarUrl = freezed,
    Object? rating = freezed,
    Object? totalReviews = freezed,
    Object? isAvailable = null,
    Object? consultationFee = freezed,
    Object? services = freezed,
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
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            specialty: null == specialty
                ? _value.specialty
                : specialty // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            rating: freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double?,
            totalReviews: freezed == totalReviews
                ? _value.totalReviews
                : totalReviews // ignore: cast_nullable_to_non_nullable
                      as int?,
            isAvailable: null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
            consultationFee: freezed == consultationFee
                ? _value.consultationFee
                : consultationFee // ignore: cast_nullable_to_non_nullable
                      as double?,
            services: freezed == services
                ? _value.services
                : services // ignore: cast_nullable_to_non_nullable
                      as List<MedicalServiceDto>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DoctorDtoImplCopyWith<$Res>
    implements $DoctorDtoCopyWith<$Res> {
  factory _$$DoctorDtoImplCopyWith(
    _$DoctorDtoImpl value,
    $Res Function(_$DoctorDtoImpl) then,
  ) = __$$DoctorDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String fullName,
    String specialty,
    String? description,
    String? phone,
    String? avatarUrl,
    double? rating,
    int? totalReviews,
    bool isAvailable,
    double? consultationFee,
    List<MedicalServiceDto>? services,
  });
}

/// @nodoc
class __$$DoctorDtoImplCopyWithImpl<$Res>
    extends _$DoctorDtoCopyWithImpl<$Res, _$DoctorDtoImpl>
    implements _$$DoctorDtoImplCopyWith<$Res> {
  __$$DoctorDtoImplCopyWithImpl(
    _$DoctorDtoImpl _value,
    $Res Function(_$DoctorDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DoctorDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? fullName = null,
    Object? specialty = null,
    Object? description = freezed,
    Object? phone = freezed,
    Object? avatarUrl = freezed,
    Object? rating = freezed,
    Object? totalReviews = freezed,
    Object? isAvailable = null,
    Object? consultationFee = freezed,
    Object? services = freezed,
  }) {
    return _then(
      _$DoctorDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        specialty: null == specialty
            ? _value.specialty
            : specialty // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        rating: freezed == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double?,
        totalReviews: freezed == totalReviews
            ? _value.totalReviews
            : totalReviews // ignore: cast_nullable_to_non_nullable
                  as int?,
        isAvailable: null == isAvailable
            ? _value.isAvailable
            : isAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
        consultationFee: freezed == consultationFee
            ? _value.consultationFee
            : consultationFee // ignore: cast_nullable_to_non_nullable
                  as double?,
        services: freezed == services
            ? _value._services
            : services // ignore: cast_nullable_to_non_nullable
                  as List<MedicalServiceDto>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DoctorDtoImpl implements _DoctorDto {
  const _$DoctorDtoImpl({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.specialty,
    required this.description,
    required this.phone,
    required this.avatarUrl,
    required this.rating,
    required this.totalReviews,
    this.isAvailable = true,
    required this.consultationFee,
    required final List<MedicalServiceDto>? services,
  }) : _services = services;

  factory _$DoctorDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DoctorDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String fullName;
  @override
  final String specialty;
  @override
  final String? description;
  @override
  final String? phone;
  @override
  final String? avatarUrl;
  @override
  final double? rating;
  @override
  final int? totalReviews;
  @override
  @JsonKey()
  final bool isAvailable;
  @override
  final double? consultationFee;
  final List<MedicalServiceDto>? _services;
  @override
  List<MedicalServiceDto>? get services {
    final value = _services;
    if (value == null) return null;
    if (_services is EqualUnmodifiableListView) return _services;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'DoctorDto(id: $id, userId: $userId, fullName: $fullName, specialty: $specialty, description: $description, phone: $phone, avatarUrl: $avatarUrl, rating: $rating, totalReviews: $totalReviews, isAvailable: $isAvailable, consultationFee: $consultationFee, services: $services)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DoctorDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.specialty, specialty) ||
                other.specialty == specialty) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.consultationFee, consultationFee) ||
                other.consultationFee == consultationFee) &&
            const DeepCollectionEquality().equals(other._services, _services));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    fullName,
    specialty,
    description,
    phone,
    avatarUrl,
    rating,
    totalReviews,
    isAvailable,
    consultationFee,
    const DeepCollectionEquality().hash(_services),
  );

  /// Create a copy of DoctorDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DoctorDtoImplCopyWith<_$DoctorDtoImpl> get copyWith =>
      __$$DoctorDtoImplCopyWithImpl<_$DoctorDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DoctorDtoImplToJson(this);
  }
}

abstract class _DoctorDto implements DoctorDto {
  const factory _DoctorDto({
    required final String id,
    required final String userId,
    required final String fullName,
    required final String specialty,
    required final String? description,
    required final String? phone,
    required final String? avatarUrl,
    required final double? rating,
    required final int? totalReviews,
    final bool isAvailable,
    required final double? consultationFee,
    required final List<MedicalServiceDto>? services,
  }) = _$DoctorDtoImpl;

  factory _DoctorDto.fromJson(Map<String, dynamic> json) =
      _$DoctorDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get fullName;
  @override
  String get specialty;
  @override
  String? get description;
  @override
  String? get phone;
  @override
  String? get avatarUrl;
  @override
  double? get rating;
  @override
  int? get totalReviews;
  @override
  bool get isAvailable;
  @override
  double? get consultationFee;
  @override
  List<MedicalServiceDto>? get services;

  /// Create a copy of DoctorDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DoctorDtoImplCopyWith<_$DoctorDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
