// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_WalletData _$$_WalletDataFromJson(Map<String, dynamic> json) =>
    _$_WalletData(
      listing: Listing.fromJson(json['listing'] as Map<String, dynamic>),
      installed: json['installed'] as bool,
    );

Map<String, dynamic> _$$_WalletDataToJson(_$_WalletData instance) =>
    <String, dynamic>{
      'listing': instance.listing,
      'installed': instance.installed,
    };

_$_ListingResponse _$$_ListingResponseFromJson(Map<String, dynamic> json) =>
    _$_ListingResponse(
      listings: (json['listings'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Listing.fromJson(e as Map<String, dynamic>)),
      ),
      total: json['total'] as int,
    );

Map<String, dynamic> _$$_ListingResponseToJson(_$_ListingResponse instance) =>
    <String, dynamic>{
      'listings': instance.listings,
      'total': instance.total,
    };

_$_Listing _$$_ListingFromJson(Map<String, dynamic> json) => _$_Listing(
      id: json['id'] as String,
      name: json['name'] as String,
      homepage: json['homepage'] as String,
      imageId: json['image_id'] as String,
      app: App.fromJson(json['app'] as Map<String, dynamic>),
      injected: (json['injected'] as List<dynamic>?)
          ?.map((e) => Injected.fromJson(e as Map<String, dynamic>))
          .toList(),
      mobile: Redirect.fromJson(json['mobile'] as Map<String, dynamic>),
      desktop: Redirect.fromJson(json['desktop'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_ListingToJson(_$_Listing instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'homepage': instance.homepage,
    'image_id': instance.imageId,
    'app': instance.app,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('injected', instance.injected);
  val['mobile'] = instance.mobile;
  val['desktop'] = instance.desktop;
  return val;
}

_$_App _$$_AppFromJson(Map<String, dynamic> json) => _$_App(
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

Map<String, dynamic> _$$_AppToJson(_$_App instance) {
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

_$_Injected _$$_InjectedFromJson(Map<String, dynamic> json) => _$_Injected(
      injectedId: json['injected_id'] as String,
      namespace: json['namespace'] as String,
    );

Map<String, dynamic> _$$_InjectedToJson(_$_Injected instance) =>
    <String, dynamic>{
      'injected_id': instance.injectedId,
      'namespace': instance.namespace,
    };

_$_ListingParams _$$_ListingParamsFromJson(Map<String, dynamic> json) =>
    _$_ListingParams(
      page: json['page'] as int?,
      search: json['search'] as String?,
      entries: json['entries'] as int?,
      version: json['version'] as int?,
      chains: json['chains'] as String?,
      recommendedIds: json['recommendedIds'] as String?,
      excludedIds: json['excludedIds'] as String?,
      sdks: json['sdks'] as String?,
    );

Map<String, dynamic> _$$_ListingParamsToJson(_$_ListingParams instance) {
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
