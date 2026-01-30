// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DashboardDto _$DashboardDtoFromJson(Map<String, dynamic> json) {
  return _DashboardDto.fromJson(json);
}

/// @nodoc
mixin _$DashboardDto {
  int get totalBookings => throw _privateConstructorUsedError;
  int get totalDoctors => throw _privateConstructorUsedError;
  int get totalPatients => throw _privateConstructorUsedError;
  int get todayBookings => throw _privateConstructorUsedError;
  int get pendingBookings => throw _privateConstructorUsedError;
  int get confirmedBookings => throw _privateConstructorUsedError;
  int get completedBookings => throw _privateConstructorUsedError;
  int get cancelledBookings => throw _privateConstructorUsedError;
  List<TimeSeriesData> get bookingsByDay => throw _privateConstructorUsedError;
  List<TimeSeriesData> get bookingsByWeek => throw _privateConstructorUsedError;
  List<TimeSeriesData> get bookingsByMonth =>
      throw _privateConstructorUsedError;
  List<DoctorStats> get topDoctors => throw _privateConstructorUsedError;
  List<ServiceStats> get popularServices => throw _privateConstructorUsedError;

  /// Serializes this DashboardDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardDtoCopyWith<DashboardDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardDtoCopyWith<$Res> {
  factory $DashboardDtoCopyWith(
    DashboardDto value,
    $Res Function(DashboardDto) then,
  ) = _$DashboardDtoCopyWithImpl<$Res, DashboardDto>;
  @useResult
  $Res call({
    int totalBookings,
    int totalDoctors,
    int totalPatients,
    int todayBookings,
    int pendingBookings,
    int confirmedBookings,
    int completedBookings,
    int cancelledBookings,
    List<TimeSeriesData> bookingsByDay,
    List<TimeSeriesData> bookingsByWeek,
    List<TimeSeriesData> bookingsByMonth,
    List<DoctorStats> topDoctors,
    List<ServiceStats> popularServices,
  });
}

/// @nodoc
class _$DashboardDtoCopyWithImpl<$Res, $Val extends DashboardDto>
    implements $DashboardDtoCopyWith<$Res> {
  _$DashboardDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalBookings = null,
    Object? totalDoctors = null,
    Object? totalPatients = null,
    Object? todayBookings = null,
    Object? pendingBookings = null,
    Object? confirmedBookings = null,
    Object? completedBookings = null,
    Object? cancelledBookings = null,
    Object? bookingsByDay = null,
    Object? bookingsByWeek = null,
    Object? bookingsByMonth = null,
    Object? topDoctors = null,
    Object? popularServices = null,
  }) {
    return _then(
      _value.copyWith(
            totalBookings: null == totalBookings
                ? _value.totalBookings
                : totalBookings // ignore: cast_nullable_to_non_nullable
                      as int,
            totalDoctors: null == totalDoctors
                ? _value.totalDoctors
                : totalDoctors // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPatients: null == totalPatients
                ? _value.totalPatients
                : totalPatients // ignore: cast_nullable_to_non_nullable
                      as int,
            todayBookings: null == todayBookings
                ? _value.todayBookings
                : todayBookings // ignore: cast_nullable_to_non_nullable
                      as int,
            pendingBookings: null == pendingBookings
                ? _value.pendingBookings
                : pendingBookings // ignore: cast_nullable_to_non_nullable
                      as int,
            confirmedBookings: null == confirmedBookings
                ? _value.confirmedBookings
                : confirmedBookings // ignore: cast_nullable_to_non_nullable
                      as int,
            completedBookings: null == completedBookings
                ? _value.completedBookings
                : completedBookings // ignore: cast_nullable_to_non_nullable
                      as int,
            cancelledBookings: null == cancelledBookings
                ? _value.cancelledBookings
                : cancelledBookings // ignore: cast_nullable_to_non_nullable
                      as int,
            bookingsByDay: null == bookingsByDay
                ? _value.bookingsByDay
                : bookingsByDay // ignore: cast_nullable_to_non_nullable
                      as List<TimeSeriesData>,
            bookingsByWeek: null == bookingsByWeek
                ? _value.bookingsByWeek
                : bookingsByWeek // ignore: cast_nullable_to_non_nullable
                      as List<TimeSeriesData>,
            bookingsByMonth: null == bookingsByMonth
                ? _value.bookingsByMonth
                : bookingsByMonth // ignore: cast_nullable_to_non_nullable
                      as List<TimeSeriesData>,
            topDoctors: null == topDoctors
                ? _value.topDoctors
                : topDoctors // ignore: cast_nullable_to_non_nullable
                      as List<DoctorStats>,
            popularServices: null == popularServices
                ? _value.popularServices
                : popularServices // ignore: cast_nullable_to_non_nullable
                      as List<ServiceStats>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DashboardDtoImplCopyWith<$Res>
    implements $DashboardDtoCopyWith<$Res> {
  factory _$$DashboardDtoImplCopyWith(
    _$DashboardDtoImpl value,
    $Res Function(_$DashboardDtoImpl) then,
  ) = __$$DashboardDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalBookings,
    int totalDoctors,
    int totalPatients,
    int todayBookings,
    int pendingBookings,
    int confirmedBookings,
    int completedBookings,
    int cancelledBookings,
    List<TimeSeriesData> bookingsByDay,
    List<TimeSeriesData> bookingsByWeek,
    List<TimeSeriesData> bookingsByMonth,
    List<DoctorStats> topDoctors,
    List<ServiceStats> popularServices,
  });
}

/// @nodoc
class __$$DashboardDtoImplCopyWithImpl<$Res>
    extends _$DashboardDtoCopyWithImpl<$Res, _$DashboardDtoImpl>
    implements _$$DashboardDtoImplCopyWith<$Res> {
  __$$DashboardDtoImplCopyWithImpl(
    _$DashboardDtoImpl _value,
    $Res Function(_$DashboardDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalBookings = null,
    Object? totalDoctors = null,
    Object? totalPatients = null,
    Object? todayBookings = null,
    Object? pendingBookings = null,
    Object? confirmedBookings = null,
    Object? completedBookings = null,
    Object? cancelledBookings = null,
    Object? bookingsByDay = null,
    Object? bookingsByWeek = null,
    Object? bookingsByMonth = null,
    Object? topDoctors = null,
    Object? popularServices = null,
  }) {
    return _then(
      _$DashboardDtoImpl(
        totalBookings: null == totalBookings
            ? _value.totalBookings
            : totalBookings // ignore: cast_nullable_to_non_nullable
                  as int,
        totalDoctors: null == totalDoctors
            ? _value.totalDoctors
            : totalDoctors // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPatients: null == totalPatients
            ? _value.totalPatients
            : totalPatients // ignore: cast_nullable_to_non_nullable
                  as int,
        todayBookings: null == todayBookings
            ? _value.todayBookings
            : todayBookings // ignore: cast_nullable_to_non_nullable
                  as int,
        pendingBookings: null == pendingBookings
            ? _value.pendingBookings
            : pendingBookings // ignore: cast_nullable_to_non_nullable
                  as int,
        confirmedBookings: null == confirmedBookings
            ? _value.confirmedBookings
            : confirmedBookings // ignore: cast_nullable_to_non_nullable
                  as int,
        completedBookings: null == completedBookings
            ? _value.completedBookings
            : completedBookings // ignore: cast_nullable_to_non_nullable
                  as int,
        cancelledBookings: null == cancelledBookings
            ? _value.cancelledBookings
            : cancelledBookings // ignore: cast_nullable_to_non_nullable
                  as int,
        bookingsByDay: null == bookingsByDay
            ? _value._bookingsByDay
            : bookingsByDay // ignore: cast_nullable_to_non_nullable
                  as List<TimeSeriesData>,
        bookingsByWeek: null == bookingsByWeek
            ? _value._bookingsByWeek
            : bookingsByWeek // ignore: cast_nullable_to_non_nullable
                  as List<TimeSeriesData>,
        bookingsByMonth: null == bookingsByMonth
            ? _value._bookingsByMonth
            : bookingsByMonth // ignore: cast_nullable_to_non_nullable
                  as List<TimeSeriesData>,
        topDoctors: null == topDoctors
            ? _value._topDoctors
            : topDoctors // ignore: cast_nullable_to_non_nullable
                  as List<DoctorStats>,
        popularServices: null == popularServices
            ? _value._popularServices
            : popularServices // ignore: cast_nullable_to_non_nullable
                  as List<ServiceStats>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardDtoImpl implements _DashboardDto {
  const _$DashboardDtoImpl({
    this.totalBookings = 0,
    this.totalDoctors = 0,
    this.totalPatients = 0,
    this.todayBookings = 0,
    this.pendingBookings = 0,
    this.confirmedBookings = 0,
    this.completedBookings = 0,
    this.cancelledBookings = 0,
    final List<TimeSeriesData> bookingsByDay = const [],
    final List<TimeSeriesData> bookingsByWeek = const [],
    final List<TimeSeriesData> bookingsByMonth = const [],
    final List<DoctorStats> topDoctors = const [],
    final List<ServiceStats> popularServices = const [],
  }) : _bookingsByDay = bookingsByDay,
       _bookingsByWeek = bookingsByWeek,
       _bookingsByMonth = bookingsByMonth,
       _topDoctors = topDoctors,
       _popularServices = popularServices;

  factory _$DashboardDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardDtoImplFromJson(json);

  @override
  @JsonKey()
  final int totalBookings;
  @override
  @JsonKey()
  final int totalDoctors;
  @override
  @JsonKey()
  final int totalPatients;
  @override
  @JsonKey()
  final int todayBookings;
  @override
  @JsonKey()
  final int pendingBookings;
  @override
  @JsonKey()
  final int confirmedBookings;
  @override
  @JsonKey()
  final int completedBookings;
  @override
  @JsonKey()
  final int cancelledBookings;
  final List<TimeSeriesData> _bookingsByDay;
  @override
  @JsonKey()
  List<TimeSeriesData> get bookingsByDay {
    if (_bookingsByDay is EqualUnmodifiableListView) return _bookingsByDay;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bookingsByDay);
  }

  final List<TimeSeriesData> _bookingsByWeek;
  @override
  @JsonKey()
  List<TimeSeriesData> get bookingsByWeek {
    if (_bookingsByWeek is EqualUnmodifiableListView) return _bookingsByWeek;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bookingsByWeek);
  }

  final List<TimeSeriesData> _bookingsByMonth;
  @override
  @JsonKey()
  List<TimeSeriesData> get bookingsByMonth {
    if (_bookingsByMonth is EqualUnmodifiableListView) return _bookingsByMonth;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bookingsByMonth);
  }

  final List<DoctorStats> _topDoctors;
  @override
  @JsonKey()
  List<DoctorStats> get topDoctors {
    if (_topDoctors is EqualUnmodifiableListView) return _topDoctors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topDoctors);
  }

  final List<ServiceStats> _popularServices;
  @override
  @JsonKey()
  List<ServiceStats> get popularServices {
    if (_popularServices is EqualUnmodifiableListView) return _popularServices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_popularServices);
  }

  @override
  String toString() {
    return 'DashboardDto(totalBookings: $totalBookings, totalDoctors: $totalDoctors, totalPatients: $totalPatients, todayBookings: $todayBookings, pendingBookings: $pendingBookings, confirmedBookings: $confirmedBookings, completedBookings: $completedBookings, cancelledBookings: $cancelledBookings, bookingsByDay: $bookingsByDay, bookingsByWeek: $bookingsByWeek, bookingsByMonth: $bookingsByMonth, topDoctors: $topDoctors, popularServices: $popularServices)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardDtoImpl &&
            (identical(other.totalBookings, totalBookings) ||
                other.totalBookings == totalBookings) &&
            (identical(other.totalDoctors, totalDoctors) ||
                other.totalDoctors == totalDoctors) &&
            (identical(other.totalPatients, totalPatients) ||
                other.totalPatients == totalPatients) &&
            (identical(other.todayBookings, todayBookings) ||
                other.todayBookings == todayBookings) &&
            (identical(other.pendingBookings, pendingBookings) ||
                other.pendingBookings == pendingBookings) &&
            (identical(other.confirmedBookings, confirmedBookings) ||
                other.confirmedBookings == confirmedBookings) &&
            (identical(other.completedBookings, completedBookings) ||
                other.completedBookings == completedBookings) &&
            (identical(other.cancelledBookings, cancelledBookings) ||
                other.cancelledBookings == cancelledBookings) &&
            const DeepCollectionEquality().equals(
              other._bookingsByDay,
              _bookingsByDay,
            ) &&
            const DeepCollectionEquality().equals(
              other._bookingsByWeek,
              _bookingsByWeek,
            ) &&
            const DeepCollectionEquality().equals(
              other._bookingsByMonth,
              _bookingsByMonth,
            ) &&
            const DeepCollectionEquality().equals(
              other._topDoctors,
              _topDoctors,
            ) &&
            const DeepCollectionEquality().equals(
              other._popularServices,
              _popularServices,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalBookings,
    totalDoctors,
    totalPatients,
    todayBookings,
    pendingBookings,
    confirmedBookings,
    completedBookings,
    cancelledBookings,
    const DeepCollectionEquality().hash(_bookingsByDay),
    const DeepCollectionEquality().hash(_bookingsByWeek),
    const DeepCollectionEquality().hash(_bookingsByMonth),
    const DeepCollectionEquality().hash(_topDoctors),
    const DeepCollectionEquality().hash(_popularServices),
  );

  /// Create a copy of DashboardDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardDtoImplCopyWith<_$DashboardDtoImpl> get copyWith =>
      __$$DashboardDtoImplCopyWithImpl<_$DashboardDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardDtoImplToJson(this);
  }
}

abstract class _DashboardDto implements DashboardDto {
  const factory _DashboardDto({
    final int totalBookings,
    final int totalDoctors,
    final int totalPatients,
    final int todayBookings,
    final int pendingBookings,
    final int confirmedBookings,
    final int completedBookings,
    final int cancelledBookings,
    final List<TimeSeriesData> bookingsByDay,
    final List<TimeSeriesData> bookingsByWeek,
    final List<TimeSeriesData> bookingsByMonth,
    final List<DoctorStats> topDoctors,
    final List<ServiceStats> popularServices,
  }) = _$DashboardDtoImpl;

  factory _DashboardDto.fromJson(Map<String, dynamic> json) =
      _$DashboardDtoImpl.fromJson;

  @override
  int get totalBookings;
  @override
  int get totalDoctors;
  @override
  int get totalPatients;
  @override
  int get todayBookings;
  @override
  int get pendingBookings;
  @override
  int get confirmedBookings;
  @override
  int get completedBookings;
  @override
  int get cancelledBookings;
  @override
  List<TimeSeriesData> get bookingsByDay;
  @override
  List<TimeSeriesData> get bookingsByWeek;
  @override
  List<TimeSeriesData> get bookingsByMonth;
  @override
  List<DoctorStats> get topDoctors;
  @override
  List<ServiceStats> get popularServices;

  /// Create a copy of DashboardDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardDtoImplCopyWith<_$DashboardDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimeSeriesData _$TimeSeriesDataFromJson(Map<String, dynamic> json) {
  return _TimeSeriesData.fromJson(json);
}

/// @nodoc
mixin _$TimeSeriesData {
  String get label => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Serializes this TimeSeriesData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeSeriesData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeSeriesDataCopyWith<TimeSeriesData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeSeriesDataCopyWith<$Res> {
  factory $TimeSeriesDataCopyWith(
    TimeSeriesData value,
    $Res Function(TimeSeriesData) then,
  ) = _$TimeSeriesDataCopyWithImpl<$Res, TimeSeriesData>;
  @useResult
  $Res call({String label, int count});
}

/// @nodoc
class _$TimeSeriesDataCopyWithImpl<$Res, $Val extends TimeSeriesData>
    implements $TimeSeriesDataCopyWith<$Res> {
  _$TimeSeriesDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeSeriesData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? label = null, Object? count = null}) {
    return _then(
      _value.copyWith(
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimeSeriesDataImplCopyWith<$Res>
    implements $TimeSeriesDataCopyWith<$Res> {
  factory _$$TimeSeriesDataImplCopyWith(
    _$TimeSeriesDataImpl value,
    $Res Function(_$TimeSeriesDataImpl) then,
  ) = __$$TimeSeriesDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, int count});
}

/// @nodoc
class __$$TimeSeriesDataImplCopyWithImpl<$Res>
    extends _$TimeSeriesDataCopyWithImpl<$Res, _$TimeSeriesDataImpl>
    implements _$$TimeSeriesDataImplCopyWith<$Res> {
  __$$TimeSeriesDataImplCopyWithImpl(
    _$TimeSeriesDataImpl _value,
    $Res Function(_$TimeSeriesDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimeSeriesData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? label = null, Object? count = null}) {
    return _then(
      _$TimeSeriesDataImpl(
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeSeriesDataImpl implements _TimeSeriesData {
  const _$TimeSeriesDataImpl({required this.label, required this.count});

  factory _$TimeSeriesDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeSeriesDataImplFromJson(json);

  @override
  final String label;
  @override
  final int count;

  @override
  String toString() {
    return 'TimeSeriesData(label: $label, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeSeriesDataImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label, count);

  /// Create a copy of TimeSeriesData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeSeriesDataImplCopyWith<_$TimeSeriesDataImpl> get copyWith =>
      __$$TimeSeriesDataImplCopyWithImpl<_$TimeSeriesDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeSeriesDataImplToJson(this);
  }
}

abstract class _TimeSeriesData implements TimeSeriesData {
  const factory _TimeSeriesData({
    required final String label,
    required final int count,
  }) = _$TimeSeriesDataImpl;

  factory _TimeSeriesData.fromJson(Map<String, dynamic> json) =
      _$TimeSeriesDataImpl.fromJson;

  @override
  String get label;
  @override
  int get count;

  /// Create a copy of TimeSeriesData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeSeriesDataImplCopyWith<_$TimeSeriesDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DoctorStats _$DoctorStatsFromJson(Map<String, dynamic> json) {
  return _DoctorStats.fromJson(json);
}

/// @nodoc
mixin _$DoctorStats {
  String get doctorId => throw _privateConstructorUsedError;
  String get doctorName => throw _privateConstructorUsedError;
  String get specialty => throw _privateConstructorUsedError;
  int get totalBookings => throw _privateConstructorUsedError;
  int get completedBookings => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;

  /// Serializes this DoctorStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DoctorStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DoctorStatsCopyWith<DoctorStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DoctorStatsCopyWith<$Res> {
  factory $DoctorStatsCopyWith(
    DoctorStats value,
    $Res Function(DoctorStats) then,
  ) = _$DoctorStatsCopyWithImpl<$Res, DoctorStats>;
  @useResult
  $Res call({
    String doctorId,
    String doctorName,
    String specialty,
    int totalBookings,
    int completedBookings,
    double rating,
  });
}

/// @nodoc
class _$DoctorStatsCopyWithImpl<$Res, $Val extends DoctorStats>
    implements $DoctorStatsCopyWith<$Res> {
  _$DoctorStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DoctorStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? doctorId = null,
    Object? doctorName = null,
    Object? specialty = null,
    Object? totalBookings = null,
    Object? completedBookings = null,
    Object? rating = null,
  }) {
    return _then(
      _value.copyWith(
            doctorId: null == doctorId
                ? _value.doctorId
                : doctorId // ignore: cast_nullable_to_non_nullable
                      as String,
            doctorName: null == doctorName
                ? _value.doctorName
                : doctorName // ignore: cast_nullable_to_non_nullable
                      as String,
            specialty: null == specialty
                ? _value.specialty
                : specialty // ignore: cast_nullable_to_non_nullable
                      as String,
            totalBookings: null == totalBookings
                ? _value.totalBookings
                : totalBookings // ignore: cast_nullable_to_non_nullable
                      as int,
            completedBookings: null == completedBookings
                ? _value.completedBookings
                : completedBookings // ignore: cast_nullable_to_non_nullable
                      as int,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DoctorStatsImplCopyWith<$Res>
    implements $DoctorStatsCopyWith<$Res> {
  factory _$$DoctorStatsImplCopyWith(
    _$DoctorStatsImpl value,
    $Res Function(_$DoctorStatsImpl) then,
  ) = __$$DoctorStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String doctorId,
    String doctorName,
    String specialty,
    int totalBookings,
    int completedBookings,
    double rating,
  });
}

/// @nodoc
class __$$DoctorStatsImplCopyWithImpl<$Res>
    extends _$DoctorStatsCopyWithImpl<$Res, _$DoctorStatsImpl>
    implements _$$DoctorStatsImplCopyWith<$Res> {
  __$$DoctorStatsImplCopyWithImpl(
    _$DoctorStatsImpl _value,
    $Res Function(_$DoctorStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DoctorStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? doctorId = null,
    Object? doctorName = null,
    Object? specialty = null,
    Object? totalBookings = null,
    Object? completedBookings = null,
    Object? rating = null,
  }) {
    return _then(
      _$DoctorStatsImpl(
        doctorId: null == doctorId
            ? _value.doctorId
            : doctorId // ignore: cast_nullable_to_non_nullable
                  as String,
        doctorName: null == doctorName
            ? _value.doctorName
            : doctorName // ignore: cast_nullable_to_non_nullable
                  as String,
        specialty: null == specialty
            ? _value.specialty
            : specialty // ignore: cast_nullable_to_non_nullable
                  as String,
        totalBookings: null == totalBookings
            ? _value.totalBookings
            : totalBookings // ignore: cast_nullable_to_non_nullable
                  as int,
        completedBookings: null == completedBookings
            ? _value.completedBookings
            : completedBookings // ignore: cast_nullable_to_non_nullable
                  as int,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DoctorStatsImpl implements _DoctorStats {
  const _$DoctorStatsImpl({
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.totalBookings,
    required this.completedBookings,
    required this.rating,
  });

  factory _$DoctorStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DoctorStatsImplFromJson(json);

  @override
  final String doctorId;
  @override
  final String doctorName;
  @override
  final String specialty;
  @override
  final int totalBookings;
  @override
  final int completedBookings;
  @override
  final double rating;

  @override
  String toString() {
    return 'DoctorStats(doctorId: $doctorId, doctorName: $doctorName, specialty: $specialty, totalBookings: $totalBookings, completedBookings: $completedBookings, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DoctorStatsImpl &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.doctorName, doctorName) ||
                other.doctorName == doctorName) &&
            (identical(other.specialty, specialty) ||
                other.specialty == specialty) &&
            (identical(other.totalBookings, totalBookings) ||
                other.totalBookings == totalBookings) &&
            (identical(other.completedBookings, completedBookings) ||
                other.completedBookings == completedBookings) &&
            (identical(other.rating, rating) || other.rating == rating));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    doctorId,
    doctorName,
    specialty,
    totalBookings,
    completedBookings,
    rating,
  );

  /// Create a copy of DoctorStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DoctorStatsImplCopyWith<_$DoctorStatsImpl> get copyWith =>
      __$$DoctorStatsImplCopyWithImpl<_$DoctorStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DoctorStatsImplToJson(this);
  }
}

abstract class _DoctorStats implements DoctorStats {
  const factory _DoctorStats({
    required final String doctorId,
    required final String doctorName,
    required final String specialty,
    required final int totalBookings,
    required final int completedBookings,
    required final double rating,
  }) = _$DoctorStatsImpl;

  factory _DoctorStats.fromJson(Map<String, dynamic> json) =
      _$DoctorStatsImpl.fromJson;

  @override
  String get doctorId;
  @override
  String get doctorName;
  @override
  String get specialty;
  @override
  int get totalBookings;
  @override
  int get completedBookings;
  @override
  double get rating;

  /// Create a copy of DoctorStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DoctorStatsImplCopyWith<_$DoctorStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ServiceStats _$ServiceStatsFromJson(Map<String, dynamic> json) {
  return _ServiceStats.fromJson(json);
}

/// @nodoc
mixin _$ServiceStats {
  String get serviceId => throw _privateConstructorUsedError;
  String get serviceName => throw _privateConstructorUsedError;
  int get bookingCount => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;

  /// Serializes this ServiceStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceStatsCopyWith<ServiceStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceStatsCopyWith<$Res> {
  factory $ServiceStatsCopyWith(
    ServiceStats value,
    $Res Function(ServiceStats) then,
  ) = _$ServiceStatsCopyWithImpl<$Res, ServiceStats>;
  @useResult
  $Res call({
    String serviceId,
    String serviceName,
    int bookingCount,
    double percentage,
  });
}

/// @nodoc
class _$ServiceStatsCopyWithImpl<$Res, $Val extends ServiceStats>
    implements $ServiceStatsCopyWith<$Res> {
  _$ServiceStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceId = null,
    Object? serviceName = null,
    Object? bookingCount = null,
    Object? percentage = null,
  }) {
    return _then(
      _value.copyWith(
            serviceId: null == serviceId
                ? _value.serviceId
                : serviceId // ignore: cast_nullable_to_non_nullable
                      as String,
            serviceName: null == serviceName
                ? _value.serviceName
                : serviceName // ignore: cast_nullable_to_non_nullable
                      as String,
            bookingCount: null == bookingCount
                ? _value.bookingCount
                : bookingCount // ignore: cast_nullable_to_non_nullable
                      as int,
            percentage: null == percentage
                ? _value.percentage
                : percentage // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ServiceStatsImplCopyWith<$Res>
    implements $ServiceStatsCopyWith<$Res> {
  factory _$$ServiceStatsImplCopyWith(
    _$ServiceStatsImpl value,
    $Res Function(_$ServiceStatsImpl) then,
  ) = __$$ServiceStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String serviceId,
    String serviceName,
    int bookingCount,
    double percentage,
  });
}

/// @nodoc
class __$$ServiceStatsImplCopyWithImpl<$Res>
    extends _$ServiceStatsCopyWithImpl<$Res, _$ServiceStatsImpl>
    implements _$$ServiceStatsImplCopyWith<$Res> {
  __$$ServiceStatsImplCopyWithImpl(
    _$ServiceStatsImpl _value,
    $Res Function(_$ServiceStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServiceStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceId = null,
    Object? serviceName = null,
    Object? bookingCount = null,
    Object? percentage = null,
  }) {
    return _then(
      _$ServiceStatsImpl(
        serviceId: null == serviceId
            ? _value.serviceId
            : serviceId // ignore: cast_nullable_to_non_nullable
                  as String,
        serviceName: null == serviceName
            ? _value.serviceName
            : serviceName // ignore: cast_nullable_to_non_nullable
                  as String,
        bookingCount: null == bookingCount
            ? _value.bookingCount
            : bookingCount // ignore: cast_nullable_to_non_nullable
                  as int,
        percentage: null == percentage
            ? _value.percentage
            : percentage // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ServiceStatsImpl implements _ServiceStats {
  const _$ServiceStatsImpl({
    required this.serviceId,
    required this.serviceName,
    required this.bookingCount,
    required this.percentage,
  });

  factory _$ServiceStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceStatsImplFromJson(json);

  @override
  final String serviceId;
  @override
  final String serviceName;
  @override
  final int bookingCount;
  @override
  final double percentage;

  @override
  String toString() {
    return 'ServiceStats(serviceId: $serviceId, serviceName: $serviceName, bookingCount: $bookingCount, percentage: $percentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceStatsImpl &&
            (identical(other.serviceId, serviceId) ||
                other.serviceId == serviceId) &&
            (identical(other.serviceName, serviceName) ||
                other.serviceName == serviceName) &&
            (identical(other.bookingCount, bookingCount) ||
                other.bookingCount == bookingCount) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    serviceId,
    serviceName,
    bookingCount,
    percentage,
  );

  /// Create a copy of ServiceStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceStatsImplCopyWith<_$ServiceStatsImpl> get copyWith =>
      __$$ServiceStatsImplCopyWithImpl<_$ServiceStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceStatsImplToJson(this);
  }
}

abstract class _ServiceStats implements ServiceStats {
  const factory _ServiceStats({
    required final String serviceId,
    required final String serviceName,
    required final int bookingCount,
    required final double percentage,
  }) = _$ServiceStatsImpl;

  factory _ServiceStats.fromJson(Map<String, dynamic> json) =
      _$ServiceStatsImpl.fromJson;

  @override
  String get serviceId;
  @override
  String get serviceName;
  @override
  int get bookingCount;
  @override
  double get percentage;

  /// Create a copy of ServiceStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceStatsImplCopyWith<_$ServiceStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
