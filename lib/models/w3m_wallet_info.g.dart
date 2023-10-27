// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: non_constant_identifier_names

part of 'w3m_wallet_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_W3MWalletInfo _$$_W3MWalletInfoFromJson(Map<String, dynamic> json) =>
    _$_W3MWalletInfo(
      listing: Listing.fromJson(json['listing']),
      installed: json['installed'] as bool,
      recent: json['recent'] as bool,
    );

Map<String, dynamic> _$$_W3MWalletInfoToJson(_$_W3MWalletInfo instance) =>
    <String, dynamic>{
      'listing': instance.listing.toJson(),
      'installed': instance.installed,
      'recent': instance.recent,
    };
