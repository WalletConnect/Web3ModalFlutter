// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletData _$WalletDataFromJson(Map<String, dynamic> json) => WalletData(
      id: json['id'] as String,
      name: json['name'] as String,
      universal: json['universal'] as String,
      homepage: json['homepage'] as String,
      native: json['native'] as String?,
    );

Map<String, dynamic> _$WalletDataToJson(WalletData instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'universal': instance.universal,
    'homepage': instance.homepage,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('native', instance.native);
  return val;
}

ListingResponse _$ListingResponseFromJson(Map<String, dynamic> json) =>
    ListingResponse(
      listings: (json['listings'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Listing.fromJson(e as Map<String, dynamic>)),
      ),
      total: json['total'] as int,
    );

Map<String, dynamic> _$ListingResponseToJson(ListingResponse instance) =>
    <String, dynamic>{
      'listings': instance.listings,
      'total': instance.total,
    };

Listing _$ListingFromJson(Map<String, dynamic> json) => Listing(
      id: json['id'] as String,
      name: json['name'] as String,
      homepage: json['homepage'] as String,
      imageId: json['image_id'] as String,
      app: App.fromJson(json['app'] as Map<String, dynamic>),
      injected: (json['injected'] as List<dynamic>?)
              ?.map((e) => Injected.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      mobile: Mobile.fromJson(json['mobile'] as Map<String, dynamic>),
      desktop: Desktop.fromJson(json['desktop'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ListingToJson(Listing instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'homepage': instance.homepage,
      'image_id': instance.imageId,
      'app': instance.app,
      'injected': instance.injected,
      'mobile': instance.mobile,
      'desktop': instance.desktop,
    };

App _$AppFromJson(Map<String, dynamic> json) => App(
      browser: json['browser'] as String?,
      ios: json['ios'] as String?,
      android: json['android'] as String?,
      mac: json['mac'] as String?,
      windows: json['windows'] as String?,
      linux: json['linux'] as String?,
      chrome: json['chrome'] as String?,
      firefox: json['firefox'] as String?,
      safari: json['safari'] as String?,
      edge: json['edge'] as String?,
      opera: json['opera'] as String?,
    );

Map<String, dynamic> _$AppToJson(App instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('browser', instance.browser);
  writeNotNull('ios', instance.ios);
  writeNotNull('android', instance.android);
  writeNotNull('mac', instance.mac);
  writeNotNull('windows', instance.windows);
  writeNotNull('linux', instance.linux);
  writeNotNull('chrome', instance.chrome);
  writeNotNull('firefox', instance.firefox);
  writeNotNull('safari', instance.safari);
  writeNotNull('edge', instance.edge);
  writeNotNull('opera', instance.opera);
  return val;
}

Injected _$InjectedFromJson(Map<String, dynamic> json) => Injected(
      injectedId: json['injected_id'] as String,
      namespace: json['namespace'] as String,
    );

Map<String, dynamic> _$InjectedToJson(Injected instance) => <String, dynamic>{
      'injected_id': instance.injectedId,
      'namespace': instance.namespace,
    };

Mobile _$MobileFromJson(Map<String, dynamic> json) => Mobile(
      native: json['native'] as String?,
      universal: json['universal'] as String?,
    );

Map<String, dynamic> _$MobileToJson(Mobile instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('native', instance.native);
  writeNotNull('universal', instance.universal);
  return val;
}

Desktop _$DesktopFromJson(Map<String, dynamic> json) => Desktop(
      native: json['native'] as String?,
      universal: json['universal'] as String?,
    );

Map<String, dynamic> _$DesktopToJson(Desktop instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('native', instance.native);
  writeNotNull('universal', instance.universal);
  return val;
}

ListingParams _$ListingParamsFromJson(Map<String, dynamic> json) =>
    ListingParams(
      page: json['page'] as int?,
      search: json['search'] as String?,
      entries: json['entries'] as int?,
      version: json['version'] as int?,
      chains: json['chains'] as String?,
      recommendedIds: json['recommendedIds'] as String?,
      excludedIds: json['excludedIds'] as String?,
      sdks: json['sdks'] as String?,
    );

Map<String, dynamic> _$ListingParamsToJson(ListingParams instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('page', instance.page);
  writeNotNull('search', instance.search);
  writeNotNull('entries', instance.entries);
  writeNotNull('version', instance.version);
  writeNotNull('chains', instance.chains);
  writeNotNull('recommendedIds', instance.recommendedIds);
  writeNotNull('excludedIds', instance.excludedIds);
  writeNotNull('sdks', instance.sdks);
  return val;
}
