// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medical_service_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MedicalServiceDto _$MedicalServiceDtoFromJson(Map<String, dynamic> json) {
  return _MedicalServiceDto.fromJson(json);
}

/// @nodoc
mixin _$MedicalServiceDto {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this MedicalServiceDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MedicalServiceDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MedicalServiceDtoCopyWith<MedicalServiceDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicalServiceDtoCopyWith<$Res> {
  factory $MedicalServiceDtoCopyWith(
    MedicalServiceDto value,
    $Res Function(MedicalServiceDto) then,
  ) = _$MedicalServiceDtoCopyWithImpl<$Res, MedicalServiceDto>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    double price,
    int durationMinutes,
    String category,
    bool isActive,
    String? imageUrl,
  });
}

/// @nodoc
class _$MedicalServiceDtoCopyWithImpl<$Res, $Val extends MedicalServiceDto>
    implements $MedicalServiceDtoCopyWith<$Res> {
  _$MedicalServiceDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MedicalServiceDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? price = null,
    Object? durationMinutes = null,
    Object? category = null,
    Object? isActive = null,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MedicalServiceDtoImplCopyWith<$Res>
    implements $MedicalServiceDtoCopyWith<$Res> {
  factory _$$MedicalServiceDtoImplCopyWith(
    _$MedicalServiceDtoImpl value,
    $Res Function(_$MedicalServiceDtoImpl) then,
  ) = __$$MedicalServiceDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    double price,
    int durationMinutes,
    String category,
    bool isActive,
    String? imageUrl,
  });
}

/// @nodoc
class __$$MedicalServiceDtoImplCopyWithImpl<$Res>
    extends _$MedicalServiceDtoCopyWithImpl<$Res, _$MedicalServiceDtoImpl>
    implements _$$MedicalServiceDtoImplCopyWith<$Res> {
  __$$MedicalServiceDtoImplCopyWithImpl(
    _$MedicalServiceDtoImpl _value,
    $Res Function(_$MedicalServiceDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MedicalServiceDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? price = null,
    Object? durationMinutes = null,
    Object? category = null,
    Object? isActive = null,
    Object? imageUrl = freezed,
  }) {
    return _then(
      _$MedicalServiceDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicalServiceDtoImpl implements _MedicalServiceDto {
  const _$MedicalServiceDtoImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.category,
    this.isActive = true,
    required this.imageUrl,
  });

  factory _$MedicalServiceDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicalServiceDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final double price;
  @override
  final int durationMinutes;
  @override
  final String category;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'MedicalServiceDto(id: $id, name: $name, description: $description, price: $price, durationMinutes: $durationMinutes, category: $category, isActive: $isActive, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicalServiceDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    price,
    durationMinutes,
    category,
    isActive,
    imageUrl,
  );

  /// Create a copy of MedicalServiceDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicalServiceDtoImplCopyWith<_$MedicalServiceDtoImpl> get copyWith =>
      __$$MedicalServiceDtoImplCopyWithImpl<_$MedicalServiceDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicalServiceDtoImplToJson(this);
  }
}

abstract class _MedicalServiceDto implements MedicalServiceDto {
  const factory _MedicalServiceDto({
    required final String id,
    required final String name,
    required final String? description,
    required final double price,
    required final int durationMinutes,
    required final String category,
    final bool isActive,
    required final String? imageUrl,
  }) = _$MedicalServiceDtoImpl;

  factory _MedicalServiceDto.fromJson(Map<String, dynamic> json) =
      _$MedicalServiceDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  double get price;
  @override
  int get durationMinutes;
  @override
  String get category;
  @override
  bool get isActive;
  @override
  String? get imageUrl;

  /// Create a copy of MedicalServiceDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MedicalServiceDtoImplCopyWith<_$MedicalServiceDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
