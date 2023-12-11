// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: non_constant_identifier_names

part of 'w3m_wallet_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$W3MWalletInfoImpl _$$W3MWalletInfoImplFromJson(Map<String, dynamic> json) =>
    _$W3MWalletInfoImpl(
      listing: Listing.fromJson(json['listing']),
      installed: json['installed'] as bool,
      recent: json['recent'] as bool,
    );

Map<String, dynamic> _$$W3MWalletInfoImplToJson(_$W3MWalletInfoImpl instance) =>
    <String, dynamic>{
      'listing': instance.listing.toJson(),
      'installed': instance.installed,
      'recent': instance.recent,
    };
