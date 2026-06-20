// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_summary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardSummaryModel {
  int get totalEmployees;
  int get onLeave;
  int get newHires;
  int get openRoles;
  List<String> get recentActivity;

  /// Create a copy of DashboardSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DashboardSummaryModelCopyWith<DashboardSummaryModel> get copyWith =>
      _$DashboardSummaryModelCopyWithImpl<DashboardSummaryModel>(
        this as DashboardSummaryModel,
        _$identity,
      );

  /// Serializes this DashboardSummaryModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DashboardSummaryModel &&
            (identical(other.totalEmployees, totalEmployees) ||
                other.totalEmployees == totalEmployees) &&
            (identical(other.onLeave, onLeave) || other.onLeave == onLeave) &&
            (identical(other.newHires, newHires) ||
                other.newHires == newHires) &&
            (identical(other.openRoles, openRoles) ||
                other.openRoles == openRoles) &&
            const DeepCollectionEquality().equals(
              other.recentActivity,
              recentActivity,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalEmployees,
    onLeave,
    newHires,
    openRoles,
    const DeepCollectionEquality().hash(recentActivity),
  );

  @override
  String toString() {
    return 'DashboardSummaryModel(totalEmployees: $totalEmployees, onLeave: $onLeave, newHires: $newHires, openRoles: $openRoles, recentActivity: $recentActivity)';
  }
}

/// @nodoc
abstract mixin class $DashboardSummaryModelCopyWith<$Res> {
  factory $DashboardSummaryModelCopyWith(
    DashboardSummaryModel value,
    $Res Function(DashboardSummaryModel) _then,
  ) = _$DashboardSummaryModelCopyWithImpl;
  @useResult
  $Res call({
    int totalEmployees,
    int onLeave,
    int newHires,
    int openRoles,
    List<String> recentActivity,
  });
}

/// @nodoc
class _$DashboardSummaryModelCopyWithImpl<$Res>
    implements $DashboardSummaryModelCopyWith<$Res> {
  _$DashboardSummaryModelCopyWithImpl(this._self, this._then);

  final DashboardSummaryModel _self;
  final $Res Function(DashboardSummaryModel) _then;

  /// Create a copy of DashboardSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalEmployees = null,
    Object? onLeave = null,
    Object? newHires = null,
    Object? openRoles = null,
    Object? recentActivity = null,
  }) {
    return _then(
      _self.copyWith(
        totalEmployees: null == totalEmployees
            ? _self.totalEmployees
            : totalEmployees // ignore: cast_nullable_to_non_nullable
                  as int,
        onLeave: null == onLeave
            ? _self.onLeave
            : onLeave // ignore: cast_nullable_to_non_nullable
                  as int,
        newHires: null == newHires
            ? _self.newHires
            : newHires // ignore: cast_nullable_to_non_nullable
                  as int,
        openRoles: null == openRoles
            ? _self.openRoles
            : openRoles // ignore: cast_nullable_to_non_nullable
                  as int,
        recentActivity: null == recentActivity
            ? _self.recentActivity
            : recentActivity // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [DashboardSummaryModel].
extension DashboardSummaryModelPatterns on DashboardSummaryModel {
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
    TResult Function(_DashboardSummaryModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DashboardSummaryModel() when $default != null:
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
    TResult Function(_DashboardSummaryModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardSummaryModel():
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
    TResult? Function(_DashboardSummaryModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardSummaryModel() when $default != null:
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
      int totalEmployees,
      int onLeave,
      int newHires,
      int openRoles,
      List<String> recentActivity,
    )?
    $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DashboardSummaryModel() when $default != null:
        return $default(
          _that.totalEmployees,
          _that.onLeave,
          _that.newHires,
          _that.openRoles,
          _that.recentActivity,
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
      int totalEmployees,
      int onLeave,
      int newHires,
      int openRoles,
      List<String> recentActivity,
    )
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardSummaryModel():
        return $default(
          _that.totalEmployees,
          _that.onLeave,
          _that.newHires,
          _that.openRoles,
          _that.recentActivity,
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
      int totalEmployees,
      int onLeave,
      int newHires,
      int openRoles,
      List<String> recentActivity,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardSummaryModel() when $default != null:
        return $default(
          _that.totalEmployees,
          _that.onLeave,
          _that.newHires,
          _that.openRoles,
          _that.recentActivity,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DashboardSummaryModel implements DashboardSummaryModel {
  const _DashboardSummaryModel({
    required this.totalEmployees,
    required this.onLeave,
    required this.newHires,
    required this.openRoles,
    required final List<String> recentActivity,
  }) : _recentActivity = recentActivity;
  factory _DashboardSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardSummaryModelFromJson(json);

  @override
  final int totalEmployees;
  @override
  final int onLeave;
  @override
  final int newHires;
  @override
  final int openRoles;
  final List<String> _recentActivity;
  @override
  List<String> get recentActivity {
    if (_recentActivity is EqualUnmodifiableListView) return _recentActivity;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentActivity);
  }

  /// Create a copy of DashboardSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DashboardSummaryModelCopyWith<_DashboardSummaryModel> get copyWith =>
      __$DashboardSummaryModelCopyWithImpl<_DashboardSummaryModel>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$DashboardSummaryModelToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DashboardSummaryModel &&
            (identical(other.totalEmployees, totalEmployees) ||
                other.totalEmployees == totalEmployees) &&
            (identical(other.onLeave, onLeave) || other.onLeave == onLeave) &&
            (identical(other.newHires, newHires) ||
                other.newHires == newHires) &&
            (identical(other.openRoles, openRoles) ||
                other.openRoles == openRoles) &&
            const DeepCollectionEquality().equals(
              other._recentActivity,
              _recentActivity,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalEmployees,
    onLeave,
    newHires,
    openRoles,
    const DeepCollectionEquality().hash(_recentActivity),
  );

  @override
  String toString() {
    return 'DashboardSummaryModel(totalEmployees: $totalEmployees, onLeave: $onLeave, newHires: $newHires, openRoles: $openRoles, recentActivity: $recentActivity)';
  }
}

/// @nodoc
abstract mixin class _$DashboardSummaryModelCopyWith<$Res>
    implements $DashboardSummaryModelCopyWith<$Res> {
  factory _$DashboardSummaryModelCopyWith(
    _DashboardSummaryModel value,
    $Res Function(_DashboardSummaryModel) _then,
  ) = __$DashboardSummaryModelCopyWithImpl;
  @override
  @useResult
  $Res call({
    int totalEmployees,
    int onLeave,
    int newHires,
    int openRoles,
    List<String> recentActivity,
  });
}

/// @nodoc
class __$DashboardSummaryModelCopyWithImpl<$Res>
    implements _$DashboardSummaryModelCopyWith<$Res> {
  __$DashboardSummaryModelCopyWithImpl(this._self, this._then);

  final _DashboardSummaryModel _self;
  final $Res Function(_DashboardSummaryModel) _then;

  /// Create a copy of DashboardSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? totalEmployees = null,
    Object? onLeave = null,
    Object? newHires = null,
    Object? openRoles = null,
    Object? recentActivity = null,
  }) {
    return _then(
      _DashboardSummaryModel(
        totalEmployees: null == totalEmployees
            ? _self.totalEmployees
            : totalEmployees // ignore: cast_nullable_to_non_nullable
                  as int,
        onLeave: null == onLeave
            ? _self.onLeave
            : onLeave // ignore: cast_nullable_to_non_nullable
                  as int,
        newHires: null == newHires
            ? _self.newHires
            : newHires // ignore: cast_nullable_to_non_nullable
                  as int,
        openRoles: null == openRoles
            ? _self.openRoles
            : openRoles // ignore: cast_nullable_to_non_nullable
                  as int,
        recentActivity: null == recentActivity
            ? _self._recentActivity
            : recentActivity // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}
