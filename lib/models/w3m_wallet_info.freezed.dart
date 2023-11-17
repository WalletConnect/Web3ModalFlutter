// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'w3m_wallet_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

W3MWalletInfo _$W3MWalletInfoFromJson(Map<String, dynamic> json) {
  return _W3MWalletInfo.fromJson(json);
}

/// @nodoc
mixin _$W3MWalletInfo {
  Listing get listing => throw _privateConstructorUsedError;
  bool get installed => throw _privateConstructorUsedError;
  bool get recent => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $W3MWalletInfoCopyWith<W3MWalletInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $W3MWalletInfoCopyWith<$Res> {
  factory $W3MWalletInfoCopyWith(
          W3MWalletInfo value, $Res Function(W3MWalletInfo) then) =
      _$W3MWalletInfoCopyWithImpl<$Res, W3MWalletInfo>;
  @useResult
  $Res call({Listing listing, bool installed, bool recent});
}

/// @nodoc
class _$W3MWalletInfoCopyWithImpl<$Res, $Val extends W3MWalletInfo>
    implements $W3MWalletInfoCopyWith<$Res> {
  _$W3MWalletInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listing = null,
    Object? installed = null,
    Object? recent = null,
  }) {
    return _then(_value.copyWith(
      listing: null == listing
          ? _value.listing
          : listing // ignore: cast_nullable_to_non_nullable
              as Listing,
      installed: null == installed
          ? _value.installed
          : installed // ignore: cast_nullable_to_non_nullable
              as bool,
      recent: null == recent
          ? _value.recent
          : recent // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$W3MWalletInfoImplCopyWith<$Res>
    implements $W3MWalletInfoCopyWith<$Res> {
  factory _$$W3MWalletInfoImplCopyWith(
          _$W3MWalletInfoImpl value, $Res Function(_$W3MWalletInfoImpl) then) =
      __$$W3MWalletInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Listing listing, bool installed, bool recent});
}

/// @nodoc
class __$$W3MWalletInfoImplCopyWithImpl<$Res>
    extends _$W3MWalletInfoCopyWithImpl<$Res, _$W3MWalletInfoImpl>
    implements _$$W3MWalletInfoImplCopyWith<$Res> {
  __$$W3MWalletInfoImplCopyWithImpl(
      _$W3MWalletInfoImpl _value, $Res Function(_$W3MWalletInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listing = null,
    Object? installed = null,
    Object? recent = null,
  }) {
    return _then(_$W3MWalletInfoImpl(
      listing: null == listing
          ? _value.listing
          : listing // ignore: cast_nullable_to_non_nullable
              as Listing,
      installed: null == installed
          ? _value.installed
          : installed // ignore: cast_nullable_to_non_nullable
              as bool,
      recent: null == recent
          ? _value.recent
          : recent // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$W3MWalletInfoImpl implements _W3MWalletInfo {
  const _$W3MWalletInfoImpl(
      {required this.listing, required this.installed, required this.recent});

  factory _$W3MWalletInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$W3MWalletInfoImplFromJson(json);

  @override
  final Listing listing;
  @override
  final bool installed;
  @override
  final bool recent;

  @override
  String toString() {
    return 'W3MWalletInfo(listing: $listing, installed: $installed, recent: $recent)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$W3MWalletInfoImpl &&
            (identical(other.listing, listing) || other.listing == listing) &&
            (identical(other.installed, installed) ||
                other.installed == installed) &&
            (identical(other.recent, recent) || other.recent == recent));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, listing, installed, recent);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$W3MWalletInfoImplCopyWith<_$W3MWalletInfoImpl> get copyWith =>
      __$$W3MWalletInfoImplCopyWithImpl<_$W3MWalletInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$W3MWalletInfoImplToJson(
      this,
    );
  }
}

abstract class _W3MWalletInfo implements W3MWalletInfo {
  const factory _W3MWalletInfo(
      {required final Listing listing,
      required final bool installed,
      required final bool recent}) = _$W3MWalletInfoImpl;

  factory _W3MWalletInfo.fromJson(Map<String, dynamic> json) =
      _$W3MWalletInfoImpl.fromJson;

  @override
  Listing get listing;
  @override
  bool get installed;
  @override
  bool get recent;
  @override
  @JsonKey(ignore: true)
  _$$W3MWalletInfoImplCopyWith<_$W3MWalletInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
