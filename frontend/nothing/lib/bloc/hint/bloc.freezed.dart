// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;
HintState _$HintStateFromJson(Map<String, dynamic> json) {
  return _HintState.fromJson(json);
}

/// @nodoc
class _$HintStateTearOff {
  const _$HintStateTearOff();

// ignore: unused_element
  _HintState call(bool unlocked) {
    return _HintState(
      unlocked,
    );
  }

// ignore: unused_element
  HintState fromJson(Map<String, Object> json) {
    return HintState.fromJson(json);
  }
}

/// @nodoc
// ignore: unused_element
const $HintState = _$HintStateTearOff();

/// @nodoc
mixin _$HintState {
  bool get unlocked;

  Map<String, dynamic> toJson();
  $HintStateCopyWith<HintState> get copyWith;
}

/// @nodoc
abstract class $HintStateCopyWith<$Res> {
  factory $HintStateCopyWith(HintState value, $Res Function(HintState) then) =
      _$HintStateCopyWithImpl<$Res>;
  $Res call({bool unlocked});
}

/// @nodoc
class _$HintStateCopyWithImpl<$Res> implements $HintStateCopyWith<$Res> {
  _$HintStateCopyWithImpl(this._value, this._then);

  final HintState _value;
  // ignore: unused_field
  final $Res Function(HintState) _then;

  @override
  $Res call({
    Object unlocked = freezed,
  }) {
    return _then(_value.copyWith(
      unlocked: unlocked == freezed ? _value.unlocked : unlocked as bool,
    ));
  }
}

/// @nodoc
abstract class _$HintStateCopyWith<$Res> implements $HintStateCopyWith<$Res> {
  factory _$HintStateCopyWith(
          _HintState value, $Res Function(_HintState) then) =
      __$HintStateCopyWithImpl<$Res>;
  @override
  $Res call({bool unlocked});
}

/// @nodoc
class __$HintStateCopyWithImpl<$Res> extends _$HintStateCopyWithImpl<$Res>
    implements _$HintStateCopyWith<$Res> {
  __$HintStateCopyWithImpl(_HintState _value, $Res Function(_HintState) _then)
      : super(_value, (v) => _then(v as _HintState));

  @override
  _HintState get _value => super._value as _HintState;

  @override
  $Res call({
    Object unlocked = freezed,
  }) {
    return _then(_HintState(
      unlocked == freezed ? _value.unlocked : unlocked as bool,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$_HintState with DiagnosticableTreeMixin implements _HintState {
  const _$_HintState(this.unlocked) : assert(unlocked != null);

  factory _$_HintState.fromJson(Map<String, dynamic> json) =>
      _$_$_HintStateFromJson(json);

  @override
  final bool unlocked;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'HintState(unlocked: $unlocked)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'HintState'))
      ..add(DiagnosticsProperty('unlocked', unlocked));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _HintState &&
            (identical(other.unlocked, unlocked) ||
                const DeepCollectionEquality()
                    .equals(other.unlocked, unlocked)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(unlocked);

  @override
  _$HintStateCopyWith<_HintState> get copyWith =>
      __$HintStateCopyWithImpl<_HintState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_HintStateToJson(this);
  }
}

abstract class _HintState implements HintState {
  const factory _HintState(bool unlocked) = _$_HintState;

  factory _HintState.fromJson(Map<String, dynamic> json) =
      _$_HintState.fromJson;

  @override
  bool get unlocked;
  @override
  _$HintStateCopyWith<_HintState> get copyWith;
}
