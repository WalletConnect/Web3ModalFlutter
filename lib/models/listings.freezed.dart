// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

WalletData _$WalletDataFromJson(Map<String, dynamic> json) {
  return _WalletData.fromJson(json);
}

/// @nodoc
mixin _$WalletData {
  Listing get listing => throw _privateConstructorUsedError;
  bool get installed => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WalletDataCopyWith<WalletData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletDataCopyWith<$Res> {
  factory $WalletDataCopyWith(
          WalletData value, $Res Function(WalletData) then) =
      _$WalletDataCopyWithImpl<$Res, WalletData>;
  @useResult
  $Res call({Listing listing, bool installed});

  $ListingCopyWith<$Res> get listing;
}

/// @nodoc
class _$WalletDataCopyWithImpl<$Res, $Val extends WalletData>
    implements $WalletDataCopyWith<$Res> {
  _$WalletDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listing = null,
    Object? installed = null,
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
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ListingCopyWith<$Res> get listing {
    return $ListingCopyWith<$Res>(_value.listing, (value) {
      return _then(_value.copyWith(listing: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_WalletDataCopyWith<$Res>
    implements $WalletDataCopyWith<$Res> {
  factory _$$_WalletDataCopyWith(
          _$_WalletData value, $Res Function(_$_WalletData) then) =
      __$$_WalletDataCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Listing listing, bool installed});

  @override
  $ListingCopyWith<$Res> get listing;
}

/// @nodoc
class __$$_WalletDataCopyWithImpl<$Res>
    extends _$WalletDataCopyWithImpl<$Res, _$_WalletData>
    implements _$$_WalletDataCopyWith<$Res> {
  __$$_WalletDataCopyWithImpl(
      _$_WalletData _value, $Res Function(_$_WalletData) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listing = null,
    Object? installed = null,
  }) {
    return _then(_$_WalletData(
      listing: null == listing
          ? _value.listing
          : listing // ignore: cast_nullable_to_non_nullable
              as Listing,
      installed: null == installed
          ? _value.installed
          : installed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$_WalletData implements _WalletData {
  const _$_WalletData({required this.listing, required this.installed});

  factory _$_WalletData.fromJson(Map<String, dynamic> json) =>
      _$$_WalletDataFromJson(json);

  @override
  final Listing listing;
  @override
  final bool installed;

  @override
  String toString() {
    return 'WalletData(listing: $listing, installed: $installed)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_WalletData &&
            (identical(other.listing, listing) || other.listing == listing) &&
            (identical(other.installed, installed) ||
                other.installed == installed));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, listing, installed);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_WalletDataCopyWith<_$_WalletData> get copyWith =>
      __$$_WalletDataCopyWithImpl<_$_WalletData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_WalletDataToJson(
      this,
    );
  }
}

abstract class _WalletData implements WalletData {
  const factory _WalletData(
      {required final Listing listing,
      required final bool installed}) = _$_WalletData;

  factory _WalletData.fromJson(Map<String, dynamic> json) =
      _$_WalletData.fromJson;

  @override
  Listing get listing;
  @override
  bool get installed;
  @override
  @JsonKey(ignore: true)
  _$$_WalletDataCopyWith<_$_WalletData> get copyWith =>
      throw _privateConstructorUsedError;
}

ListingResponse _$ListingResponseFromJson(Map<String, dynamic> json) {
  return _ListingResponse.fromJson(json);
}

/// @nodoc
mixin _$ListingResponse {
  Map<String, Listing> get listings => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ListingResponseCopyWith<ListingResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingResponseCopyWith<$Res> {
  factory $ListingResponseCopyWith(
          ListingResponse value, $Res Function(ListingResponse) then) =
      _$ListingResponseCopyWithImpl<$Res, ListingResponse>;
  @useResult
  $Res call({Map<String, Listing> listings, int total});
}

/// @nodoc
class _$ListingResponseCopyWithImpl<$Res, $Val extends ListingResponse>
    implements $ListingResponseCopyWith<$Res> {
  _$ListingResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listings = null,
    Object? total = null,
  }) {
    return _then(_value.copyWith(
      listings: null == listings
          ? _value.listings
          : listings // ignore: cast_nullable_to_non_nullable
              as Map<String, Listing>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ListingResponseCopyWith<$Res>
    implements $ListingResponseCopyWith<$Res> {
  factory _$$_ListingResponseCopyWith(
          _$_ListingResponse value, $Res Function(_$_ListingResponse) then) =
      __$$_ListingResponseCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, Listing> listings, int total});
}

/// @nodoc
class __$$_ListingResponseCopyWithImpl<$Res>
    extends _$ListingResponseCopyWithImpl<$Res, _$_ListingResponse>
    implements _$$_ListingResponseCopyWith<$Res> {
  __$$_ListingResponseCopyWithImpl(
      _$_ListingResponse _value, $Res Function(_$_ListingResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listings = null,
    Object? total = null,
  }) {
    return _then(_$_ListingResponse(
      listings: null == listings
          ? _value._listings
          : listings // ignore: cast_nullable_to_non_nullable
              as Map<String, Listing>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$_ListingResponse implements _ListingResponse {
  const _$_ListingResponse(
      {required final Map<String, Listing> listings, required this.total})
      : _listings = listings;

  factory _$_ListingResponse.fromJson(Map<String, dynamic> json) =>
      _$$_ListingResponseFromJson(json);

  final Map<String, Listing> _listings;
  @override
  Map<String, Listing> get listings {
    if (_listings is EqualUnmodifiableMapView) return _listings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_listings);
  }

  @override
  final int total;

  @override
  String toString() {
    return 'ListingResponse(listings: $listings, total: $total)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ListingResponse &&
            const DeepCollectionEquality().equals(other._listings, _listings) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_listings), total);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ListingResponseCopyWith<_$_ListingResponse> get copyWith =>
      __$$_ListingResponseCopyWithImpl<_$_ListingResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ListingResponseToJson(
      this,
    );
  }
}

abstract class _ListingResponse implements ListingResponse {
  const factory _ListingResponse(
      {required final Map<String, Listing> listings,
      required final int total}) = _$_ListingResponse;

  factory _ListingResponse.fromJson(Map<String, dynamic> json) =
      _$_ListingResponse.fromJson;

  @override
  Map<String, Listing> get listings;
  @override
  int get total;
  @override
  @JsonKey(ignore: true)
  _$$_ListingResponseCopyWith<_$_ListingResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

Listing _$ListingFromJson(Map<String, dynamic> json) {
  return _Listing.fromJson(json);
}

/// @nodoc
mixin _$Listing {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get homepage => throw _privateConstructorUsedError;
  String get imageId => throw _privateConstructorUsedError;
  App get app => throw _privateConstructorUsedError;
  List<Injected>? get injected => throw _privateConstructorUsedError;
  Redirect get mobile => throw _privateConstructorUsedError;
  Redirect get desktop => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ListingCopyWith<Listing> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingCopyWith<$Res> {
  factory $ListingCopyWith(Listing value, $Res Function(Listing) then) =
      _$ListingCopyWithImpl<$Res, Listing>;
  @useResult
  $Res call(
      {String id,
      String name,
      String homepage,
      String imageId,
      App app,
      List<Injected>? injected,
      Redirect mobile,
      Redirect desktop});

  $AppCopyWith<$Res> get app;
}

/// @nodoc
class _$ListingCopyWithImpl<$Res, $Val extends Listing>
    implements $ListingCopyWith<$Res> {
  _$ListingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? homepage = null,
    Object? imageId = null,
    Object? app = null,
    Object? injected = freezed,
    Object? mobile = null,
    Object? desktop = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      homepage: null == homepage
          ? _value.homepage
          : homepage // ignore: cast_nullable_to_non_nullable
              as String,
      imageId: null == imageId
          ? _value.imageId
          : imageId // ignore: cast_nullable_to_non_nullable
              as String,
      app: null == app
          ? _value.app
          : app // ignore: cast_nullable_to_non_nullable
              as App,
      injected: freezed == injected
          ? _value.injected
          : injected // ignore: cast_nullable_to_non_nullable
              as List<Injected>?,
      mobile: null == mobile
          ? _value.mobile
          : mobile // ignore: cast_nullable_to_non_nullable
              as Redirect,
      desktop: null == desktop
          ? _value.desktop
          : desktop // ignore: cast_nullable_to_non_nullable
              as Redirect,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AppCopyWith<$Res> get app {
    return $AppCopyWith<$Res>(_value.app, (value) {
      return _then(_value.copyWith(app: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_ListingCopyWith<$Res> implements $ListingCopyWith<$Res> {
  factory _$$_ListingCopyWith(
          _$_Listing value, $Res Function(_$_Listing) then) =
      __$$_ListingCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String homepage,
      String imageId,
      App app,
      List<Injected>? injected,
      Redirect mobile,
      Redirect desktop});

  @override
  $AppCopyWith<$Res> get app;
}

/// @nodoc
class __$$_ListingCopyWithImpl<$Res>
    extends _$ListingCopyWithImpl<$Res, _$_Listing>
    implements _$$_ListingCopyWith<$Res> {
  __$$_ListingCopyWithImpl(_$_Listing _value, $Res Function(_$_Listing) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? homepage = null,
    Object? imageId = null,
    Object? app = null,
    Object? injected = freezed,
    Object? mobile = null,
    Object? desktop = null,
  }) {
    return _then(_$_Listing(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      homepage: null == homepage
          ? _value.homepage
          : homepage // ignore: cast_nullable_to_non_nullable
              as String,
      imageId: null == imageId
          ? _value.imageId
          : imageId // ignore: cast_nullable_to_non_nullable
              as String,
      app: null == app
          ? _value.app
          : app // ignore: cast_nullable_to_non_nullable
              as App,
      injected: freezed == injected
          ? _value._injected
          : injected // ignore: cast_nullable_to_non_nullable
              as List<Injected>?,
      mobile: null == mobile
          ? _value.mobile
          : mobile // ignore: cast_nullable_to_non_nullable
              as Redirect,
      desktop: null == desktop
          ? _value.desktop
          : desktop // ignore: cast_nullable_to_non_nullable
              as Redirect,
    ));
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake)
class _$_Listing implements _Listing {
  const _$_Listing(
      {required this.id,
      required this.name,
      required this.homepage,
      required this.imageId,
      required this.app,
      final List<Injected>? injected,
      required this.mobile,
      required this.desktop})
      : _injected = injected;

  factory _$_Listing.fromJson(Map<String, dynamic> json) =>
      _$$_ListingFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String homepage;
  @override
  final String imageId;
  @override
  final App app;
  final List<Injected>? _injected;
  @override
  List<Injected>? get injected {
    final value = _injected;
    if (value == null) return null;
    if (_injected is EqualUnmodifiableListView) return _injected;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final Redirect mobile;
  @override
  final Redirect desktop;

  @override
  String toString() {
    return 'Listing(id: $id, name: $name, homepage: $homepage, imageId: $imageId, app: $app, injected: $injected, mobile: $mobile, desktop: $desktop)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Listing &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.homepage, homepage) ||
                other.homepage == homepage) &&
            (identical(other.imageId, imageId) || other.imageId == imageId) &&
            (identical(other.app, app) || other.app == app) &&
            const DeepCollectionEquality().equals(other._injected, _injected) &&
            (identical(other.mobile, mobile) || other.mobile == mobile) &&
            (identical(other.desktop, desktop) || other.desktop == desktop));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, homepage, imageId, app,
      const DeepCollectionEquality().hash(_injected), mobile, desktop);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ListingCopyWith<_$_Listing> get copyWith =>
      __$$_ListingCopyWithImpl<_$_Listing>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ListingToJson(
      this,
    );
  }
}

abstract class _Listing implements Listing {
  const factory _Listing(
      {required final String id,
      required final String name,
      required final String homepage,
      required final String imageId,
      required final App app,
      final List<Injected>? injected,
      required final Redirect mobile,
      required final Redirect desktop}) = _$_Listing;

  factory _Listing.fromJson(Map<String, dynamic> json) = _$_Listing.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get homepage;
  @override
  String get imageId;
  @override
  App get app;
  @override
  List<Injected>? get injected;
  @override
  Redirect get mobile;
  @override
  Redirect get desktop;
  @override
  @JsonKey(ignore: true)
  _$$_ListingCopyWith<_$_Listing> get copyWith =>
      throw _privateConstructorUsedError;
}

App _$AppFromJson(Map<String, dynamic> json) {
  return _App.fromJson(json);
}

/// @nodoc
mixin _$App {
  String? get browser => throw _privateConstructorUsedError;
  String? get ios => throw _privateConstructorUsedError;
  String? get android => throw _privateConstructorUsedError;
  String? get mac => throw _privateConstructorUsedError;
  String? get windows => throw _privateConstructorUsedError;
  String? get linux => throw _privateConstructorUsedError;
  String? get chrome => throw _privateConstructorUsedError;
  String? get firefox => throw _privateConstructorUsedError;
  String? get safari => throw _privateConstructorUsedError;
  String? get edge => throw _privateConstructorUsedError;
  String? get opera => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppCopyWith<App> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppCopyWith<$Res> {
  factory $AppCopyWith(App value, $Res Function(App) then) =
      _$AppCopyWithImpl<$Res, App>;
  @useResult
  $Res call(
      {String? browser,
      String? ios,
      String? android,
      String? mac,
      String? windows,
      String? linux,
      String? chrome,
      String? firefox,
      String? safari,
      String? edge,
      String? opera});
}

/// @nodoc
class _$AppCopyWithImpl<$Res, $Val extends App> implements $AppCopyWith<$Res> {
  _$AppCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? browser = freezed,
    Object? ios = freezed,
    Object? android = freezed,
    Object? mac = freezed,
    Object? windows = freezed,
    Object? linux = freezed,
    Object? chrome = freezed,
    Object? firefox = freezed,
    Object? safari = freezed,
    Object? edge = freezed,
    Object? opera = freezed,
  }) {
    return _then(_value.copyWith(
      browser: freezed == browser
          ? _value.browser
          : browser // ignore: cast_nullable_to_non_nullable
              as String?,
      ios: freezed == ios
          ? _value.ios
          : ios // ignore: cast_nullable_to_non_nullable
              as String?,
      android: freezed == android
          ? _value.android
          : android // ignore: cast_nullable_to_non_nullable
              as String?,
      mac: freezed == mac
          ? _value.mac
          : mac // ignore: cast_nullable_to_non_nullable
              as String?,
      windows: freezed == windows
          ? _value.windows
          : windows // ignore: cast_nullable_to_non_nullable
              as String?,
      linux: freezed == linux
          ? _value.linux
          : linux // ignore: cast_nullable_to_non_nullable
              as String?,
      chrome: freezed == chrome
          ? _value.chrome
          : chrome // ignore: cast_nullable_to_non_nullable
              as String?,
      firefox: freezed == firefox
          ? _value.firefox
          : firefox // ignore: cast_nullable_to_non_nullable
              as String?,
      safari: freezed == safari
          ? _value.safari
          : safari // ignore: cast_nullable_to_non_nullable
              as String?,
      edge: freezed == edge
          ? _value.edge
          : edge // ignore: cast_nullable_to_non_nullable
              as String?,
      opera: freezed == opera
          ? _value.opera
          : opera // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_AppCopyWith<$Res> implements $AppCopyWith<$Res> {
  factory _$$_AppCopyWith(_$_App value, $Res Function(_$_App) then) =
      __$$_AppCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? browser,
      String? ios,
      String? android,
      String? mac,
      String? windows,
      String? linux,
      String? chrome,
      String? firefox,
      String? safari,
      String? edge,
      String? opera});
}

/// @nodoc
class __$$_AppCopyWithImpl<$Res> extends _$AppCopyWithImpl<$Res, _$_App>
    implements _$$_AppCopyWith<$Res> {
  __$$_AppCopyWithImpl(_$_App _value, $Res Function(_$_App) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? browser = freezed,
    Object? ios = freezed,
    Object? android = freezed,
    Object? mac = freezed,
    Object? windows = freezed,
    Object? linux = freezed,
    Object? chrome = freezed,
    Object? firefox = freezed,
    Object? safari = freezed,
    Object? edge = freezed,
    Object? opera = freezed,
  }) {
    return _then(_$_App(
      browser: freezed == browser
          ? _value.browser
          : browser // ignore: cast_nullable_to_non_nullable
              as String?,
      ios: freezed == ios
          ? _value.ios
          : ios // ignore: cast_nullable_to_non_nullable
              as String?,
      android: freezed == android
          ? _value.android
          : android // ignore: cast_nullable_to_non_nullable
              as String?,
      mac: freezed == mac
          ? _value.mac
          : mac // ignore: cast_nullable_to_non_nullable
              as String?,
      windows: freezed == windows
          ? _value.windows
          : windows // ignore: cast_nullable_to_non_nullable
              as String?,
      linux: freezed == linux
          ? _value.linux
          : linux // ignore: cast_nullable_to_non_nullable
              as String?,
      chrome: freezed == chrome
          ? _value.chrome
          : chrome // ignore: cast_nullable_to_non_nullable
              as String?,
      firefox: freezed == firefox
          ? _value.firefox
          : firefox // ignore: cast_nullable_to_non_nullable
              as String?,
      safari: freezed == safari
          ? _value.safari
          : safari // ignore: cast_nullable_to_non_nullable
              as String?,
      edge: freezed == edge
          ? _value.edge
          : edge // ignore: cast_nullable_to_non_nullable
              as String?,
      opera: freezed == opera
          ? _value.opera
          : opera // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake)
class _$_App implements _App {
  const _$_App(
      {this.browser,
      this.ios,
      this.android,
      this.mac,
      this.windows,
      this.linux,
      this.chrome,
      this.firefox,
      this.safari,
      this.edge,
      this.opera});

  factory _$_App.fromJson(Map<String, dynamic> json) => _$$_AppFromJson(json);

  @override
  final String? browser;
  @override
  final String? ios;
  @override
  final String? android;
  @override
  final String? mac;
  @override
  final String? windows;
  @override
  final String? linux;
  @override
  final String? chrome;
  @override
  final String? firefox;
  @override
  final String? safari;
  @override
  final String? edge;
  @override
  final String? opera;

  @override
  String toString() {
    return 'App(browser: $browser, ios: $ios, android: $android, mac: $mac, windows: $windows, linux: $linux, chrome: $chrome, firefox: $firefox, safari: $safari, edge: $edge, opera: $opera)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_App &&
            (identical(other.browser, browser) || other.browser == browser) &&
            (identical(other.ios, ios) || other.ios == ios) &&
            (identical(other.android, android) || other.android == android) &&
            (identical(other.mac, mac) || other.mac == mac) &&
            (identical(other.windows, windows) || other.windows == windows) &&
            (identical(other.linux, linux) || other.linux == linux) &&
            (identical(other.chrome, chrome) || other.chrome == chrome) &&
            (identical(other.firefox, firefox) || other.firefox == firefox) &&
            (identical(other.safari, safari) || other.safari == safari) &&
            (identical(other.edge, edge) || other.edge == edge) &&
            (identical(other.opera, opera) || other.opera == opera));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, browser, ios, android, mac,
      windows, linux, chrome, firefox, safari, edge, opera);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_AppCopyWith<_$_App> get copyWith =>
      __$$_AppCopyWithImpl<_$_App>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_AppToJson(
      this,
    );
  }
}

abstract class _App implements App {
  const factory _App(
      {final String? browser,
      final String? ios,
      final String? android,
      final String? mac,
      final String? windows,
      final String? linux,
      final String? chrome,
      final String? firefox,
      final String? safari,
      final String? edge,
      final String? opera}) = _$_App;

  factory _App.fromJson(Map<String, dynamic> json) = _$_App.fromJson;

  @override
  String? get browser;
  @override
  String? get ios;
  @override
  String? get android;
  @override
  String? get mac;
  @override
  String? get windows;
  @override
  String? get linux;
  @override
  String? get chrome;
  @override
  String? get firefox;
  @override
  String? get safari;
  @override
  String? get edge;
  @override
  String? get opera;
  @override
  @JsonKey(ignore: true)
  _$$_AppCopyWith<_$_App> get copyWith => throw _privateConstructorUsedError;
}

Injected _$InjectedFromJson(Map<String, dynamic> json) {
  return _Injected.fromJson(json);
}

/// @nodoc
mixin _$Injected {
  String get injectedId => throw _privateConstructorUsedError;
  String get namespace => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InjectedCopyWith<Injected> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InjectedCopyWith<$Res> {
  factory $InjectedCopyWith(Injected value, $Res Function(Injected) then) =
      _$InjectedCopyWithImpl<$Res, Injected>;
  @useResult
  $Res call({String injectedId, String namespace});
}

/// @nodoc
class _$InjectedCopyWithImpl<$Res, $Val extends Injected>
    implements $InjectedCopyWith<$Res> {
  _$InjectedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? injectedId = null,
    Object? namespace = null,
  }) {
    return _then(_value.copyWith(
      injectedId: null == injectedId
          ? _value.injectedId
          : injectedId // ignore: cast_nullable_to_non_nullable
              as String,
      namespace: null == namespace
          ? _value.namespace
          : namespace // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_InjectedCopyWith<$Res> implements $InjectedCopyWith<$Res> {
  factory _$$_InjectedCopyWith(
          _$_Injected value, $Res Function(_$_Injected) then) =
      __$$_InjectedCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String injectedId, String namespace});
}

/// @nodoc
class __$$_InjectedCopyWithImpl<$Res>
    extends _$InjectedCopyWithImpl<$Res, _$_Injected>
    implements _$$_InjectedCopyWith<$Res> {
  __$$_InjectedCopyWithImpl(
      _$_Injected _value, $Res Function(_$_Injected) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? injectedId = null,
    Object? namespace = null,
  }) {
    return _then(_$_Injected(
      injectedId: null == injectedId
          ? _value.injectedId
          : injectedId // ignore: cast_nullable_to_non_nullable
              as String,
      namespace: null == namespace
          ? _value.namespace
          : namespace // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake)
class _$_Injected implements _Injected {
  const _$_Injected({required this.injectedId, required this.namespace});

  factory _$_Injected.fromJson(Map<String, dynamic> json) =>
      _$$_InjectedFromJson(json);

  @override
  final String injectedId;
  @override
  final String namespace;

  @override
  String toString() {
    return 'Injected(injectedId: $injectedId, namespace: $namespace)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Injected &&
            (identical(other.injectedId, injectedId) ||
                other.injectedId == injectedId) &&
            (identical(other.namespace, namespace) ||
                other.namespace == namespace));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, injectedId, namespace);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_InjectedCopyWith<_$_Injected> get copyWith =>
      __$$_InjectedCopyWithImpl<_$_Injected>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_InjectedToJson(
      this,
    );
  }
}

abstract class _Injected implements Injected {
  const factory _Injected(
      {required final String injectedId,
      required final String namespace}) = _$_Injected;

  factory _Injected.fromJson(Map<String, dynamic> json) = _$_Injected.fromJson;

  @override
  String get injectedId;
  @override
  String get namespace;
  @override
  @JsonKey(ignore: true)
  _$$_InjectedCopyWith<_$_Injected> get copyWith =>
      throw _privateConstructorUsedError;
}

ListingParams _$ListingParamsFromJson(Map<String, dynamic> json) {
  return _ListingParams.fromJson(json);
}

/// @nodoc
mixin _$ListingParams {
  int? get page => throw _privateConstructorUsedError;
  String? get search => throw _privateConstructorUsedError;
  int? get entries => throw _privateConstructorUsedError;
  int? get version => throw _privateConstructorUsedError;
  String? get chains => throw _privateConstructorUsedError;
  String? get recommendedIds => throw _privateConstructorUsedError;
  String? get excludedIds => throw _privateConstructorUsedError;
  String? get sdks => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ListingParamsCopyWith<ListingParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingParamsCopyWith<$Res> {
  factory $ListingParamsCopyWith(
          ListingParams value, $Res Function(ListingParams) then) =
      _$ListingParamsCopyWithImpl<$Res, ListingParams>;
  @useResult
  $Res call(
      {int? page,
      String? search,
      int? entries,
      int? version,
      String? chains,
      String? recommendedIds,
      String? excludedIds,
      String? sdks});
}

/// @nodoc
class _$ListingParamsCopyWithImpl<$Res, $Val extends ListingParams>
    implements $ListingParamsCopyWith<$Res> {
  _$ListingParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = freezed,
    Object? search = freezed,
    Object? entries = freezed,
    Object? version = freezed,
    Object? chains = freezed,
    Object? recommendedIds = freezed,
    Object? excludedIds = freezed,
    Object? sdks = freezed,
  }) {
    return _then(_value.copyWith(
      page: freezed == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
      search: freezed == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String?,
      entries: freezed == entries
          ? _value.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as int?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int?,
      chains: freezed == chains
          ? _value.chains
          : chains // ignore: cast_nullable_to_non_nullable
              as String?,
      recommendedIds: freezed == recommendedIds
          ? _value.recommendedIds
          : recommendedIds // ignore: cast_nullable_to_non_nullable
              as String?,
      excludedIds: freezed == excludedIds
          ? _value.excludedIds
          : excludedIds // ignore: cast_nullable_to_non_nullable
              as String?,
      sdks: freezed == sdks
          ? _value.sdks
          : sdks // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ListingParamsCopyWith<$Res>
    implements $ListingParamsCopyWith<$Res> {
  factory _$$_ListingParamsCopyWith(
          _$_ListingParams value, $Res Function(_$_ListingParams) then) =
      __$$_ListingParamsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? page,
      String? search,
      int? entries,
      int? version,
      String? chains,
      String? recommendedIds,
      String? excludedIds,
      String? sdks});
}

/// @nodoc
class __$$_ListingParamsCopyWithImpl<$Res>
    extends _$ListingParamsCopyWithImpl<$Res, _$_ListingParams>
    implements _$$_ListingParamsCopyWith<$Res> {
  __$$_ListingParamsCopyWithImpl(
      _$_ListingParams _value, $Res Function(_$_ListingParams) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = freezed,
    Object? search = freezed,
    Object? entries = freezed,
    Object? version = freezed,
    Object? chains = freezed,
    Object? recommendedIds = freezed,
    Object? excludedIds = freezed,
    Object? sdks = freezed,
  }) {
    return _then(_$_ListingParams(
      page: freezed == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
      search: freezed == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String?,
      entries: freezed == entries
          ? _value.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as int?,
      version: freezed == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int?,
      chains: freezed == chains
          ? _value.chains
          : chains // ignore: cast_nullable_to_non_nullable
              as String?,
      recommendedIds: freezed == recommendedIds
          ? _value.recommendedIds
          : recommendedIds // ignore: cast_nullable_to_non_nullable
              as String?,
      excludedIds: freezed == excludedIds
          ? _value.excludedIds
          : excludedIds // ignore: cast_nullable_to_non_nullable
              as String?,
      sdks: freezed == sdks
          ? _value.sdks
          : sdks // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _$_ListingParams implements _ListingParams {
  const _$_ListingParams(
      {this.page,
      this.search,
      this.entries,
      this.version,
      this.chains,
      this.recommendedIds,
      this.excludedIds,
      this.sdks});

  factory _$_ListingParams.fromJson(Map<String, dynamic> json) =>
      _$$_ListingParamsFromJson(json);

  @override
  final int? page;
  @override
  final String? search;
  @override
  final int? entries;
  @override
  final int? version;
  @override
  final String? chains;
  @override
  final String? recommendedIds;
  @override
  final String? excludedIds;
  @override
  final String? sdks;

  @override
  String toString() {
    return 'ListingParams(page: $page, search: $search, entries: $entries, version: $version, chains: $chains, recommendedIds: $recommendedIds, excludedIds: $excludedIds, sdks: $sdks)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ListingParams &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.search, search) || other.search == search) &&
            (identical(other.entries, entries) || other.entries == entries) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.chains, chains) || other.chains == chains) &&
            (identical(other.recommendedIds, recommendedIds) ||
                other.recommendedIds == recommendedIds) &&
            (identical(other.excludedIds, excludedIds) ||
                other.excludedIds == excludedIds) &&
            (identical(other.sdks, sdks) || other.sdks == sdks));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, page, search, entries, version,
      chains, recommendedIds, excludedIds, sdks);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ListingParamsCopyWith<_$_ListingParams> get copyWith =>
      __$$_ListingParamsCopyWithImpl<_$_ListingParams>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ListingParamsToJson(
      this,
    );
  }
}

abstract class _ListingParams implements ListingParams {
  const factory _ListingParams(
      {final int? page,
      final String? search,
      final int? entries,
      final int? version,
      final String? chains,
      final String? recommendedIds,
      final String? excludedIds,
      final String? sdks}) = _$_ListingParams;

  factory _ListingParams.fromJson(Map<String, dynamic> json) =
      _$_ListingParams.fromJson;

  @override
  int? get page;
  @override
  String? get search;
  @override
  int? get entries;
  @override
  int? get version;
  @override
  String? get chains;
  @override
  String? get recommendedIds;
  @override
  String? get excludedIds;
  @override
  String? get sdks;
  @override
  @JsonKey(ignore: true)
  _$$_ListingParamsCopyWith<_$_ListingParams> get copyWith =>
      throw _privateConstructorUsedError;
}
