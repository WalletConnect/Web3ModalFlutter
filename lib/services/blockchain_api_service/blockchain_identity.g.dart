// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blockchain_identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_BlockchainIdentity _$$_BlockchainIdentityFromJson(
        Map<String, dynamic> json) =>
    _$_BlockchainIdentity(
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$$_BlockchainIdentityToJson(
    _$_BlockchainIdentity instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('avatar', instance.avatar);
  return val;
}
