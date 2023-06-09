import 'package:json_annotation/json_annotation.dart';

part 'listings.g.dart';

@JsonSerializable(includeIfNull: false)
class WalletData {
  String id;
  String name;
  String universal;
  String homepage;
  String? native;

  WalletData({
    required this.id,
    required this.name,
    required this.universal,
    required this.homepage,
    this.native,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) =>
      _$WalletDataFromJson(json);

  Map<String, dynamic> toJson() => _$WalletDataToJson(this);

  @override
  String toString() {
    return 'WalletData(id: $id, name: $name, universal: $universal, homepage: $homepage, native: $native)';
  }
}

@JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake)
class ListingResponse {
  Map<String, Listing> listings;
  int total;

  ListingResponse({
    required this.listings,
    required this.total,
  });

  factory ListingResponse.fromJson(Map<String, dynamic> json) =>
      _$ListingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ListingResponseToJson(this);

  @override
  String toString() => 'ListingResponse(listings: $listings, total: $total)';
}

@JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake)
class Listing {
  String id;
  String name;
  String homepage;
  String imageId;
  App app;
  List<Injected> injected;
  Mobile mobile;
  Desktop desktop;

  Listing({
    required this.id,
    required this.name,
    required this.homepage,
    required this.imageId,
    required this.app,
    this.injected = const [],
    required this.mobile,
    required this.desktop,
  });

  factory Listing.fromJson(Map<String, dynamic> json) =>
      _$ListingFromJson(json);

  Map<String, dynamic> toJson() => _$ListingToJson(this);

  @override
  String toString() {
    return 'Listing(id: $id, name: $name, homepage: $homepage, imageId: $imageId, app: $app, injected: $injected, mobile: $mobile, desktop: $desktop)';
  }
}

@JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake)
class App {
  String? browser;
  String? ios;
  String? android;
  String? mac;
  String? windows;
  String? linux;
  String? chrome;
  String? firefox;
  String? safari;
  String? edge;
  String? opera;

  App({
    this.browser,
    this.ios,
    this.android,
    this.mac,
    this.windows,
    this.linux,
    this.chrome,
    this.firefox,
    this.safari,
    this.edge,
    this.opera,
  });

  factory App.fromJson(Map<String, dynamic> json) => _$AppFromJson(json);

  Map<String, dynamic> toJson() => _$AppToJson(this);

  @override
  String toString() {
    return 'App(browser: $browser, ios: $ios, android: $android, mac: $mac, windows: $windows, linux: $linux, chrome: $chrome, firefox: $firefox, safari: $safari, edge: $edge, opera: $opera)';
  }
}

@JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake)
class Injected {
  String injectedId;
  String namespace;

  Injected({
    required this.injectedId,
    required this.namespace,
  });

  factory Injected.fromJson(Map<String, dynamic> json) =>
      _$InjectedFromJson(json);

  Map<String, dynamic> toJson() => _$InjectedToJson(this);

  @override
  String toString() =>
      'Injected(injectedId: $injectedId, namespace: $namespace)';
}

@JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake)
class Mobile {
  String? native;
  String? universal;

  Mobile({
    required this.native,
    required this.universal,
  });

  factory Mobile.fromJson(Map<String, dynamic> json) => _$MobileFromJson(json);

  Map<String, dynamic> toJson() => _$MobileToJson(this);

  @override
  String toString() => 'Mobile(native: $native, universal: $universal)';
}

@JsonSerializable(includeIfNull: false, fieldRename: FieldRename.snake)
class Desktop {
  String? native;
  String? universal;

  Desktop({
    required this.native,
    required this.universal,
  });

  factory Desktop.fromJson(Map<String, dynamic> json) =>
      _$DesktopFromJson(json);

  Map<String, dynamic> toJson() => _$DesktopToJson(this);

  @override
  String toString() => 'Desktop(native: $native, universal: $universal)';
}

@JsonSerializable(includeIfNull: false)
class ListingParams {
  int? page;
  String? search;
  int? entries;
  int? version;
  String? chains;
  String? recommendedIds;
  String? excludedIds;
  String? sdks;

  ListingParams({
    this.page,
    this.search,
    this.entries,
    this.version,
    this.chains,
    this.recommendedIds,
    this.excludedIds,
    this.sdks,
  });

  factory ListingParams.fromJson(Map<String, dynamic> json) =>
      _$ListingParamsFromJson(json);

  Map<String, dynamic> toJson() => _$ListingParamsToJson(this);

  @override
  String toString() {
    return 'ListingParams(page: $page, search: $search, entries: $entries, version: $version, chains: $chains, recommendedIds: $recommendedIds, excludedIds: $excludedIds, sdks: $sdks)';
  }
}
