// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_out_exception.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckOutException {
  String get employeeId;
  String get exceptionReason;
  String get remarks;
  double get latitude;
  double get longitude;
  String get officeLocation;
  double get officeLatitude;
  double get officeLongitude;
  double get distanceInMeters;
  DateTime get attemptedAt;

  /// Create a copy of CheckOutException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CheckOutExceptionCopyWith<CheckOutException> get copyWith =>
      _$CheckOutExceptionCopyWithImpl<CheckOutException>(
        this as CheckOutException,
        _$identity,
      );

  /// Serializes this CheckOutException to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CheckOutException &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.exceptionReason, exceptionReason) ||
                other.exceptionReason == exceptionReason) &&
            (identical(other.remarks, remarks) || other.remarks == remarks) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.officeLocation, officeLocation) ||
                other.officeLocation == officeLocation) &&
            (identical(other.officeLatitude, officeLatitude) ||
                other.officeLatitude == officeLatitude) &&
            (identical(other.officeLongitude, officeLongitude) ||
                other.officeLongitude == officeLongitude) &&
            (identical(other.distanceInMeters, distanceInMeters) ||
                other.distanceInMeters == distanceInMeters) &&
            (identical(other.attemptedAt, attemptedAt) ||
                other.attemptedAt == attemptedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    employeeId,
    exceptionReason,
    remarks,
    latitude,
    longitude,
    officeLocation,
    officeLatitude,
    officeLongitude,
    distanceInMeters,
    attemptedAt,
  );

  @override
  String toString() {
    return 'CheckOutException(employeeId: $employeeId, exceptionReason: $exceptionReason, remarks: $remarks, latitude: $latitude, longitude: $longitude, officeLocation: $officeLocation, officeLatitude: $officeLatitude, officeLongitude: $officeLongitude, distanceInMeters: $distanceInMeters, attemptedAt: $attemptedAt)';
  }
}

/// @nodoc
abstract mixin class $CheckOutExceptionCopyWith<$Res> {
  factory $CheckOutExceptionCopyWith(
    CheckOutException value,
    $Res Function(CheckOutException) _then,
  ) = _$CheckOutExceptionCopyWithImpl;
  @useResult
  $Res call({
    String employeeId,
    String exceptionReason,
    String remarks,
    double latitude,
    double longitude,
    String officeLocation,
    double officeLatitude,
    double officeLongitude,
    double distanceInMeters,
    DateTime attemptedAt,
  });
}

/// @nodoc
class _$CheckOutExceptionCopyWithImpl<$Res>
    implements $CheckOutExceptionCopyWith<$Res> {
  _$CheckOutExceptionCopyWithImpl(this._self, this._then);

  final CheckOutException _self;
  final $Res Function(CheckOutException) _then;

  /// Create a copy of CheckOutException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? employeeId = null,
    Object? exceptionReason = null,
    Object? remarks = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? officeLocation = null,
    Object? officeLatitude = null,
    Object? officeLongitude = null,
    Object? distanceInMeters = null,
    Object? attemptedAt = null,
  }) {
    return _then(
      _self.copyWith(
        employeeId: null == employeeId
            ? _self.employeeId
            : employeeId // ignore: cast_nullable_to_non_nullable
                  as String,
        exceptionReason: null == exceptionReason
            ? _self.exceptionReason
            : exceptionReason // ignore: cast_nullable_to_non_nullable
                  as String,
        remarks: null == remarks
            ? _self.remarks
            : remarks // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _self.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _self.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        officeLocation: null == officeLocation
            ? _self.officeLocation
            : officeLocation // ignore: cast_nullable_to_non_nullable
                  as String,
        officeLatitude: null == officeLatitude
            ? _self.officeLatitude
            : officeLatitude // ignore: cast_nullable_to_non_nullable
                  as double,
        officeLongitude: null == officeLongitude
            ? _self.officeLongitude
            : officeLongitude // ignore: cast_nullable_to_non_nullable
                  as double,
        distanceInMeters: null == distanceInMeters
            ? _self.distanceInMeters
            : distanceInMeters // ignore: cast_nullable_to_non_nullable
                  as double,
        attemptedAt: null == attemptedAt
            ? _self.attemptedAt
            : attemptedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [CheckOutException].
extension CheckOutExceptionPatterns on CheckOutException {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_CheckOutException value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckOutException() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_CheckOutException value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckOutException():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_CheckOutException value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckOutException() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      String employeeId,
      String exceptionReason,
      String remarks,
      double latitude,
      double longitude,
      String officeLocation,
      double officeLatitude,
      double officeLongitude,
      double distanceInMeters,
      DateTime attemptedAt,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckOutException() when $default != null:
        return $default(
          _that.employeeId,
          _that.exceptionReason,
          _that.remarks,
          _that.latitude,
          _that.longitude,
          _that.officeLocation,
          _that.officeLatitude,
          _that.officeLongitude,
          _that.distanceInMeters,
          _that.attemptedAt,
        );
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      String employeeId,
      String exceptionReason,
      String remarks,
      double latitude,
      double longitude,
      String officeLocation,
      double officeLatitude,
      double officeLongitude,
      double distanceInMeters,
      DateTime attemptedAt,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckOutException():
        return $default(
          _that.employeeId,
          _that.exceptionReason,
          _that.remarks,
          _that.latitude,
          _that.longitude,
          _that.officeLocation,
          _that.officeLatitude,
          _that.officeLongitude,
          _that.distanceInMeters,
          _that.attemptedAt,
        );
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      String employeeId,
      String exceptionReason,
      String remarks,
      double latitude,
      double longitude,
      String officeLocation,
      double officeLatitude,
      double officeLongitude,
      double distanceInMeters,
      DateTime attemptedAt,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckOutException() when $default != null:
        return $default(
          _that.employeeId,
          _that.exceptionReason,
          _that.remarks,
          _that.latitude,
          _that.longitude,
          _that.officeLocation,
          _that.officeLatitude,
          _that.officeLongitude,
          _that.distanceInMeters,
          _that.attemptedAt,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CheckOutException implements CheckOutException {
  const _CheckOutException({
    required this.employeeId,
    required this.exceptionReason,
    required this.remarks,
    required this.latitude,
    required this.longitude,
    required this.officeLocation,
    required this.officeLatitude,
    required this.officeLongitude,
    required this.distanceInMeters,
    required this.attemptedAt,
  });
  factory _CheckOutException.fromJson(Map<String, dynamic> json) =>
      _$CheckOutExceptionFromJson(json);

  @override
  final String employeeId;
  @override
  final String exceptionReason;
  @override
  final String remarks;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String officeLocation;
  @override
  final double officeLatitude;
  @override
  final double officeLongitude;
  @override
  final double distanceInMeters;
  @override
  final DateTime attemptedAt;

  /// Create a copy of CheckOutException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CheckOutExceptionCopyWith<_CheckOutException> get copyWith =>
      __$CheckOutExceptionCopyWithImpl<_CheckOutException>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CheckOutExceptionToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CheckOutException &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.exceptionReason, exceptionReason) ||
                other.exceptionReason == exceptionReason) &&
            (identical(other.remarks, remarks) || other.remarks == remarks) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.officeLocation, officeLocation) ||
                other.officeLocation == officeLocation) &&
            (identical(other.officeLatitude, officeLatitude) ||
                other.officeLatitude == officeLatitude) &&
            (identical(other.officeLongitude, officeLongitude) ||
                other.officeLongitude == officeLongitude) &&
            (identical(other.distanceInMeters, distanceInMeters) ||
                other.distanceInMeters == distanceInMeters) &&
            (identical(other.attemptedAt, attemptedAt) ||
                other.attemptedAt == attemptedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    employeeId,
    exceptionReason,
    remarks,
    latitude,
    longitude,
    officeLocation,
    officeLatitude,
    officeLongitude,
    distanceInMeters,
    attemptedAt,
  );

  @override
  String toString() {
    return 'CheckOutException(employeeId: $employeeId, exceptionReason: $exceptionReason, remarks: $remarks, latitude: $latitude, longitude: $longitude, officeLocation: $officeLocation, officeLatitude: $officeLatitude, officeLongitude: $officeLongitude, distanceInMeters: $distanceInMeters, attemptedAt: $attemptedAt)';
  }
}

/// @nodoc
abstract mixin class _$CheckOutExceptionCopyWith<$Res>
    implements $CheckOutExceptionCopyWith<$Res> {
  factory _$CheckOutExceptionCopyWith(
    _CheckOutException value,
    $Res Function(_CheckOutException) _then,
  ) = __$CheckOutExceptionCopyWithImpl;
  @override
  @useResult
  $Res call({
    String employeeId,
    String exceptionReason,
    String remarks,
    double latitude,
    double longitude,
    String officeLocation,
    double officeLatitude,
    double officeLongitude,
    double distanceInMeters,
    DateTime attemptedAt,
  });
}

/// @nodoc
class __$CheckOutExceptionCopyWithImpl<$Res>
    implements _$CheckOutExceptionCopyWith<$Res> {
  __$CheckOutExceptionCopyWithImpl(this._self, this._then);

  final _CheckOutException _self;
  final $Res Function(_CheckOutException) _then;

  /// Create a copy of CheckOutException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? employeeId = null,
    Object? exceptionReason = null,
    Object? remarks = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? officeLocation = null,
    Object? officeLatitude = null,
    Object? officeLongitude = null,
    Object? distanceInMeters = null,
    Object? attemptedAt = null,
  }) {
    return _then(
      _CheckOutException(
        employeeId: null == employeeId
            ? _self.employeeId
            : employeeId // ignore: cast_nullable_to_non_nullable
                  as String,
        exceptionReason: null == exceptionReason
            ? _self.exceptionReason
            : exceptionReason // ignore: cast_nullable_to_non_nullable
                  as String,
        remarks: null == remarks
            ? _self.remarks
            : remarks // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _self.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _self.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        officeLocation: null == officeLocation
            ? _self.officeLocation
            : officeLocation // ignore: cast_nullable_to_non_nullable
                  as String,
        officeLatitude: null == officeLatitude
            ? _self.officeLatitude
            : officeLatitude // ignore: cast_nullable_to_non_nullable
                  as double,
        officeLongitude: null == officeLongitude
            ? _self.officeLongitude
            : officeLongitude // ignore: cast_nullable_to_non_nullable
                  as double,
        distanceInMeters: null == distanceInMeters
            ? _self.distanceInMeters
            : distanceInMeters // ignore: cast_nullable_to_non_nullable
                  as double,
        attemptedAt: null == attemptedAt
            ? _self.attemptedAt
            : attemptedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
mixin _$CheckOutExceptionResponse {
  String get id;
  String get employeeId;
  String get employeeName;
  String get managerId;
  String get managerName;
  String get exceptionReason;
  String get remarks;
  String get status; // pending, approved, rejected
  DateTime get submittedAt;
  String get attendanceStatus; // Check-Out Pending Approval
  double get latitude;
  double get longitude;

  /// Create a copy of CheckOutExceptionResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CheckOutExceptionResponseCopyWith<CheckOutExceptionResponse> get copyWith =>
      _$CheckOutExceptionResponseCopyWithImpl<CheckOutExceptionResponse>(
        this as CheckOutExceptionResponse,
        _$identity,
      );

  /// Serializes this CheckOutExceptionResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CheckOutExceptionResponse &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.employeeName, employeeName) ||
                other.employeeName == employeeName) &&
            (identical(other.managerId, managerId) ||
                other.managerId == managerId) &&
            (identical(other.managerName, managerName) ||
                other.managerName == managerName) &&
            (identical(other.exceptionReason, exceptionReason) ||
                other.exceptionReason == exceptionReason) &&
            (identical(other.remarks, remarks) || other.remarks == remarks) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.attendanceStatus, attendanceStatus) ||
                other.attendanceStatus == attendanceStatus) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    employeeId,
    employeeName,
    managerId,
    managerName,
    exceptionReason,
    remarks,
    status,
    submittedAt,
    attendanceStatus,
    latitude,
    longitude,
  );

  @override
  String toString() {
    return 'CheckOutExceptionResponse(id: $id, employeeId: $employeeId, employeeName: $employeeName, managerId: $managerId, managerName: $managerName, exceptionReason: $exceptionReason, remarks: $remarks, status: $status, submittedAt: $submittedAt, attendanceStatus: $attendanceStatus, latitude: $latitude, longitude: $longitude)';
  }
}

/// @nodoc
abstract mixin class $CheckOutExceptionResponseCopyWith<$Res> {
  factory $CheckOutExceptionResponseCopyWith(
    CheckOutExceptionResponse value,
    $Res Function(CheckOutExceptionResponse) _then,
  ) = _$CheckOutExceptionResponseCopyWithImpl;
  @useResult
  $Res call({
    String id,
    String employeeId,
    String employeeName,
    String managerId,
    String managerName,
    String exceptionReason,
    String remarks,
    String status,
    DateTime submittedAt,
    String attendanceStatus,
    double latitude,
    double longitude,
  });
}

/// @nodoc
class _$CheckOutExceptionResponseCopyWithImpl<$Res>
    implements $CheckOutExceptionResponseCopyWith<$Res> {
  _$CheckOutExceptionResponseCopyWithImpl(this._self, this._then);

  final CheckOutExceptionResponse _self;
  final $Res Function(CheckOutExceptionResponse) _then;

  /// Create a copy of CheckOutExceptionResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? employeeName = null,
    Object? managerId = null,
    Object? managerName = null,
    Object? exceptionReason = null,
    Object? remarks = null,
    Object? status = null,
    Object? submittedAt = null,
    Object? attendanceStatus = null,
    Object? latitude = null,
    Object? longitude = null,
  }) {
    return _then(
      _self.copyWith(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        employeeId: null == employeeId
            ? _self.employeeId
            : employeeId // ignore: cast_nullable_to_non_nullable
                  as String,
        employeeName: null == employeeName
            ? _self.employeeName
            : employeeName // ignore: cast_nullable_to_non_nullable
                  as String,
        managerId: null == managerId
            ? _self.managerId
            : managerId // ignore: cast_nullable_to_non_nullable
                  as String,
        managerName: null == managerName
            ? _self.managerName
            : managerName // ignore: cast_nullable_to_non_nullable
                  as String,
        exceptionReason: null == exceptionReason
            ? _self.exceptionReason
            : exceptionReason // ignore: cast_nullable_to_non_nullable
                  as String,
        remarks: null == remarks
            ? _self.remarks
            : remarks // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        submittedAt: null == submittedAt
            ? _self.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        attendanceStatus: null == attendanceStatus
            ? _self.attendanceStatus
            : attendanceStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _self.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _self.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [CheckOutExceptionResponse].
extension CheckOutExceptionResponsePatterns on CheckOutExceptionResponse {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_CheckOutExceptionResponse value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckOutExceptionResponse() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_CheckOutExceptionResponse value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckOutExceptionResponse():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_CheckOutExceptionResponse value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckOutExceptionResponse() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      String id,
      String employeeId,
      String employeeName,
      String managerId,
      String managerName,
      String exceptionReason,
      String remarks,
      String status,
      DateTime submittedAt,
      String attendanceStatus,
      double latitude,
      double longitude,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CheckOutExceptionResponse() when $default != null:
        return $default(
          _that.id,
          _that.employeeId,
          _that.employeeName,
          _that.managerId,
          _that.managerName,
          _that.exceptionReason,
          _that.remarks,
          _that.status,
          _that.submittedAt,
          _that.attendanceStatus,
          _that.latitude,
          _that.longitude,
        );
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      String id,
      String employeeId,
      String employeeName,
      String managerId,
      String managerName,
      String exceptionReason,
      String remarks,
      String status,
      DateTime submittedAt,
      String attendanceStatus,
      double latitude,
      double longitude,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckOutExceptionResponse():
        return $default(
          _that.id,
          _that.employeeId,
          _that.employeeName,
          _that.managerId,
          _that.managerName,
          _that.exceptionReason,
          _that.remarks,
          _that.status,
          _that.submittedAt,
          _that.attendanceStatus,
          _that.latitude,
          _that.longitude,
        );
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      String id,
      String employeeId,
      String employeeName,
      String managerId,
      String managerName,
      String exceptionReason,
      String remarks,
      String status,
      DateTime submittedAt,
      String attendanceStatus,
      double latitude,
      double longitude,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CheckOutExceptionResponse() when $default != null:
        return $default(
          _that.id,
          _that.employeeId,
          _that.employeeName,
          _that.managerId,
          _that.managerName,
          _that.exceptionReason,
          _that.remarks,
          _that.status,
          _that.submittedAt,
          _that.attendanceStatus,
          _that.latitude,
          _that.longitude,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CheckOutExceptionResponse implements CheckOutExceptionResponse {
  const _CheckOutExceptionResponse({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.managerId,
    required this.managerName,
    required this.exceptionReason,
    required this.remarks,
    required this.status,
    required this.submittedAt,
    required this.attendanceStatus,
    required this.latitude,
    required this.longitude,
  });
  factory _CheckOutExceptionResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckOutExceptionResponseFromJson(json);

  @override
  final String id;
  @override
  final String employeeId;
  @override
  final String employeeName;
  @override
  final String managerId;
  @override
  final String managerName;
  @override
  final String exceptionReason;
  @override
  final String remarks;
  @override
  final String status;
  // pending, approved, rejected
  @override
  final DateTime submittedAt;
  @override
  final String attendanceStatus;
  // Check-Out Pending Approval
  @override
  final double latitude;
  @override
  final double longitude;

  /// Create a copy of CheckOutExceptionResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CheckOutExceptionResponseCopyWith<_CheckOutExceptionResponse>
  get copyWith =>
      __$CheckOutExceptionResponseCopyWithImpl<_CheckOutExceptionResponse>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$CheckOutExceptionResponseToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CheckOutExceptionResponse &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.employeeName, employeeName) ||
                other.employeeName == employeeName) &&
            (identical(other.managerId, managerId) ||
                other.managerId == managerId) &&
            (identical(other.managerName, managerName) ||
                other.managerName == managerName) &&
            (identical(other.exceptionReason, exceptionReason) ||
                other.exceptionReason == exceptionReason) &&
            (identical(other.remarks, remarks) || other.remarks == remarks) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.attendanceStatus, attendanceStatus) ||
                other.attendanceStatus == attendanceStatus) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    employeeId,
    employeeName,
    managerId,
    managerName,
    exceptionReason,
    remarks,
    status,
    submittedAt,
    attendanceStatus,
    latitude,
    longitude,
  );

  @override
  String toString() {
    return 'CheckOutExceptionResponse(id: $id, employeeId: $employeeId, employeeName: $employeeName, managerId: $managerId, managerName: $managerName, exceptionReason: $exceptionReason, remarks: $remarks, status: $status, submittedAt: $submittedAt, attendanceStatus: $attendanceStatus, latitude: $latitude, longitude: $longitude)';
  }
}

/// @nodoc
abstract mixin class _$CheckOutExceptionResponseCopyWith<$Res>
    implements $CheckOutExceptionResponseCopyWith<$Res> {
  factory _$CheckOutExceptionResponseCopyWith(
    _CheckOutExceptionResponse value,
    $Res Function(_CheckOutExceptionResponse) _then,
  ) = __$CheckOutExceptionResponseCopyWithImpl;
  @override
  @useResult
  $Res call({
    String id,
    String employeeId,
    String employeeName,
    String managerId,
    String managerName,
    String exceptionReason,
    String remarks,
    String status,
    DateTime submittedAt,
    String attendanceStatus,
    double latitude,
    double longitude,
  });
}

/// @nodoc
class __$CheckOutExceptionResponseCopyWithImpl<$Res>
    implements _$CheckOutExceptionResponseCopyWith<$Res> {
  __$CheckOutExceptionResponseCopyWithImpl(this._self, this._then);

  final _CheckOutExceptionResponse _self;
  final $Res Function(_CheckOutExceptionResponse) _then;

  /// Create a copy of CheckOutExceptionResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? employeeId = null,
    Object? employeeName = null,
    Object? managerId = null,
    Object? managerName = null,
    Object? exceptionReason = null,
    Object? remarks = null,
    Object? status = null,
    Object? submittedAt = null,
    Object? attendanceStatus = null,
    Object? latitude = null,
    Object? longitude = null,
  }) {
    return _then(
      _CheckOutExceptionResponse(
        id: null == id
            ? _self.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        employeeId: null == employeeId
            ? _self.employeeId
            : employeeId // ignore: cast_nullable_to_non_nullable
                  as String,
        employeeName: null == employeeName
            ? _self.employeeName
            : employeeName // ignore: cast_nullable_to_non_nullable
                  as String,
        managerId: null == managerId
            ? _self.managerId
            : managerId // ignore: cast_nullable_to_non_nullable
                  as String,
        managerName: null == managerName
            ? _self.managerName
            : managerName // ignore: cast_nullable_to_non_nullable
                  as String,
        exceptionReason: null == exceptionReason
            ? _self.exceptionReason
            : exceptionReason // ignore: cast_nullable_to_non_nullable
                  as String,
        remarks: null == remarks
            ? _self.remarks
            : remarks // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _self.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        submittedAt: null == submittedAt
            ? _self.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        attendanceStatus: null == attendanceStatus
            ? _self.attendanceStatus
            : attendanceStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _self.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _self.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}
